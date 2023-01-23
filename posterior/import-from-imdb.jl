#!/usr/bin/julia

import YAML
using CSV
using DataFrames

include("utils/pipe.jl")

path = "assets/imdb-ratings.csv"

# csv_file = CSV.File

movies = @pipe Dict(
    :items => @pipe path |> CSV.File |> DataFrame |> sort("Release Date") |> (:, ["Your Rating", "Title", "Year", "Const"]) |> eachrow |> map() do row
        Dict(:rating => row."Your Rating", :title => row.Title, :year => row.Year, :imdb_id => row.Const)
    end
) |> YAML.write_file("assets/movies-tmp.yml", _)

# @pipe movies |> YAML.write_file("assets/movies-tmp.yml", _)

# df = @pipe df  |> (:, ["Your Rating", "Title", "Year", "Const"]) |> eachrow |> map() do x x end true

# df = sort(df, "Release Date")[:, ["Your Rating", "Title", "Year", "Const"]]

# describe(df) |> println
# println(df.Year)

# ii = df |> eachrow
# items = @pipe df |> map() do row
#     Dict(:rating => row."Your Rating", :title => row.Title, :year => row.Year, :imdb_id => row.Const)
# end
# 
# movies = Dict(:items => items)
# 
# print(size(movies[:items]))

# YAML.write_file("assets/movies.yml", movies)
