# papervis

Visualize the paper writing process through your Git commit history

## Installation

This is custom software so it should be installed under `/opt` at

```
git clone https://github.com/matthewfeickert/papervis.git /opt/papervis
```

However, functionality to use it as a system wide command line utility hasn't been added yet. So for the time being you should clone it to wherever you'd like to run from.

## Requirements

`papervis` has the following dependencies:

- Git
- LaTeX
- pdfnup # provided by LaTeX
- latexmk # provided by LaTeX
- awk
- convert
- ffmpeg

and additionally requires that the Git repo you want to visualize has a `Makefile` with the following variables set in it:
- `LATEX`
- `FILENAME`

Example:
```
FILENAME = analysis_paper
LATEX = lualatex
```

## Use

You can query `papervis` for its options

```
bash papervis.sh --help
USAGE:
    papervis [FLAGS] [OPTIONS]

FLAGS:
    -h, --help              Print help information and quit

OPTIONS:
        --url <url>         URL of the project Git repo (HTTPS, SSH, or local path)
        --start <start>     Git commit hash to start at.
                            If left blank it will default to the first commit
                            in the project repo
        --grid <grid>       The dimensions of the grid. Ex: 9x6
        --name <name>       The name of the output .mp4 file. Default is papervis
        --target <target>   The name of an optional Makefile target to run as
                            part of the build

```

Once you run `papervis` check in the `build` directory for the output `.mp4` file.

## Example

```
bash papervis.sh \
    --url https://github.com/matthewfeickert/Dedman-Thesis-Latex-Template.git \
    --start 2d8d5ca13127584578cdb9806fef98dbaab60a16 \
    --grid 9x6 \
    --target figures
```

```
find build -iname "*.mp4"
# build/papervis.mp4
```

## Authors

- [Matthew Feickert](http://www.matthewfeickert.com/) ([@matthewfeickert](https://github.com/matthewfeickert))
- [Leo C. Stein](https://duetosymmetry.com/) ([@duetosymmetry](https://github.com/duetosymmetry))
