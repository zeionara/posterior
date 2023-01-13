#!/usr/bin/julia

using FileIO, Images
using ProgressMeter

include("movie.jl")

movies = read_movies()

function resize(movie :: Movie, width :: Int64 = 256, height :: Int64 = 256)
    poster = movie |> get_poster_local_path |> load
    save(get_poster_local_path(movie, "assets/posters/resized"), imresize(poster, width, height))

    next!(progress_bar)
end

progress_bar = Progress(size(movies, 1), desc = "resizing images:", showspeed = true)
resize.(movies)
