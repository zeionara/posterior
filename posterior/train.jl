#!/usr/bin/julia

using FileIO, Images
using Flux
using OneHotArrays
using Base.Iterators
using Statistics
using Printf

include("movie.jl")

# posters = for movie in read_movies()
#     poster = get_poster_local_path(movie, "assets/posters/resized") |> load
#     poster |> size |> println
# end

movies = read_movies()

posters = (movie -> get_poster_local_path(movie, "assets/posters/resized") |> load |> channelview).(movies)
ratings = trunc.(Int, (movie -> movie.rating).(movies))

println(size(posters[1]))
# println(ratings)

batch_size = 2
max_rating = 10

function make_minibatch(X, Y, indices)
    X_batch = Array{Float32}(undef, size(X[1])..., length(indices))

    for i in 1:length(indices)
        X_batch[:, :, :, i] = Float32.(X[indices[i]])
    end

    Y_batch = onehotbatch(Y[indices], 1:max_rating)

    # print(Y_batch)

    return (X_batch, Y_batch)
end

batches = (indices -> make_minibatch(posters, ratings, indices)).(partition(1:length(posters), batch_size))

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
    Dense(15488, max_rating),
    softmax
)

train_loss = Float64[]
test_loss = Float64[]
acc = Float64[]
parameters = Flux.params(model)
opt = ADAM()
L(x, y) = Flux.crossentropy(model(x), y)
L((x, y)) = Flux.crossentropy(model(x), y)
accuracy(x, y, f) = mean(onecold(f(x)) .== onecold(y))

function update_loss!()
    push!(train_loss, mean(L.(posters)))
    @printf("train loss = %.2f\n", train_loss[end])
end

n_epochs = 10

for i in 1:n_epochs
    println("Running $(i)th epoch")
    Flux.train!(L, parameters, batches, opt; cb = Flux.throttle(update_loss!, 8)) 
end

println("Train losses:")
println(train_loss)
