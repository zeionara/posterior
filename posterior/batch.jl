using OneHotArrays
using Base.Iterators

using CUDA

function make_batch(X, Y; indices, max_rating :: Integer = 10)
    X_batch = Array{Float32}(undef, size(X[1])..., length(indices))  # create an empty array

    for i in 1:length(indices)
        X_batch[:, :, :, i] = Float32.(X[indices[i]])  # copy elements indices of which are in the indices array
    end

    Y_batch = onehotbatch(Y[indices], 1:max_rating)

    (X_batch, Y_batch)
end

function make_batches(X, Y; batch_size :: Integer, max_rating :: Integer = 10)
    (
        indices -> make_batch(X, Y; indices = indices, max_rating = max_rating)
    ).(
        partition(1:length(X), batch_size)
    )
end

function make_all_batch(X, Y; max_rating :: Integer = 10, device = cpu)
    X_batch = Array{Float32}(undef, size(X[1])..., length(X))

    for i in 1:length(X)
        X_batch[:, :, :, i] = Float32.(X[i])
    end

    Y_batch = onehotbatch(Y, 1:max_rating)

    (X_batch |> device, Y_batch |> device)
end
