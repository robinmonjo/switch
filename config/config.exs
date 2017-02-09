# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :switch,
  ecto_repos: [Switch.Repo]

# Configures the endpoint
config :switch, Switch.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wDxzc+ONojGTJTTBGzi8B4ZYocaTeimYaezVRKnwV4m75nOOQHJiFM9fAsYRYqIR",
  render_errors: [view: Switch.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Switch.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  binary_id: true,
  migration: false,
  sample_binary_id: "111111111111111111111111"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
