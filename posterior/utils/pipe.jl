#!/usr/bin/julia

function foo(arg :: AbstractString)
    "foo $arg"
end

function foo(arg :: AbstractString, arg2 :: AbstractString)
    "foo $arg $arg2"
end

function _pipe(expr :: Expr)
    pipe_operator = expr.args[1]

    @assert pipe_operator  == :|> "invalid pipe expression: expected pipe operator instead of '$pipe_operator'"

    piped_argument = expr.args[2]
    piped_function = expr.args[3]

    post_processed_piped_argument = piped_argument |> _pipe

    if typeof(piped_function) == Symbol 
        println(post_processed_piped_argument)
        # return (:call, piped_function, post_processed_piped_argument)
        return :($piped_function($post_processed_piped_argument))
    end

    insert!(piped_function.args, 2, post_processed_piped_argument)

    Meta.show_sexpr(piped_function)
    println(piped_function)

    return piped_function
end

function _pipe(value)
    value
end

macro pipe(expr :: Expr)
    return expr |> _pipe
end

# @pipe "bar" |> foo()
baz = @pipe "bar" |> foo |> foo("qux") |> foo("quux")

println(baz)
