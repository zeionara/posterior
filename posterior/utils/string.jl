struct string_to_number{T} end

function string_to_number{T}(value :: Union{String, Missing}) :: Union{T, Missing} where T
    if value === missing 
        return value
    end
    parse(T, value)
end
