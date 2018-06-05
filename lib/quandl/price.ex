defmodule Quandl.Price do
  @moduledoc """
  A module for converting JSON stock price data from Quandl into structs.
  See: https://www.quandl.com/databases/WIKIP
  """

  # Use this table to avoid creating runtime (non-garbage-collected) atoms.
  @column_atoms_by_str %{
    "close" => :close,
    "date" => :date,
    "high" => :high,
    "low" => :low,
    "open" => :open,
    "ticker" => :ticker,
    "volume" => :volume
  }

  @column_strs Map.keys(@column_atoms_by_str)

  @enforce_keys Map.values(@column_atoms_by_str)
  defstruct Map.values(@column_atoms_by_str)

  def column_atom(column_str), do: Map.get(@column_atoms_by_str, column_str)

  def column_strs(), do: @column_strs

  def list_from_json_map(%{"datatable" => %{"data" => rows, "columns" => schemas}}) do
    rows |> Enum.map(&new(&1, schemas))
  end

  # Values order must match schemas order. Schemas order unspecified.
  def new(values, schemas) do
    fields = schemas |> Enum.zip(values) |> Enum.map(&pair/1)
    struct(__MODULE__, fields)
  end

  def month_str(%__MODULE__{date: date}), do: date |> Date.to_iso8601() |> String.slice(0..6)

  def gain(%__MODULE__{open: buy, close: sell}), do: sell - buy

  def spread(%__MODULE__{high: high, low: low}), do: high - low

  defp pair({%{"name" => column_str}, value}) do
    column_atom = Map.get(@column_atoms_by_str, column_str)
    {column_atom, value |> transform(column_atom)}
  end

  defp transform(value, :date), do: value |> Date.from_iso8601!()
  defp transform(value, _), do: value
end
