#!/bin/bash

set -e

function prep_repo() {
    # 1: URL of Git repo
    git clone "${1}.git" build
    cd build
    if [[ -f Makefile ]]; then
        printf "\npapervis:\n\tlatexmk -\$(LATEX) -jobname=\"paper\" -logfilewarnings -halt-on-error \$(FILENAME)\n" >> Makefile
    else
        return 1
    fi
    # TODO: This is test repo specific. Need to generalize
    make figures
}

function makepaperrev() {
    # Gets the commit number counted from the beginning
    local mcount
    mcount=$(git rev-list --count --first-parent HEAD)

    echo "${mcount}"
    make clean
    make papervis
    mv paper.pdf "paper-${mcount}.pdf"
    git stash
    git stash drop
    # Ignore build errors
    true
}

function make_all() {
    # 1: the first commit hash to build
    while read -r rev; do
        git checkout "$rev"
        makepaperrev
    done < <(git rev-list --reverse "${1}..master")
}

function main() {

    if [[ $# -gt 0 ]]; then
        local git_repo_HTTPS
        git_repo_HTTPS="${1}"

        prep_repo "${git_repo_HTTPS}"

        if [[ $# -gt 1 ]]; then
            local start_commit_hash
            start_commit_hash="${2}"
            printf "\nstarting hash: %s" "${start_commit_hash}"
            sleep 1

            make_all "${start_commit_hash}"
        fi
    fi
}

# bash driver.sh https://github.com/matthewfeickert/Dedman-Thesis-Latex-Template 1e3a42f6a1bd39275c59ac1e3b713cd7a2d9a927

main "$@" || return 1
