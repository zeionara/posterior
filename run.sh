#!/bin/bash

quit () {
    echo $1
    exit 1
}

# before running this script you should put your .csv file with ratings from imdb at assets/imdb-ratings.csv

./posterior/import-from-imdb.jl || quit 'Cannot convert csv file to yaml'

mkdir assets/posters

# this step may take a while depending on number of movies in your list
./posterior/augment.jl || quit 'Cannot augment data about movies'

./promote.sh || quit 'Cannot rename generated file'

./posterior/prepare.jl || quit 'Cannot resize downloaded images'

n_items=$1

if [ -z "$1" ]; then
    ./posterior/eval.jl --cpu || quit 'Cannot evaluate model'
else
    ./posterior/eval.jl --cpu --n-items $n_items || quit 'Cannot evaluate model'
fi

./posterior/serve.jl --cpu || quit 'Cannot start server'

# then you can use provided bash script for rating poster that you want:
# ./predict.sh https://m.media-amazon.com/images/M/MV5BNTNjZDVlM2EtODVkYy00NzllLWJjZTUtOTNhYWM5M2I1MGJjXkEyXkFqcGdeQXVyODkxODg3OA@@._V1_FMjpg_UX526_.jpg
