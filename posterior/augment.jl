#!/usr/bin/julia

import YAML
import HTTP
import JSON

using ProgressMeter

include("utils/string.jl")

include("movie.jl")

api_key = get(ENV, "OMDB_API_KEY", missing)

data = YAML.load_file("assets/movies.yml")

progress_bar = Progress(length(data["items"]), desc = "augmenting data:", showspeed = true)

function get_response_field(response, field) :: Union{String, Missing}
    value = get(response, field, missing)

    if value == "N/A"
        missing
    else
        value
    end
end

function nothing_to_missing(value)
    if isnothing(value)
        missing
    else
        value
    end
end

seen_ids = Set{String}()

movies = map(data["items"]) do movie
    movie = if (haskey(movie, "poster") && haskey(movie, "title") && haskey(movie, "rating") && haskey(movie, "year"))
        id = get_id(movie, movie["title"])

        if !ismissing(id)
            if id in seen_ids
                throw(ArgumentError("Duplicated movie id: $id"))  
            else
                push!(seen_ids, id)
            end
        end

        Movie(
            movie["title"] |> nothing_to_missing,
            movie["poster"] |> nothing_to_missing,
            movie["rating"] |> nothing_to_missing,
            movie["year"] |> nothing_to_missing,
            id |> nothing_to_missing
        )
    else
        # name = get(movie, "imdb_id", movie["title"])
        # response = Dict{String, Any}("Director" => "Edward A. Palmer", "BoxOffice" => "N/A", "Country" => "United Kingdom", "Writer" => "Edward A. Palmer", "Actors" => "Ingvild Deila, Stuart Mortimer", "Awards" => "N/A", "Genre" => "Drama, Thriller", "Response" => "True", "Runtime" => "77 min", "imdbRating" => "N/A", "imdbVotes" => "N/A", "Rated" => "N/A", "Metascore" => "N/A", "Plot" => "Ruby has been kidnapped, but her kidnapper doesn't want a ransom. He wants her to fall in love with him.", "Website" => "N/A", "Year" => "2015", "Title" => "Hippopotamus", "Language" => "English", "Released" => "N/A", "Poster" => "N/A", "DVD" => "N/A", "imdbID" => "tt3755154", "Ratings" => Any[], "Type" => "movie", "Production" => "N/A")

        url = if haskey(movie, "imdb_id")
            "https://www.omdbapi.com/?i=$(HTTP.escapeuri(movie["imdb_id"]))&apikey=$api_key"
        else
            "https://www.omdbapi.com/?t=$(HTTP.escapeuri(movie["title"]))&apikey=$api_key"
        end

        # println("foo")
        # println(resp)
        # println("bar")

        response = HTTP.request("GET", url).body |> String |> JSON.parse

        println(response)

        rating = 
          if haskey(movie, "rating")
            movie["rating"]
          else
            try
              string_to_number{Float64}(
                response["imdbRating"]
              )
            catch e
              if isa(e, LoadError)
                missing
              else
                rethrow(e)
              end
            end
          end

        year = 
          if haskey(movie, "year")
              movie["year"]
          else
            try
              string_to_number{Int16}(
                match(
                  r"^([0-9]{4})",
                  response["Year"]
                )[1]
              )
            catch e
              if isa(e, LoadError)
                missing
              else
                rethrow(e)
              end
            end
          end

        title = get(movie, "title", get_response_field(response, "Title"))

        # println(rating)
        # println(year)

        id = ismissing(title) ? missing : get_id(movie, title)

        if !ismissing(id)
            if id in seen_ids
                throw(ArgumentError("Duplicated movie id: $id"))  
            else
                push!(seen_ids, id)
            end
        end

        # print(id)

        Movie(
          title,
          get(movie, "poster", get_response_field(response, "Poster")),
          rating,
          # get(movie, "rating", string_to_number{Float64}(get(response, "imdbRating", missing))),
          year,
          # get(
          #   movie, "year", string_to_number{Int16}(
          #     match(
          #       r"^([0-9]{4})",
          #       get(response, "Year", missing)
          #     )[1]
          #   )
          # ),
          id
        )
    end

    poster_local_path = movie |> get_poster_local_path

    if !ismissing(poster_local_path) && !(poster_local_path |> isfile) 
        download(movie.poster_url, poster_local_path)
    end

    next!(progress_bar)

    movie
end

# println(movies)

YAML.write_file("assets/augmented-movies.yml", Dict("items" => map(asDict, movies)))
