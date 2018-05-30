defmodule Quandl.Price do
  @moduledoc false

  defstruct ~w[ticker date open close volume]a

  # Values order must match schemas order. Schemas order unspecified.
  def new(values, schemas) do
    values
    |> Enum.zip(schemas)
    |> Enum.reduce(%__MODULE__{}, &merge(&1, &2))
  end

  def new_list(%{"datatable" => %{"data" => rows, "columns" => schemas}}) do
    rows
    |> Enum.map(&new(&1, schemas))
  end

  defp merge({value, %{"name" => key}}, %__MODULE__{} = price), do: merge(price, key, value)

  # Atoms are not garbage collected, pattern match to avoid creating runtime atoms
  defp merge(%__MODULE__{} = price, "ticker", value), do: %{price | ticker: value}
  defp merge(%__MODULE__{} = price, "open", value), do: %{price | open: value}
  defp merge(%__MODULE__{} = price, "close", value), do: %{price | close: value}
  defp merge(%__MODULE__{} = price, "volume", value), do: %{price | volume: value}
  defp merge(%__MODULE__{} = price, "date", value), do: %{price | date: Date.from_iso8601!(value)}
end
