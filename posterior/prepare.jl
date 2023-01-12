#!/usr/bin/julia

import YAML

using FileIO, Images

include("movie.jl")

data = YAML.load_file("assets/movies.yml")
movies = (movie -> Movie(movie["title"], movie["poster"], movie["rating"], movie["year"], movie["id"])).(data["items"])

function resize(movie :: Movie, width :: Int64 = 256, height :: Int64 = 256)
    poster = movie |> get_poster_local_path |> load
    save(get_poster_local_path(movie, "assets/posters/resized"), imresize(poster, width, height))
end

resize.(movies)

# poster_paths = (movie -> movie |> get_poster_local_path).(movies)
# 
# poster = poster_paths |> first |> load
# resized_poster = imresize(poster, 256, 256)
# 
# print(size(resized_poster))
