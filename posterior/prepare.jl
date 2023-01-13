#!/usr/bin/julia

import YAML

using FileIO, Images
using ProgressMeter

include("movie.jl")

# println("Loading input file...")

# spinner = ProgressUnknown("reading movies:", showspeed = true, spinner = true)

# spin = true
# @async while true
#     print(".")
#     sleep(0.05)
# end

# prog = ProgressUnknown("reading movies", spinner = true)
# 
# @async while true
#     ProgressMeter.next!(prog)
#     sleep(0.1)
# end
# 
sleep(1)
# 
# ProgressMeter.finish!(prog)

print(".")
data = YAML.load_file("assets/movies.yml")
movies = (movie -> Movie(movie["title"], movie["poster"], movie["rating"], movie["year"], movie["id"])).(data["items"])
print(".")

spin = false

function resize(movie :: Movie, width :: Int64 = 256, height :: Int64 = 256)
    poster = movie |> get_poster_local_path |> load
    save(get_poster_local_path(movie, "assets/posters/resized"), imresize(poster, width, height))

    # next!(spinner)
    # next!(progress_bar)
end

# finish!(spinner)
# progress_bar = Progress(size(movies, 1), desc = "resizing images:", showspeed = true)
resize.(movies)



