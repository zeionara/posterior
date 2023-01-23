#!/usr/bin/julia

# macro sayhello(name)
#     expr = :( println("Hello, $($name)") )
#     Meta.show_sexpr(expr)
#     println()
#     expr
# end
# 
# @sayhello "dima"

function foo(arg :: AbstractString)
    # println("foo has got $arg")
    "foo $arg"
end

function pipe(expr :: Expr)
    # expr = :( println("Hello, $($name)") )
    # Meta.show_sexpr(expr)
    # println()

    pipe_operator = expr.args[1]

    @assert pipe_operator  == :|> "invalid pipe expression: expected pipe operator instead of '$pipe_operator'"

    piped_argument = expr.args[2]
    piped_function = expr.args[3]

    insert!(piped_function.args, 2, piped_argument |> pipe)

    # println(expr)

    # println("Finished piped macro")
    # baz = @pipe "bar" |> foo() # |> foo()
    # println(baz)

    return piped_function
    # expr
end

function pipe(value)
    value
end

macro pipe(expr :: Expr)
    return expr |> pipe
end

# @pipe "bar" |> foo()
baz = @pipe "bar" |> foo() |> foo()

println(baz)
