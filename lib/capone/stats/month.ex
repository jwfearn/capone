defmodule Capone.Stats.Month do
  alias Quandl.Price

  @enforce_keys ~w[month_str ticker]a
  defstruct count: 0,
            month_str: nil,
            sum_close: 0,
            sum_open: 0,
            sum_volume: 0,
            ticker: nil

  @type t :: %__MODULE__{}

  def from_price(%Price{} = price) do
    %__MODULE__{
      month_str: Price.month_str(price),
      ticker: price.ticker
    }
  end

  def from_prices([%Price{} = price | _] = prices) do
    prices
    |> Enum.reduce(from_price(price), &accumulate(&2, &1))
  end

  defp accumulate(%__MODULE__{} = acc, %Price{} = price) do
    #    ^acc.month_str = Price.month_str(price) # raise unless months match
    #    ^acc.ticker = Price.ticker(price) # raise unless tickers match

    %__MODULE__{
      acc
      | count: acc.count + 1,
        sum_close: acc.sum_close + price.close,
        sum_open: acc.sum_open + price.open,
        sum_volume: acc.sum_volume + price.volume
    }
  end

  def avg_close(%__MODULE__{count: count, sum_close: sum_close}), do: sum_close / count
  def avg_open(%__MODULE__{count: count, sum_open: sum_open}), do: sum_open / count
  def avg_volume(%__MODULE__{count: count, sum_volume: sum_volume}), do: sum_volume / count
  def count(%__MODULE__{count: count}), do: count
end
