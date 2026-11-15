#!/usr/bin/env bash
# Publishes this run's job results and the tail of each job log to the
# ci-logs branch, so build results can be read with a plain git fetch.
# Usage: report.sh <folder-name>
set -euo pipefail

FOLDER="$1"
WORK="$(mktemp -d)"
REMOTE="https://x-access-token:${GH_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

gh api "repos/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/jobs?per_page=100" > "${WORK}/jobs.json"

mkdir -p "${WORK}/out"
{
    echo "workflow: ${GITHUB_WORKFLOW}"
    echo "event: ${GITHUB_EVENT_NAME}"
    echo "run_number: ${GITHUB_RUN_NUMBER}"
    echo "run_attempt: ${GITHUB_RUN_ATTEMPT}"
    echo "sha: ${GITHUB_SHA}"
    echo "reported_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "jobs:"
    jq -r '.jobs[] | select(.name != "Report results") | "  \(.conclusion // .status)\t\(.name)"' "${WORK}/jobs.json"
} > "${WORK}/out/summary.txt"

jq -r '.jobs[] | select(.name != "Report results") | "\(.id)\t\(.name)"' "${WORK}/jobs.json" |
while IFS=$'\t' read -r id name; do
    safe="$(echo "${name}" | tr -c 'A-Za-z0-9\n' '_')"
    if gh api "repos/${GITHUB_REPOSITORY}/actions/jobs/${id}/logs" > "${WORK}/full.log" 2>/dev/null; then
        tail -n 250 "${WORK}/full.log" > "${WORK}/out/${safe}.log"
    else
        echo "log not available" > "${WORK}/out/${safe}.log"
    fi
done

for attempt in 1 2 3 4 5; do
    rm -rf "${WORK}/branch"
    if ! git clone -q --depth 1 --branch ci-logs "${REMOTE}" "${WORK}/branch" 2>/dev/null; then
        mkdir -p "${WORK}/branch"
        git -C "${WORK}/branch" init -q
        git -C "${WORK}/branch" checkout -q -b ci-logs
        git -C "${WORK}/branch" remote add origin "${REMOTE}"
    fi
    rm -rf "${WORK}/branch/${FOLDER}"
    mkdir -p "${WORK}/branch/${FOLDER}"
    cp -r "${WORK}/out/." "${WORK}/branch/${FOLDER}/"
    git -C "${WORK}/branch" add -A
    git -C "${WORK}/branch" -c user.name="github-actions[bot]" \
        -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
        commit -q -m "${FOLDER}: run ${GITHUB_RUN_NUMBER}" || true
    if git -C "${WORK}/branch" push -q origin ci-logs; then
        exit 0
    fi
    sleep $((attempt * 5))
done
echo "could not push results"
exit 1
