#!/usr/bin/julia

using ArgParse
using Genie
using Flux

using BSON: @load

Genie.config.run_as_server = true

function parse_arguments()
    settings = ArgParseSettings()

    @add_arg_table settings begin
        "--model-path", "-m"
            help = "Trained model path"
            arg_type = String
            default = "assets/model.bson"
        "--cpu", "-c"
            help = "Run model on cpu"
            action = :store_true
    end

    return parse_args(settings)
end

args = parse_arguments()

# println(args["model-path"])
device = args["cpu"] ? cpu : gpu

@load args["model-path"] model_at_cpu

model = model_at_cpu |> device

route("/predict", method = POST) do
  message = Genie.Requests.jsonpayload()
  println(message)
  "good movie"
end

up(7171)
