#!/bin/bash

# Use this bash script to populate the "gh-pages branch" with content from the maintained "master branch".
# Call this script with a file to populate from master branch.
#   - Ex: sh populate.sh Lab1.html
#   - No error checking is done to determine that the parent file actually exists.

file=$1
git checkout master decks/1501/"$file"
