#!/usr/bin/julia

import YAML

using FileIO, Images
using ProgressBars

include("movie.jl")

println("Loading input file...")

data = YAML.load_file("assets/movies.yml")
movies = (movie -> Movie(movie["title"], movie["poster"], movie["rating"], movie["year"], movie["id"])).(data["items"])

width = 256
height = 256

println("Resizing images...")

for movie in ProgressBar(movies)
    poster = movie |> get_poster_local_path |> load
    save(get_poster_local_path(movie, "assets/posters/resized"), imresize(poster, width, height))
end
