#!/usr/bin/julia

using FileIO, Images
using Flux
# using OneHotArrays
using Base.Iterators
using Statistics
using Printf

include("movie.jl")
include("batch.jl")

# posters = for movie in read_movies()
#     poster = get_poster_local_path(movie, "assets/posters/resized") |> load
#     poster |> size |> println
# end

movies = read_movies()

posters = (movie -> permutedims(get_poster_local_path(movie, "assets/posters/resized") |> load |> channelview, (2, 3, 1))).(movies)
ratings = trunc.(Int, (movie -> movie.rating).(movies))

# println(size(posters[1]))
# println(ratings)

batch_size = 2
max_rating = 10

# function make_minibatch(X, Y, indices)
#     X_batch = Array{Float32}(undef, size(X[1])..., length(indices))
# 
#     for i in 1:length(indices)
#         X_batch[:, :, :, i] = Float32.(X[indices[i]])
#     end
# 
#     Y_batch = onehotbatch(Y[indices], 1:max_rating)
# 
#     return (X_batch, Y_batch)
# end

# old_batches = (indices -> make_batch(posters, ratings; indices = indices)).(partition(1:length(posters), batch_size))

batches = make_batches(posters, ratings; batch_size = 2)

# println(old_batches == batches)

train_loss = Float64[]

n_epochs = 10

model = Chain(
    # # Conv((3, 3), 3 => 32, relu; pad = (1, 1)),
    Conv((3, 3), 3 => 32, relu; pad = (1, 1), bias = false),
    # MaxPool((2, 2)),
    # # Conv((3, 3), 32 => 64, relu; pad = (1, 1)),
    # Conv((3, 3), 32 => 64),
    # MaxPool((2, 2)),
    # # Conv((3, 3), 64 => 128, relu; pad = (1, 1)),
    # Conv((3, 3), 64 => 128),
    # MaxPool((2, 2)),
    Flux.flatten,
    # Dense(15488, max_rating),
    Dense(2097152, max_rating),
    softmax
)

opt_state = Flux.setup(Adam(), model)

# all_batch = Array{Float32}(undef, size(posters[1])..., length(posters))
# 
# for i in 1:length(posters)
#     all_batch[:, :, :, i] = Float32.(posters[i])
# end
# 
# all_y = onehotbatch(ratings, 1:max_rating)

all_batch, all_y = make_all_batch(posters, ratings)

for i in 1:n_epochs
    println("Running $(i)th epoch")

    Flux.train!(model, batches, opt_state) do m, x, y
        Flux.crossentropy(x |> m, y)
    end

    push!(train_loss, Flux.crossentropy.(all_batch |> model |> eachcol, all_y |> eachcol) |> mean)
end

println("Train losses:")
println(train_loss)
