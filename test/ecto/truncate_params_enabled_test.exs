defmodule Ecto.TruncateParamsEnabledTest do
  use ExUnit.Case, async: false

  alias CustomStruct
  import ExUnit.CaptureIO
  require Logger

  defp get_log(func) do
    capture_io(:user, fn ->
      Process.put(:get_log, func.())
      Logger.flush()
    end)
    |> String.replace("\e[36m", "")
    |> String.replace("\e[22m", "")
    |> String.replace("\n\e[0m", "")
    |> Poison.decode!()
  end

  test "truncate params enabled" do
    Application.put_env(:ecto_logger_json, :truncate_params, true)

    entry = %{
      query_time: nil,
      decode_time: nil,
      queue_time: nil,
      query:
        "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\" FROM \"last_processed_reactions\"",
      params: [String.duplicate("Long Value", 100)]
    }

    log = get_log(fn -> Ecto.LoggerJSON.log(entry, :info) end)

    assert [truncated_value] = log["params"]
    assert String.length(truncated_value) == 100
  end
end
