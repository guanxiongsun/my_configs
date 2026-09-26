#!/usr/bin/env bash
# First install only: set up this machine's GitHub SSH key. Re-run any time with `github-ssh-setup`.
"$HOME/.local/bin/github-ssh-setup" || echo "GitHub SSH setup didn't finish; run github-ssh-setup to retry."
