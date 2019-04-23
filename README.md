# papervis

Visualize the paper writing process through your Git commit history

## Installation

This is custom software so it should be installed under `/opt` at

```
git clone depth -1 https://github.com/matthewfeickert/papervis.git /opt/papervis
```

## Use

> Instructions describe inherited code workflow

1. Get the HTTPS URL of the Git repo
2. Get the commit hash of the Git repo to start at
3. Run the driver to generate the files for each commit (`bash driver.sh $git_repo_HTTPS $start_commit_hash`)
4. Convert PDFs to PNGs and then animate to `.mp4` with `ffmpeg` (`bash make_all_nup.sh`)
