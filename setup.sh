#!/bin/bash

# before running this script you should specify omdb api key using command like "export OMDB_API_KEY=<your-omdb-api-key-here>"

quit () {
    echo $1
    exit 1
}

local_archive_path=/tmp/julia-1.9.tar.gz

# 1. Download and unpack archive

wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.0-beta3-linux-x86_64.tar.gz -O $local_archive_path || quit "Cannot download julia"
sudo tar -xzvf $local_archive_path -C /usr/share || quit "Cannot unpack julia"
rm $local_archive_path || quit "Cannot remove downloaded julia"
sudo ln -s /usr/share/julia-1.9.0-beta3/bin/julia /usr/bin/ || quit "Cannot create symbolic link to the julia executable"

# 2. Instantiate environment (it will take a while - around 15 minutes)

julia --project=. -e 'using Pkg; Pkg.instantiate()' || quit "Cannot install dependencies"

# 3. Set up environment variables

echo -e "\nexport OMDB_API_KEY=$OMDB_API_KEY" >> ~/.bashrc || quit 'Cannot update bashrc with omdb api key'
echo 'export JULIA_PROJECT=.' >> ~/.bashrc || quit 'Cannot update bashrc with julia project default path'

. ~/.bashrc
