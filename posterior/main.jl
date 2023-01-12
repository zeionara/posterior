#!/usr/bin/julia

import YAML
import HTTP
import JSON

include("utils/string.jl")

include("movie.jl")

api_key = get(ENV, "OMDB_API_KEY", missing)

data = YAML.load_file("assets/movies.yml")

movies = map(data["items"]) do movie
    movie = if (haskey(movie, "poster") && haskey(movie, "title") && haskey(movie, "rating") && haskey(movie, "year"))
        Movie(movie["title"], movie["poster"], movie["rating"], movie["year"], get_id(movie, movie["title"]))
    else
        response = HTTP.request("GET", "https://www.omdbapi.com/?t=$(HTTP.escapeuri(movie["title"]))&apikey=$api_key").body |> String |> JSON.parse
        title = get(movie, "title", get(response, "Title", missing))
        Movie(
          title,
          get(movie, "poster", get(response, "Poster", missing)),
          get(movie, "rating", string_to_number{Float64}(get(response, "imdbRating", missing))),
          get(movie, "year", string_to_number{Int16}(get(response, "Year", missing))),
          get_id(movie, title)
        )
    end

    poster_local_path = movie |> get_poster_local_path

    if !(poster_local_path |> isfile) 
        download(movie.poster_url, poster_local_path)
    end

    movie
end

println(movies)

YAML.write_file("assets/augmented-movies.yml", Dict("items" => map(asDict, movies)))
