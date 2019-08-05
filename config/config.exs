# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :liveview_todos,
  ecto_repos: [LiveviewTodos.Repo]

# Configures the endpoint
config :liveview_todos, LiveviewTodosWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Z9xouQmjBTHPd2TbIDQOmoOotfsRifdXlLgEM0VeVyMmY21KaRmfHbwP7S0Lh9Pc",
  render_errors: [view: LiveviewTodosWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveviewTodos.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Gd33A0dPWg3DkTgQSDBBjh7pseENdHuk"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
