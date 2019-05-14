#!/bin/bash

set -e

function print_usage {
    cat 1>&2 <<EOF
USAGE:
    papervis [FLAGS] [OPTIONS]

FLAGS:
    -h, --help              Print help information and quit

OPTIONS:
        --url <url>         URL of the project Git repo (HTTPS or SSH)
        --start <start>     Git commit hash to start at.
                            If left blank it will default to the first commit
                            in the project repo
        --grid <grid>       The dimensions of the grid. Ex: 9x6
        --name <name>       The name of the output .mp4 file. Default is papervis
        --target <target>   The name of an optional Makefile target to run as
                            part of the build

EOF
}

function prep_repo() {
    # 1: URL of Git repo
    git clone --recursive "${1}" build
    cd build
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
    # 2: the optional make target
    while read -r rev; do
        if [[ -f Makefile ]]; then
            if [[ $# -gt 1 ]]; then
                printf "\npapervis: ${2}\n\tlatexmk -\$(LATEX) -jobname=\"paper\" -logfilewarnings -halt-on-error \$(FILENAME)\n" >> Makefile
            else
                printf "\npapervis:\n\tlatexmk -\$(LATEX) -jobname=\"paper\" -logfilewarnings -halt-on-error \$(FILENAME)\n" >> Makefile
            fi
        else
            return 1
        fi
        git checkout "$rev"
        makepaperrev
    done < <(git rev-list --reverse "${1}..master")
}

function make_all_nup() {
    # 1: the dimensionality of the paper grid
    # 2: the name of the output .mp4 file
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

    ffmpeg -y -pattern_type glob -i '*.png' -c:v libx264  -vf "fps=24,format=yuv420p" "${2}.mp4"

    for pdfile in paper-[0-9]*-$grid_dimension.pdf ; do
        echo "${pdfile}"
    done
}

function main() {

    local GIT_REPO_URL
    local START_COMMIT_HASH
    local GRID_DIMENSION
    local OUTPUT_NAME
    OUTPUT_NAME="papervis"
    local MAKE_TARGET

    while [[ $# -gt 0 ]]; do
        arg="${1}"
        case "${arg}" in
            -h|--help)
                print_usage
                exit 0
                ;;
                # Additional options
            --url)
                GIT_REPO_URL="${2}"
                shift
                shift
                ;;
            --start)
                START_COMMIT_HASH="${2}"
                shift
                shift
                ;;
            --grid)
                GRID_DIMENSION="${2}"
                shift
                shift
                ;;
            --name)
                OUTPUT_NAME="${2}"
                shift
                shift
                ;;
            --target)
                MAKE_TARGET="${2}"
                shift
                shift
                ;;
            *)
                printf "\n    Invalid option: %s\n\n" "${1}"
                print_usage
                exit 1
                ;;
        esac
    done

    # Check input values
    if [[ -z "${GIT_REPO_URL}" ]]; then
        printf "\n# Enter the Git repo URL (HTTPS or SHH) with the --url option\n\n"
        exit 1
    fi

    if [[ -z "${GRID_DIMENSION}" ]]; then
        printf "\n# Enter the grid dimension with the --grid option\n# A example would be 9x6\n\n"
        exit 1
    fi

    # Clone and cd
    prep_repo "${GIT_REPO_URL}"

    if [[ -z "${START_COMMIT_HASH}" ]]; then
        START_COMMIT_HASH="$(git rev-list --max-parents=0 HEAD)"
        printf "\n# Starting papervis at the first commit in the project Git repo: %s\n\n" "${START_COMMIT_HASH}"
    else
        printf "\n# Starting papervis at commit hash: %s\n\n" "${START_COMMIT_HASH}"
    fi
    sleep 2

    if [[ ! -z "${MAKE_TARGET}" ]]; then
        make_all "${START_COMMIT_HASH}" "${MAKE_TARGET}"
    else
        make_all "${START_COMMIT_HASH}"
    fi
    cd build
    make_all_nup "${GRID_DIMENSION}" "${OUTPUT_NAME}"
}

main "$@" || return 1
