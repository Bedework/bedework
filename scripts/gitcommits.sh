#!/usr/bin/env bash

git log --pretty='format:%cd' --date=format:'%Y' | uniq -c | awk '{print "Year: "$2", commits: "$1}'

# or

git shortlog -s -n --all --no-merges --since="01 Jan 2018" --before="01 Jan 2019"