#!/bin/bash
# System packages added to or removed from the base.
# Rule: RPMs only for things that must be part of the OS. User apps are Flatpaks.
# Every package added must justify itself against the speed budget.

set -ouex pipefail

# Nothing added or removed yet.
