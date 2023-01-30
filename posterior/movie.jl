import YAML

include("utils/nullable.jl")
include("utils/file.jl")

struct Movie 
    title :: Union{String, Missing}
    poster_url :: Union{String, Missing}
    rating :: Union{Float64, Missing}
    year :: Union{Int16, Missing}
    id :: Union{String, Missing}
    imdb_id :: Union{String, Missing}
end

struct nullable{T} end

function nullable{T}(value :: Union{T, Missing}) :: Union{T, Symbol} where T
    if ismissing(value)
        :null
    else
        value
    end
end

function asDict(movie :: Movie) :: Dict 
    Dict(
         "title" => movie.title |> nullable{String},
         "poster" => movie.poster_url |> nullable{String},
         "rating" => movie.rating |> nullable{Float64},
         "year" => movie.year |> nullable{Int16},
         "id" => movie.id |> nullable{String},
         "imdb_id" => movie.imdb_id |> nullable{String}
    )
end

function get_id(movie :: Dict, title :: AbstractString) :: String
    title_without_leading_special_characters = replace(title, r"^[^\w]+" => s"")
    title_without_trailing_or_leading_special_characters = replace(title_without_leading_special_characters, r"[^\w]+$" => s"")
    get(movie, "id", replace(title_without_trailing_or_leading_special_characters |> lowercase, r"[^\w]+" => s"-"))
end

# function get_extension(movie :: Movie) :: Union{String, Missing}
#     if ismissing(movie.poster_url)
#         missing
#     else
#         matched = match(extension_regexp, movie.poster_url)
# 
#         if isnothing(matched)
#             missing
#         else
#             matched[1]
#         end
#     end
# end

function get_poster_local_path(movie :: Movie, root :: AbstractString = "assets/posters") :: Union{String, Missing} 
    extension = get_extension(movie.poster_url)

    if ismissing(extension)
        missing
    else
       "$(root)/$(movie.id).$(extension)"
    end
end

function read_movies(path :: AbstractString = "assets/movies.yml") :: Vector{Movie}
    data = YAML.load_file(path)
    (
        movie -> Movie(
            movie["title"] |> nothing_to_missing,
            movie["poster"] |> nothing_to_missing,
            movie["rating"] |> nothing_to_missing,
            movie["year"] |> nothing_to_missing,
            movie["id"] |> nothing_to_missing,
            movie["imdb_id"] |> nothing_to_missing
        )
    ).(data["items"])
end
