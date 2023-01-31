extension_regexp = r"\.([^.]+)$"

function get_extension(url :: Union{AbstractString, Missing}) :: Union{String, Missing}
    if ismissing(url)
        missing
    else
        matched = match(extension_regexp, url)

        if isnothing(matched)
            missing
        else
            matched[1]
        end
    end
end

