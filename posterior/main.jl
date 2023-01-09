import YAML
import HTTP
import JSON

struct Movie 
    title::String
    poster_url::String
    rating::Float64
    year::Int16
end

function asDict(movie :: Movie) :: Dict 
    Dict("title" => movie.title, "poster" => movie.poster_url, "rating" => movie.rating, "year" => movie.year)
end

api_key = get(ENV, "OMDB_API_KEY", missing)

# function string_to_number(value :: Union{String, Missing}) :: Union{UInt16, Missing}
#     if value === missing 
#         return value
#     end
#     parse(UInt16, value)
# end

struct string_to_number{T} end

function string_to_number{T}(value :: Union{String, Missing}) :: Union{T, Missing} where T
    if value === missing 
        return value
    end
    parse(T, value)
end

data = YAML.load_file("assets/movies.yml")

movies = map(data["items"]) do movie
    if (haskey(movie, "poster") && haskey(movie, "title") && haskey(movie, "rating") && haskey(movie, "year"))
        Movie(movie["title"], movie["poster"], movie["rating"], movie["year"])
        # movie["poster"]
    else
        response = HTTP.request("GET", "https://www.omdbapi.com/?t=$(HTTP.escapeuri(movie["title"]))&apikey=$api_key").body |> String |> JSON.parse
        Movie(
          get(movie, "title", get(response, "Title", missing)),
          get(movie, "poster", get(response, "Poster", missing)),
          get(movie, "rating", string_to_number{Float64}(get(response, "imdbRating", missing))),
          get(movie, "year", string_to_number{Int16}(get(response, "Year", missing)))
        )
        # println(response.status)
        # println(JSON.parse(String(response.body)))
    end
end

println(movies)

YAML.write_file("assets/augmented-movies.yml", Dict("items" => map(asDict, movies)))
