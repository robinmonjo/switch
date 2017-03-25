use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :switch, Switch.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :switch, Switch.Repo,
  adapter: Mongo.Ecto,
  database: "switch_test",
  pool_size: 1

config :switch, Switch,
  hostname: "www.example.com"

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
