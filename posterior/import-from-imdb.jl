#!/usr/bin/julia

import YAML
using CSV
using DataFrames

path = "assets/imdb-ratings.csv"

df = path |> CSV.File |> DataFrame

df = sort(df, "Release Date")[:, ["Your Rating", "Title", "Year", "Const"]]

# describe(df) |> println
println(df.Year)

items = map(df |> eachrow) do row
    Dict(:rating => row."Your Rating", :title => row.Title, :year => row.Year, :imdb_id => row.Const)
end

movies = Dict(:items => items)

YAML.write_file("assets/movies.yml", movies)
