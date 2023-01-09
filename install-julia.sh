cd tmp

wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.0-beta2-linux-x86_64.tar.gz
tar -xzvf julia-1.9.0-beta2-linux-x86_64.tar.gz

sudo mv julia-1.9.0-beta2 /usr/share/julia-1.9.0

echo 'export PATH="$PATH:/usr/share/julia-1.9.0/bin"' >> ~/.bashrc
. ~/.bashrc

julia -v
