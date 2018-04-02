defmodule CustomStruct do
  defstruct [:foo, :bar]
end

defimpl Ecto.LoggerJSON.StructParser, for: CustomStruct do
  def parse(value) do
    Map.take(value, ~w(foo bar)a)
  end
end
