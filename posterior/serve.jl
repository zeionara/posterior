#!/usr/bin/julia

using ArgParse
using Genie
using Flux
using HTTP
using FileIO, Images

using BSON: @load

Genie.config.run_as_server = true

include("utils/file.jl")
include("utils/pipe.jl")

# local_image_path = "/tmp/poster.jpg"
# resized_image = @pipe local_image_path |> load |> imresize(256, 256)

function parse_arguments()
    settings = ArgParseSettings()

    @add_arg_table settings begin
        "--model-path", "-m"
            help = "Trained model path"
            arg_type = String
            default = "assets/model.bson"
        "--width", "-w"
            help = "Normalized image width"
            arg_type = Int
            default = 256
        "--height"
            help = "Normalized image height"
            arg_type = Int
            default = 256
        "--image-path", "-i"
            help = "Path for temporarily storing downloaded images"
            arg_type = String
            default = "/tmp"
        "--cpu", "-c"
            help = "Run model on cpu"
            action = :store_true
        "--port", "-p"
            help = "Port on which to run the server"
            arg_type = Int
            default = 7171
    end

    return parse_args(settings)
end

args = parse_arguments()

device = args["cpu"] ? cpu : gpu

@load args["model-path"] model_at_cpu

model = model_at_cpu |> device

width = args["width"]
height = args["height"]

image_path = joinpath(args["image-path"], "poster")

# function prepare(path :: AbstractString)
#     @pipe path |> load |> imresize(256, 256)
# end

route("/predict", method = POST) do
  message = Genie.Requests.jsonpayload()
  
  url = message["url"]

  extension = get_extension(url)

  local_image_path = "$image_path.$extension"

  if ismissing(extension)
    url |> DomainError |> throw("Cannot find file extension in passed string: $url")
    # (status = "ERROR", value = "Cannot find file extension in passed string: $url") |> Genie.Renderer.Json.json |> return
    # url |> DomainError |> throw("Cannot find file extension in passed string: $url")
  else
    Base.download(url, local_image_path)
  end

  # println("Saved image at $url as $local_image_path")

  # resized_image = @pipe local_image_path |> load |> imresize(width, height)
  # print("foo")
  # println(local_image_path)
  # print("bar")

  features = @pipe local_image_path |> load |> imresize(width, height) |> channelview |> permutedims((2, 3, 1))

  # features = permutedims(imresize(local_image_path |> load, width, height) |> channelview, (2, 3, 1))
  # features = permutedims(resized_image |> channelview, (2, 3, 1))

  # println("Resized")

  # ratings = @pipe features |> reshape((size(features)..., 1)) |> model |> cpu |> Flux.onecold
  ratings = @pipe features |> reshape((size(features)..., 1)) |> model |> cpu |> Flux.onecold

  (rating = ratings |> only, ) |> Genie.Renderer.Json.json
  # println(message)
  # "good movie"
end

args["port"] |> up
