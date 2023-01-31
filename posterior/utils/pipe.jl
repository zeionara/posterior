#!/usr/bin/julia

function foo(arg :: AbstractString)
    "foo $arg"
end

# using DataFrames
# using CSV

# function foo(arg :: AbstractString)
#     ["foo", "$arg"]
# end

function foo(arg :: AbstractString, arg2 :: AbstractString)
    "foo $arg $arg2"
end

function _pipe(expr :: Expr)
    pipe_operator = expr.args[1]

    # println("-----------")
    # Meta.show_sexpr(expr)
    # println()

    # @assert pipe_operator  == :|> "invalid pipe expression: expected pipe operator instead of '$pipe_operator'"
    if pipe_operator  != :|>
        # println("not pipe operator")
        return expr
    end
    # println("pipe operator")

    piped_argument = expr.args[2]
    piped_function = expr.args[3]

    # print(typeof(piped_function))

    post_processed_piped_argument = piped_argument |> _pipe

    # println("======")

    # println("hmm...")

    if typeof(piped_function) == Expr && piped_function.head == :do
        # println("DO!!!")
        insert!(piped_function.args[1].args, 2, post_processed_piped_argument)
        # Meta.show_sexpr(expr)
        # println()
        # expr
        piped_function
    elseif typeof(piped_function) == Symbol || piped_function.head == :.
        # Meta.show_sexpr(expr)
        # println(" is a SYMBOL!!!")
        # Meta.show_sexpr(post_processed_piped_argument)
        :($piped_function($post_processed_piped_argument))
    elseif typeof(piped_function) == Expr && piped_function.head == :call
        # println("PIPED FUNC!!!")
        args = piped_function.args
        if :_ in args 
            # println(args)
            # println(piped_function)
            # Meta.show_sexpr(piped_function)
            # println()
            for i in 1:length(args)
                if args[i] == :_
                    args[i] = post_processed_piped_argument
                else
                    # println(args[i])
                    args[i] = esc(args[i])
                end
            end
            # args[args .== :_] .= post_processed_piped_argument
        else
            for i in 1:length(args)
                # println(args[i])
                args[i] = esc(args[i])
            end
            insert!(piped_function.args, 2, post_processed_piped_argument)
        end
        piped_function
    elseif typeof(piped_function) == Expr && piped_function.head == :tuple
        # println("TUPLE!!!!!!")
        result = :($post_processed_piped_argument[$piped_function...])
        # Meta.show_sexpr(result)
        # println()
        result
    else
        # println("REST!!!")
        :($post_processed_piped_argument[$piped_function])
    end

    # return piped_function
end

function _pipe(value)
    value |> esc
end

macro pipe(expr :: Expr, verbose :: Bool = false)
    result = expr |> _pipe
    if verbose
        Meta.show_sexpr(result)
    end
    result
end

# macro _pipe(expr :: Expr)
#     Meta.show_sexpr(expr)
#     expr
# end
# 
# bar = "bar"
# baz = @pipe bar |> foo |> foo("qux") |> foo("quux")
# println(baz)

# qux = "qux"
# foo(qux) |> println
# "foo(qux)" |> Meta.parse |> eval |> println

# function tmp()
#     bar = "bar"
#     # foo(bar) |> println
#     # "foo(bar)" |> Meta.parse |> eval |> println
#     # :(foo(bar)) |> eval |> println
#     # Meta.show_sexpr(ex)
#     # @_pipe foo(bar)
#     # @_pipe foo(bar)
#     # baz = @pipe bar |> foo |> foo("qux") |> foo("quux")
#     baz = @pipe bar |> foo(bar)
#     baz
# end
# baz = @pipe "bar" |> foo("qux")
# baz = @pipe "bar" |> foo() |> (2, 1)
# df = DataFrame(foo = [1, 2], bar = [17, 19])
# bar = @pipe "foo" |> CSV.File

# baz = @pipe df |> (:, [:bar])
# 
# println(tmp())

# baz = @pipe "bar" |> foo |> map() do x x * "_" end
# println(baz)
