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
3. Run the driver (`bash driver.sh $git_repo_HTTPS $start_commit_hash 9x6`)
4. Check in the `build` directory for the output
