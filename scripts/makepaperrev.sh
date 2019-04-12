#!/bin/bash

# Gets the commit number counted from the beginning
mcount=$(git rev-list --count --first-parent HEAD)

# echo $mcount

# At one point the paper was in the root
if [ -f Paper/paper.tex ]; then
    cd Paper
fi
make clean
make
mv paper.pdf paper-$mcount.pdf
git stash
git stash drop
# Ignore build errors
true
