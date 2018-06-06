defmodule Capone.Stats.Day do
  alias Quandl.Price

  @enforce_keys ~w[date spread ticker volume]a
  defstruct date: nil,
            spread: 0,
            ticker: nil,
            volume: 0

  @type t :: %__MODULE__{}

  def list_from_prices([%Price{} | _] = prices, filter_fun \\ &pass/1) do
    prices
    |> Enum.reduce([], &accumulate(&2, &1, filter_fun))
    |> Enum.sort_by(& &1.date)
  end

  defp accumulate(acc, price, filter_fun) when is_function(filter_fun) do
    accumulate(acc, price, filter_fun.(price))
  end

  defp accumulate(acc, _, false), do: acc

  defp accumulate(acc, %Price{date: date, ticker: ticker, volume: volume} = price, true) do
    [%__MODULE__{date: date, spread: Price.spread(price), ticker: ticker, volume: volume} | acc]
  end

  defp pass(_price), do: true
end
