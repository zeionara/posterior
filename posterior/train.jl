#!/usr/bin/julia

using FileIO, Images
using Flux
using CUDA

using Statistics
using Base.Iterators
# using Printf

using ProgressMeter
using ArgParse

include("movie.jl")
include("batch.jl")

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
    end

    return parse_args(s)
end

args = parse_arguments()

# println(args)

device = args["cpu"] ? cpu : gpu

n_epochs = args["n-epochs"]
batch_size = args["batch-size"]

max_rating = 10

movies = filter(isnothing(args["n-items"]) ? read_movies() : read_movies()[1:min(args["n-items"], end)]) do movie
    !ismissing(movie.poster_url)
end

# posters = (movie -> permutedims(get_poster_local_path(movie, "assets/posters/resized") |> load |> channelview, (2, 3, 1)) |> device).(movies)
posters = (movie -> permutedims(get_poster_local_path(movie, "assets/posters/resized") |> load |> channelview, (2, 3, 1))).(movies)
ratings = trunc.(Int, (movie -> movie.rating).(movies))

# println("foo")
batches = make_batches(posters, ratings; batch_size = batch_size)
# println("finished making batches")
# println(size(batches, 1))

# all_batch, all_y = make_all_batch(posters, ratings; device = device)

model = Chain(
    Conv((3, 3), 3 => 32, relu; pad = (1, 1)),
    MaxPool((2, 2)),
    Conv((3, 3), 32 => 64, relu; pad = (1, 1)),
    MaxPool((2, 2)),
    Conv((3, 3), 64 => 128, relu; pad = (1, 1)),
    MaxPool((2, 2)),
    Flux.flatten,
    Dense(131072, max_rating),
    softmax
) |> device

opt_state = Flux.setup(Adam(), model)

progress_bar = Progress(n_epochs, desc = "training model:", showspeed = true)
# train_loss = Float64[]

for i in 1:n_epochs
    # println("Running $(i)th epoch")

    Flux.train!(model, batches, opt_state) do m, x, y
        Flux.crossentropy(x |> device |> m, y |> device)
    end

    # push!(train_loss, Flux.crossentropy.(all_batch |> model |> eachcol, all_y |> eachcol) |> mean)
    # println("next epoch")
    # next!(progress_bar; showvalues = [(:loss, Flux.crossentropy.(all_batch |> model |> eachcol, all_y |> eachcol) |> mean)])
    # next!(progress_bar; showvalues = [(:loss, Flux.crossentropy.(all_batch |> model |> eachcol, all_y |> eachcol) |> mean)])

    loss = map(batches) do (x, y)
        Flux.crossentropy.(x |> device |> model |> cpu |> eachcol, y |> eachcol) |> mean
    end |> flatten |> mean

    next!(progress_bar; showvalues = [(:loss, loss)])
end

# println("Train losses:")
# println(train_loss)
