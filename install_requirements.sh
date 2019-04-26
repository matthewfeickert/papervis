#!/bin/bash

# Dependencies
# - Git
# - LaTeX
# - pdfnup # provided by LaTeX
# - awk # provied by gawk
# - convert # provided by graphicsmagick
# - ffmpeg

set -e

function install {
    printf "\n# sudo apt-get update\n\n"
    sudo apt-get update -qq
    printf "\n# sudo apt-get install\n\n"
    sudo apt-get install -y \
        gawk \
        graphicsmagick \
        ffmpeg
    printf "\n# sudo apt-get --only-upgrade install\n\n"
    sudo apt-get --only-upgrade install -y \
        git \
        gawk \
        graphicsmagick \
        ffmpeg
}

function set_permissions {
    # Give user access to ghostscript format types
    # https://alexvanderbist.com/posts/2018/fixing-imagick-error-unauthorized
    if [[ -f /etc/ImageMagick-6/policy.xml ]]; then
        # Create a backup before doing anything
        if [[ ! -f /etc/ImageMagick-6/policy-backup.xml ]]; then
            sudo cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy-backup.xml
        fi

        local replace_line_number
        replace_line_number=$(grep -n "policy domain=\"coder\" rights=\"none\" pattern=\"PDF\"" /etc/ImageMagick-6/policy.xml | cut -f1 -d:)
        # Only update if there is a line with the pattern match
        if [[ ! -z "${replace_line_number}" ]]; then
            sudo sed -i "${replace_line_number}s/none/read|write/" /etc/ImageMagick-6/policy.xml
        fi
    fi
}

function main() {
    install
    set_permissions
}

main "$@" || return 1
