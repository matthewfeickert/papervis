#!/bin/bash

while read -r rev; do
    git checkout "$rev"
    ./makepaperrev.sh
done < <(git rev-list --reverse "f18e7ed088e2227f4c22cd37e28c5829c238bc1f..master")
# In the above, the commit hash before ..master is the first commit to build
