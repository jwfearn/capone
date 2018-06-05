defmodule Capone.Stats.Security do
  alias Quandl.Price

  @enforce_keys [:ticker]
  defstruct count: 0,
            loser_count: 0,
            max_spread: 0,
            sum_volume: 0,
            ticker: nil

  @type t :: %__MODULE__{}

  def from_price(%Price{ticker: ticker}), do: %__MODULE__{ticker: ticker}

  def from_prices([%Price{} = price | _] = ticker_prices) do
    ticker_prices
    |> Enum.reduce(from_price(price), &accumulate(&2, &1))
  end

  def count(%__MODULE__{count: count}), do: count
  def avg_volume(%__MODULE__{count: count, sum_volume: sum_volume}), do: sum_volume / count

  defp accumulate(%__MODULE__{ticker: ticker} = acc, %Price{} = price) do
    # raise unless tickers match
    %Price{ticker: ^ticker} = price

    %__MODULE__{acc | count: acc.count + 1, sum_volume: acc.sum_volume + price.volume}
    |> update_loser_count(Price.gain(price))
    |> update_max_spread(Price.spread(price))
  end

  defp update_loser_count(%__MODULE__{} = ticker, gain) when gain < 0 do
    %__MODULE__{ticker | loser_count: ticker.loser_count + 1}
  end

  defp update_loser_count(%__MODULE__{} = ticker, _), do: ticker

  defp update_max_spread(%__MODULE__{max_spread: max_spread} = ticker, spread)
       when spread > max_spread do
    %__MODULE__{ticker | max_spread: spread}
  end

  defp update_max_spread(%__MODULE__{} = ticker, _), do: ticker
end
