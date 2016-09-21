# EctoLoggerJson

Log ecto data as JSON with slightly different fields

## Dependencies
  * Poison

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ecto_logger_json` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ecto_logger_json, "~> 0.1.0"}]
    end
    ```

  2. Ensure `ecto_logger_json` is started before your application:

    ```elixir
    def application do
      [applications: [:ecto_logger_json]]
    end
    ```

  3. Configure ecto logging in `config/enviroment_name.exs`

    ```elixir
    config :my_app, MyApp.Repo,
    adapter: Ecto.Adapters.Postgres,
    ...
    loggers: [{Ecto.LoggerJSON, :log, [:info]}] 
    ```

### Additonal Setup depending on your use case
  * Configure the logger (console)
    * Add to your `config/config.exs` or `config/env_name.exs`:

            config :logger, :console,
              format: "$message\n",
              level: :info,
              metadata: [:request_id]

  * Configure the logger (file)
    * Add `{:logger_file_backend, "~> 0.0.7"}` to your mix.exs
    * Run `mix deps.get`
    * Add to your `config/config.exs` or `config/env_name.exs`:

            config :logger, format: "$message\n", backends: [{LoggerFileBackend, :log_file}, :console]

            config :logger, :log_file,
              format: "$message\n",
              level: :info,
              metadata: [:request_id],
              path: "log/my_pipeline.log"
