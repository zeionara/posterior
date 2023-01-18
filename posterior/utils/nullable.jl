function nothing_to_missing(value)
    if isnothing(value)
        missing
    else
        value
    end
end
