#!/usr/bin/julia

import YAML

using FileIO, Images
using Term.Progress

include("movie.jl")

println("Loading input file...")

data = YAML.load_file("assets/movies.yml")
movies = (movie -> Movie(movie["title"], movie["poster"], movie["rating"], movie["year"], movie["id"])).(data["items"])

progress_bar = ProgressBar(; columns = :detailed)
job = addjob!(progress_bar; N = size(movies, 1), description = "resizing posters")

function resize(movie :: Movie, width :: Int64 = 256, height :: Int64 = 256)
    poster = movie |> get_poster_local_path |> load
    save(get_poster_local_path(movie, "assets/posters/resized"), imresize(poster, width, height))

    update!(job)
    render(progress_bar)
end

println("Resizing images...")

start!(progress_bar)
resize.(movies)
stop!(progress_bar)
