defmodule Quandl.Price do
  @moduledoc """
  Utilties for working with Quandl JSON stock price data.
  See: https://www.quandl.com/databases/WIKIP
  """

  @columns ~w[close date high low open ticker volume]a
  @enforce_keys @columns
  defstruct @columns

  def columns(), do: @columns

  def list_from_json_map(%{"datatable" => %{"data" => rows, "columns" => schemas}}) do
    rows |> Enum.map(&new(&1, schemas))
  end

  # Values order must match schemas order. Schemas order unspecified.
  def new(values, schemas) do
    fields = schemas |> Enum.zip(values) |> Enum.map(&pair/1)
    struct(__MODULE__, fields)
  end

  def month_str(%__MODULE__{date: date}), do: date |> Date.to_iso8601() |> String.slice(0..6)

  def gain(%__MODULE__{open: buy, close: sell}), do: Float.round(1.0 * sell - buy, 12)

  def spread(%__MODULE__{high: high, low: low}), do: Float.round(1.0 * high - low, 12)

  defp pair({%{"name" => column_str, "type" => type}, value}) do
    column_atom = String.to_existing_atom(column_str)
    {column_atom, value |> transform(column_atom, type)}
  end

  defp transform(value, _, "Date"), do: value |> Date.from_iso8601!()
  defp transform(value, :volume, "BigDecimal" <> _), do: value
  defp transform(value, _, "BigDecimal" <> _), do: value
  defp transform(value, _, _), do: value
end
