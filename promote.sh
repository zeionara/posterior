#!/bin/bash

src=${1:-augmented-movies}
dst=${2:-movies}

mv assets/$dst.yml assets/__$dst.yml
mv assets/$src.yml assets/$dst.yml
