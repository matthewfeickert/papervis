#!/bin/bash

cd Paper

# Set the desired layout here
nup="9x6"

# Yes, I know this violates Don't Repeat Yourself, but I couldn't be
# bothered to figure out how to do n-width digits in bash

for pdfile in paper-?.pdf ; do
    k=$(echo "${pdfile}" | cut -d- -f2 | cut -d. -f1)
    if [ ! -f "paper-00${k}-${nup}.pdf" ]; then
        pdfnup --nup "${nup}" --suffix "${nup}" --batch "${pdfile}"
        mv "paper-${k}-${nup}.pdf" "paper-00${k}-${nup}.pdf"
    fi
done

for pdfile in paper-??.pdf; do
    k=$(echo "${pdfile}" | cut -d- -f2 | cut -d. -f1);
    if [ ! -f "paper-00${k}-${nup}.pdf" ]; then
        pdfnup --nup "${nup}" --suffix "${nup}" --batch "${pdfile}"
        mv "paper-${k}-${nup}.pdf" "paper-0${k}-${nup}.pdf"
    fi
done

for pdfile in paper-???.pdf ; do
    if [ ! -f "${pdfile%.*}"-$nup.pdf ]; then
        pdfnup --nup "${nup}" --suffix "${nup}" --batch "${pdfile}"
    fi
done

for pdfile in paper-[0-9]*-$nup.pdf ; do
    if [ ! -f "${pdfile%.*}".png ]; then
        convert -verbose -density 300 -geometry 'x800' -background "#FFFFFF" -flatten "${pdfile}" "${pdfile%.*}".png
    fi
done

ffmpeg -y -pattern_type glob -i '*.png' -c:v libx264  -vf "fps=24,format=yuv420p" paper-anim.mp4
