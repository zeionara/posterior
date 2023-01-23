#!/usr/bin/julia

# function foo(arg :: AbstractString)
#     "foo $arg"
# end

# using DataFrames
# using CSV

function foo(arg :: AbstractString)
    ["foo", "$arg"]
end

function foo(arg :: AbstractString, arg2 :: AbstractString)
    "foo $arg $arg2"
end

function _pipe(expr :: Expr)
    pipe_operator = expr.args[1]

    # Meta.show_sexpr(expr)
    # println()

    @assert pipe_operator  == :|> "invalid pipe expression: expected pipe operator instead of '$pipe_operator'"

    piped_argument = expr.args[2]
    piped_function = expr.args[3]

    # print(typeof(piped_function))

    post_processed_piped_argument = piped_argument |> _pipe

    if typeof(piped_function) == Symbol || piped_function.head == :.
        :($piped_function($post_processed_piped_argument))
    elseif typeof(piped_function) == Expr && piped_function.head == :call
        insert!(piped_function.args, 2, post_processed_piped_argument)
        piped_function
    elseif typeof(piped_function) == Expr && piped_function.head == :tuple
        :($post_processed_piped_argument[$piped_function...])
    else
        :($post_processed_piped_argument[$piped_function])
    end

    # return piped_function
end

function _pipe(value)
    value
end

macro pipe(expr :: Expr)
    return expr |> _pipe
end

# baz = @pipe "bar" |> foo |> foo("qux") |> foo("quux")
# baz = @pipe "bar" |> foo() |> (2, 1)
# df = DataFrame(foo = [1, 2], bar = [17, 19])
# bar = @pipe "foo" |> CSV.File

# baz = @pipe df |> (:, [:bar])
# 
# println(baz)
