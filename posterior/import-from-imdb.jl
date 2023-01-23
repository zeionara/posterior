#!/usr/bin/julia

import YAML
using CSV
using DataFrames

include("utils/pipe.jl")

path = "assets/imdb-ratings.csv"

# csv_file = CSV.File

df = @pipe path |> CSV.File |> DataFrame |> sort("Release Date") |> (:, ["Your Rating", "Title", "Year", "Const"])

# df = sort(df, "Release Date")[:, ["Your Rating", "Title", "Year", "Const"]]

# describe(df) |> println
# println(df.Year)

items = map(df |> eachrow) do row
    Dict(:rating => row."Your Rating", :title => row.Title, :year => row.Year, :imdb_id => row.Const)
end

movies = Dict(:items => items)

print(movies[:items][1:2])

# YAML.write_file("assets/movies.yml", movies)
