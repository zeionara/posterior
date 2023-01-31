#!/bin/bash

quit () {
    echo $1
    exit 1
}

if [ -z "$1" ]; then
    echo 'is null'
else
    echo 'is not null'
fi
# echo -e "\nexport OMDB_API_KEY=$OMDB_API_KEY" >> ~/.bashrc || quit 'Cannot update bashrc with omdb api key'
# echo 'export JULIA_PROJECT=.' >> ~/.bashrc || quit 'Cannot update bashrc with julia project default path'

# . ~/.bashrc
