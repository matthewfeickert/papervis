#!/bin/bash

set -e

function prep_repo() {
    # 1: URL of Git repo
    git clone "${1}.git" build
    cd build
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
        if [[ -f Makefile ]]; then
            printf "\npapervis:\n\tlatexmk -\$(LATEX) -jobname=\"paper\" -logfilewarnings -halt-on-error \$(FILENAME)\n" >> Makefile
        else
            return 1
        fi
        git checkout "$rev"
        makepaperrev
    done < <(git rev-list --reverse "${1}..master")
}

function make_all_nup() {
    # 1: the dimensionality of the paper grid
    local grid_dimension
    grid_dimension="${1}"

    shopt -s extglob
    regex="paper-+([0-9]).pdf"
    max_page_number_size=$(find ${regex} | cut -d- -f2 | cut -d. -f1 | awk '{ print length }' | sort | tail -1)

    # Convert to "n-up" PDF files and rename with zero padded names for order
    for pdfile in ${regex}; do
        pdfnup --nup "${grid_dimension}" --suffix "${grid_dimension}" --batch "${pdfile}"

        page_number=$(echo "${pdfile}" | cut -d- -f2 | cut -d. -f1);
        page_number_size=$(echo "${page_number}" | awk '{ print length }')
        zero_pad_len=$((max_page_number_size-page_number_size))
        if (( zero_pad_len > 0 )); then
            mv "paper-${page_number}-${grid_dimension}.pdf" "$(printf "paper-%0${zero_pad_len}d${page_number}-${grid_dimension}.pdf")"
        fi
    done

    # Convert to PNG and animate
    for pdfile in paper-[0-9]*-$grid_dimension.pdf ; do
        if [ ! -f "${pdfile%.*}".png ]; then
            convert -verbose -density 300 -geometry 'x800' -background "#FFFFFF" -flatten "${pdfile}" "${pdfile%.*}".png
        fi
    done

    ffmpeg -y -pattern_type glob -i '*.png' -c:v libx264  -vf "fps=24,format=yuv420p" papervis.mp4

    for pdfile in paper-[0-9]*-$grid_dimension.pdf ; do
        echo "${pdfile}"
    done
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

            local grid_dimension
            if [[ $# -gt 2 ]]; then
                grid_dimension="${3}"
            else
                grid_dimension="9x6"
            fi
            cd build
            make_all_nup "${grid_dimension}"
        fi
    fi
}

# bash papervis.sh https://github.com/matthewfeickert/Dedman-Thesis-Latex-Template 2d8d5ca13127584578cdb9806fef98dbaab60a16

main "$@" || return 1
