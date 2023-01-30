#!/usr/bin/julia

using Genie

Genie.config.run_as_server = true

route("/predict", method = POST) do
  message = Genie.Requests.jsonpayload()
  println(message)
  "good movie"
end

up(7171)
