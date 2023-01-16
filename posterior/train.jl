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

posters = (movie -> permutedims(get_poster_local_path(movie, "assets/posters/resized") |> load |> channelview, (2, 3, 1))).(movies)
ratings = trunc.(Int, (movie -> movie.rating).(movies))

# println(size(posters[1]))
# println(ratings)

batch_size = 2
max_rating = 10

function make_minibatch(X, Y, indices)
    X_batch = Array{Float32}(undef, size(X[1])..., length(indices))

    # println("batch size:")
    # println(size(X_batch))

    # println("size of x:")
    # println(size(X))
    # println(size(X[indices[1]]))
    # println(X == posters)
    # println(indices[1])
    # Float32.(X[indices[1]])
    # Float32.(X)

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
    # Dense(15488, max_rating),
    Dense(2097152, max_rating),
    softmax
)

train_loss = Float64[]
# test_loss = Float64[]
# acc = Float64[]
# parameters = Flux.params(model)
# opt = ADAM()
# L(x, y) = Flux.crossentropy(model(x), y)
# L((x, y)) = Flux.crossentropy(model(x), y)
# accuracy(x, y, f) = mean(onecold(f(x)) .== onecold(y))

# function update_loss!()
#     push!(train_loss, mean(L.(posters)))
#     @printf("train loss = %.2f\n", train_loss[end])
# end

n_epochs = 10

opt_state = Flux.setup(Adam(), model)

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


all_batch = Array{Float32}(undef, size(posters[1])..., length(posters))

# println(size(all_batch))
# println(size(posters))

for i in 1:length(posters)
    all_batch[:, :, :, i] = Float32.(posters[i])
end


for i in 1:n_epochs
    println("Running $(i)th epoch")
    # print(typeof(batches))
    # Flux.train!(L, parameters, batches, opt; cb = Flux.throttle(update_loss!, 8)) 
    Flux.train!(model, batches, opt_state) do m, x, y
        y_hat = m(x)
        loss = Flux.crossentropy(y_hat, y)
        println(size(y_hat))
        println(y_hat)

        all_y = onehotbatch(ratings, 1:max_rating)

        println("---")
        # println(size(all_y))
        println(all_y)

        # print(size(posters))

        all_y_hat = all_batch |> m
        # println(size(all_y_hat))
        println(all_y_hat)
        println("***")
        println(Flux.crossentropy.(all_y_hat |> eachcol, all_y |> eachcol) |> mean)
        # push!(train_loss, mean(((x, y) -> Flux.crossentropy(m(x), y)).(posters, )))
        loss
    end
end

println("Train losses:")
println(train_loss)
