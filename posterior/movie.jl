extension_regexp = r"\.([^.]+)$"

struct Movie 
    title :: String
    poster_url :: String
    rating :: Float64
    year :: Int16
    id :: String
end

function asDict(movie :: Movie) :: Dict 
    Dict("title" => movie.title, "poster" => movie.poster_url, "rating" => movie.rating, "year" => movie.year, "id" => movie.id)
end

function get_id(movie :: Dict, title :: String) :: String
    title_without_leading_special_characters = replace(title, r"^[^\w]+" => s"")
    title_without_trailing_or_leading_special_characters = replace(title_without_leading_special_characters, r"[^\w]+$" => s"")
    get(movie, "id", replace(title_without_trailing_or_leading_special_characters |> lowercase, r"[^\w]+" => s"-"))
end

function get_extension(movie :: Movie) :: String
    match(extension_regexp, movie.poster_url)[1]
end

function get_poster_local_path(movie :: Movie, root :: String = "assets/posters") :: String 
    "$(root)/$(movie.id).$(get_extension(movie))"
end
