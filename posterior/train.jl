#!/usr/bin/julia

using FileIO, Images
using Flux

using Statistics
# using Printf

using ProgressMeter

include("movie.jl")
include("batch.jl")

n_epochs = 10
batch_size = 16

max_rating = 10

movies = filter(read_movies()) do movie
    !ismissing(movie.poster_url)
end

posters = (movie -> permutedims(get_poster_local_path(movie, "assets/posters/resized") |> load |> channelview, (2, 3, 1))).(movies)
ratings = trunc.(Int, (movie -> movie.rating).(movies))

batches = make_batches(posters, ratings; batch_size = batch_size)

all_batch, all_y = make_all_batch(posters, ratings)

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
)

opt_state = Flux.setup(Adam(), model)

progress_bar = Progress(n_epochs, desc = "training model:", showspeed = true)
# train_loss = Float64[]

for i in 1:n_epochs
    # println("Running $(i)th epoch")

    Flux.train!(model, batches, opt_state) do m, x, y
        Flux.crossentropy(x |> m, y)
    end

    # push!(train_loss, Flux.crossentropy.(all_batch |> model |> eachcol, all_y |> eachcol) |> mean)
    next!(progress_bar; showvalues = [(:loss, Flux.crossentropy.(all_batch |> model |> eachcol, all_y |> eachcol) |> mean)])
end

# println("Train losses:")
# println(train_loss)
