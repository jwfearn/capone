defmodule Quandl.Price do
  @moduledoc """
  Utilties for working with Quandl JSON stock price data.
  See: https://www.quandl.com/databases/WIKIP
  """

  @columns ~w[close date high low open ticker volume]a
  @enforce_keys @columns
  defstruct @columns

  def columns(), do: @columns

  def list_from_map(%{"datatable" => %{"data" => rows, "columns" => schemas}}) do
    rows
    |> Enum.map(&new(&1, schemas))
  end

  # Values order must match schemas order. Schemas order unspecified.
  def new(values, schemas) do
    fields =
      schemas
      |> Enum.zip(values)
      |> Enum.map(&transform/1)

    struct(__MODULE__, fields)
  end

  # Useful for testing
  def new(fields), do: struct(__MODULE__, fields |> Enum.map(&default_transform/1))

  def month_str(%__MODULE__{date: date}), do: date |> Date.to_iso8601() |> String.slice(0..6)

  def gain(%__MODULE__{open: buy, close: sell}), do: sell - buy

  def spread(%__MODULE__{high: high, low: low}), do: high - low

  defp transform({%{"name" => column_str, "type" => type}, value}) do
    {String.to_existing_atom(column_str), value |> from_type(type)}
  end

  defp from_type(value, "BigDecimal" <> format) do
    [_, precision, scale] = Regex.run(~r/\((\d*),(\d*)\)/, format)

    value
    |> from_big_decimal(precision: Integer.parse(precision), scale: Integer.parse(scale))
  end

  defp from_type(value, "Date"), do: value |> Date.from_iso8601!()
  defp from_type(value, _), do: value

  # TODO: use options
  defp from_big_decimal(value, precision: _, scale: _), do: 1.0 * value

  # Used only by new/1
  defp default_transform({column, value}), do: {column, value |> from_column(column)}
  defp from_column(value, :date), do: value
  defp from_column(value, :ticker), do: value
  defp from_column(value, :volume), do: from_type(value, "BigDecimal(37,15)")
  defp from_column(value, _), do: from_type(value, "BigDecimal(34,12)")
end
