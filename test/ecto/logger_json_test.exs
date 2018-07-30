defmodule Ecto.LoggerJSONTest do
  use ExUnit.Case

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

  describe "&log/1" do
    test "correct output - non nil times and request id" do
      Logger.metadata(request_id: "fake_request_id")

      entry = %{
        query_time: 100_000,
        decode_time: 10_000,
        queue_time: 20_000,
        query:
          "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\", l0.\"info\" FROM \"last_processed_reactions\" WHERE l0.\"info\" <@ $1",
        params: [%{"foo" => "bar"}, %CustomStruct{foo: 1, bar: 2}]
      }

      log = get_log(fn -> Ecto.LoggerJSON.log(entry) end)

      assert log["decode_time"] == 0.01
      assert log["duration"] == 0.13
      assert log["log_type"] == "persistence"

      assert log["query"] ==
               "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\", l0.\"info\" FROM \"last_processed_reactions\" WHERE l0.\"info\" <@ $1"

      assert log["query_time"] == 0.1
      assert log["queue_time"] == 0.02
      assert log["request_id"] == "fake_request_id"
      assert log["params"] == ["%{\"foo\" => \"bar\"}", %{"bar" => 2, "foo" => 1}]
    end

    test "correct output - nil times" do
      entry = %{
        query_time: nil,
        decode_time: nil,
        queue_time: nil,
        query:
          "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\" FROM \"last_processed_reactions\"",
        params: []
      }

      log = get_log(fn -> Ecto.LoggerJSON.log(entry) end)

      assert log["decode_time"] == 0
      assert log["duration"] == 0
      assert log["log_type"] == "persistence"

      assert log["query"] ==
               "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\" FROM \"last_processed_reactions\""

      assert log["query_time"] == 0
      assert log["queue_time"] == 0
      assert log["request_id"] == nil
    end
  end

  describe "&log/2" do
    test "correct output - non nil times and request id" do
      Logger.metadata(request_id: "fake_request_id")

      entry = %{
        query_time: 100_000,
        decode_time: 10_000,
        queue_time: 20_000,
        query:
          "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\", l0.\"info\" FROM \"last_processed_reactions\" WHERE l0.\"info\" <@ $1",
        params: [%{"foo" => "bar"}, %CustomStruct{foo: 1, bar: 2}]
      }

      log = get_log(fn -> Ecto.LoggerJSON.log(entry, :info) end)

      assert log["decode_time"] == 0.01
      assert log["duration"] == 0.13
      assert log["log_type"] == "persistence"

      assert log["query"] ==
               "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\", l0.\"info\" FROM \"last_processed_reactions\" WHERE l0.\"info\" <@ $1"

      assert log["query_time"] == 0.1
      assert log["queue_time"] == 0.02
      assert log["request_id"] == "fake_request_id"
      assert log["params"] == ["%{\"foo\" => \"bar\"}", %{"bar" => 2, "foo" => 1}]
    end

    test "correct output - nil times" do
      entry = %{
        query_time: nil,
        decode_time: nil,
        queue_time: nil,
        query:
          "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\" FROM \"last_processed_reactions\"",
        params: []
      }

      log = get_log(fn -> Ecto.LoggerJSON.log(entry, :info) end)

      assert log["decode_time"] == 0
      assert log["duration"] == 0
      assert log["log_type"] == "persistence"

      assert log["query"] ==
               "SELECT l0.\"id\", l0.\"reaction_id\", l0.\"inserted_at\", l0.\"updated_at\" FROM \"last_processed_reactions\""

      assert log["query_time"] == 0
      assert log["queue_time"] == 0
      assert log["request_id"] == nil
    end

    test "truncate disabled on long strings" do
      long_string = String.duplicate("Long Value", 100)
      entry = %{params: [long_string]}
      log = get_log(fn -> Ecto.LoggerJSON.log(entry, :info) end)

      assert [value] = log["params"]
      assert String.length(value) == String.length(long_string)
    end

    test "truncate enabled on long strings" do
      Application.put_env(:ecto_logger_json, :truncate_strings, true)
      entry = %{params: [String.duplicate("Long Value", 100)]}
      log = get_log(fn -> Ecto.LoggerJSON.log(entry, :info) end)

      assert [truncated_value] = log["params"]
      assert String.length(truncated_value) == 100
    end
  end
end
