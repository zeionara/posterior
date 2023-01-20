#!/usr/bin/julia

using ArgParse
using DataFrames
using Random
using CUDA

include("movie.jl")
include("train.jl")

function parse_arguments()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--cpu", "-c"
            help = "Use cpu for model training"
            action = :store_true
        "--n-epochs", "-n"
            help = "Number of training iterations"
            arg_type = Int
            default = 10
        "--batch-size", "-b"
            help = "Number of images passed to model at once"
            arg_type = Int
            default = 16
        "--n-items", "-i"
            help = "Number of movies to take from the dataset"
            arg_type = Int
            default = nothing
        "--seed", "-s"
            help = "Random seed"
            arg_type = Int
            default = nothing
        "--train-portion", "-t"
            help = "Portion of the dataset used for training"
            arg_type = Float64
            default = 0.8
        "--images-root", "-r"
            help = "Images root"
            arg_type = String
            default = "assets/posters/resized"
        "--output-path", "-o"
            help = "Model output path"
            arg_type = String
            default = "assets/model.bson"
        "--input-path"
            help = "Model input path"
            arg_type = String
            default = nothing
    end

    return parse_args(s)
end

function split(df :: DataFrame, portion :: Float64)
    @assert 0 <= portion <= 1
    ids = axes(df, 1) |> collect |> shuffle
    sel = ids .<= (nrow(df) * portion)
    return view(df, sel, :), view(df, .!sel, :)
end

args = parse_arguments()

seed = args["seed"]

if !isnothing(seed)
    Random.seed!(seed)

    if !args["cpu"]
        CUDA.seed!(seed)
    end
end

images_root = args["images-root"]

movies = filter(isnothing(args["n-items"]) ? read_movies() : read_movies()[1:min(args["n-items"], end)]) do movie
    !ismissing(movie.poster_url)
end |> items -> map(items) do movie
    Dict(:rating => movie.rating, :path => get_poster_local_path(movie, images_root))
end |> DataFrame

# println(args["train-portion"])
# println(movies)

train_subset, test_subset = split(movies, args["train-portion"])

# println(train)
# println(test)

device = args["cpu"] ? cpu : gpu

using BSON: @save
using BSON: @load

model = if isnothing(args["input-path"])
    println("training...")

    model = train(train_subset; device = device, seed = args["seed"], n_epochs = args["n-epochs"], batch_size = args["batch-size"])

    # @save args["output-path"] model
    model_at_cpu = model |> cpu

    # @save "assets/model.bson" model_at_cpu
    @save args["output-path"] model_at_cpu

    model
else
    path = args["input-path"]

    println("loading from $path...")

    # @load "assets/model.bson" model_at_cpu
    @load path model_at_cpu

    model_at_cpu |> device
end

function get_accuracy(reference_scores, hypothesis_scores, n_scores :: Int; max_difference :: Int = 0)
    soft_matches = hypothesis_scores .- reference_scores .|> abs .<= max_difference
    return sum(soft_matches) / n_scores
end

println(model)

combined = combine(groupby(test_subset, :rating), nrow => :n_ratings)
combined[:, :frac_ratings] = combined[:, :n_ratings] / nrow(test_subset)

println(combined)

# test_subset[:, :path] .|> load_image |> device |> model |> println
hypothesis_scores = test(model, test_subset; device = device, batch_size = args["batch-size"])
reference_scores = test_subset[:, :rating]

n_scores = size(hypothesis_scores, 1)

# hard_matches = scores .== test_subset[:, :rating]
# soft_matches = scores .- test_subset[:, :rating] .|> abs .< 1

# println(soft_matches)

# println("accuracy (hard): $(sum(hard_matches) / n_scores)")

for i in 0:5
    println("accuracy (max-difference = $i): $(get_accuracy(reference_scores, hypothesis_scores, n_scores; max_difference = i))")
end
