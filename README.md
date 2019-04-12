# papervis

Visualize the paper writing process through your Git commit history

## Installation

This is custom software so it should be installed under `/opt` at

```
git clone depth -1 https://github.com/matthewfeickert/papervis.git /opt/papervis
```

## Use

> Instructions describe inherited code workflow


1. Clone the repo you want to visualize with repo name `Paper`
2. Navigate into the repo (`cd Paper`)
3. Configure the contents of the `Makefile` of the `Paper` repo to produce a PDF called `paper.pdf` 
4. Determine the starting commit of your visualization and specify that in `make_all.sh`
5. Generate the files for each commit (`bash make_all.sh`)
6. Convert PDFs to PNGs and then animate to `.mp4` with `ffmpeg` (`bash make_all_nup.sh`)
