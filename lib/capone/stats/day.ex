defmodule Capone.Stats.Day do
  alias Quandl.Price

  @enforce_keys [:date, :ticker, :volume]
  defstruct date: nil,
            ticker: nil,
            volume: 0

  @type t :: %__MODULE__{}

  def list_from_prices([%Price{} | _] = prices, filter_fun \\ &pass/1) do
    prices
    |> Enum.reduce([], &accumulate(&2, &1, filter_fun))
    |> Enum.reverse()
  end

  defp accumulate(acc, price, filter_fun) when is_function(filter_fun) do
    accumulate(acc, price, filter_fun.(price))
  end

  defp accumulate(acc, price, false), do: acc

  defp accumulate(acc, %Price{date: date, ticker: ticker, volume: volume}, true) do
    [%__MODULE__{date: date, ticker: ticker, volume: volume} | acc]
  end

  defp pass(_price), do: true
end
