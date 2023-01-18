#!/usr/bin/julia

using FileIO, Images
using ProgressMeter

include("movie.jl")

movies = read_movies()

function resize(movie :: Movie, width :: Int64 = 256, height :: Int64 = 256)
    resized_poster_path = get_poster_local_path(movie, "assets/posters/resized")

    if ismissing(resized_poster_path)
        @warn "Missing poster for movie $(movie.id) (imdb-id = $(movie.imdb_id))"
    else
        if !isfile(resized_poster_path)
            poster = movie |> get_poster_local_path |> load
            save(resized_poster_path, imresize(poster, width, height))
        end
    end

    next!(progress_bar)
end

progress_bar = Progress(size(movies, 1), desc = "resizing images:", showspeed = true)
resize.(movies)
