defmodule Capone.Stats.Day do
  alias Quandl.Price

  @enforce_keys ~w[date spread ticker volume]a
  defstruct date: nil,
            spread: 0.0,
            ticker: nil,
            volume: 0.0

  @type t :: %__MODULE__{}

  def from_price(%Price{} = price) do
    %__MODULE__{
      date: price.date,
      spread: Price.spread(price),
      ticker: price.ticker,
      volume: price.volume
    }
  end

  def list_from_prices([%Price{} | _] = prices, filter_fun \\ &pass/1) do
    prices
    |> Enum.reduce([], &accumulate(&2, &1, filter_fun))
    |> Enum.sort_by(& &1.date)
  end

  defp accumulate(acc, price, filter_fun) when is_function(filter_fun) do
    accumulate(acc, price, filter_fun.(price))
  end

  defp accumulate(acc, _, false), do: acc
  defp accumulate(acc, %Price{} = price, true), do: [from_price(price) | acc]

  defp pass(_), do: true
end
