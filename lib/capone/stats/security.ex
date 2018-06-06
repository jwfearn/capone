defmodule Capone.Stats.Security do
  alias Quandl.Price

  @enforce_keys ~w[ticker]a
  defstruct count: 0,
            losing_days_count: 0,
            max_spread: 0.0,
            sum_volume: 0.0,
            ticker: nil

  @type t :: %__MODULE__{}

  def from_price(%Price{ticker: ticker}), do: %__MODULE__{ticker: ticker}

  def from_prices([%Price{} = price | _] = ticker_prices) do
    ticker_prices
    |> Enum.reduce(from_price(price), &accumulate(&2, &1))
  end

  def count(%__MODULE__{count: count}), do: count

  def avg_volume(%__MODULE__{count: count, sum_volume: sum_volume}) do
    sum_volume / count
  end

  defp accumulate(%__MODULE__{ticker: ticker} = acc, %Price{} = price) do
    # raise unless tickers match
    %Price{ticker: ^ticker} = price

    %__MODULE__{acc | count: acc.count + 1, sum_volume: acc.sum_volume + price.volume}
    |> update_loser_count(Price.gain(price))
    |> update_max_spread(Price.spread(price))
  end

  defp update_loser_count(%__MODULE__{} = security, gain) do
    if gain < 0 do
      %__MODULE__{security | losing_days_count: security.losing_days_count + 1}
    else
      security
    end
  end

  defp update_max_spread(%__MODULE__{max_spread: max_spread} = security, spread) do
    if :spread > max_spread do
      %__MODULE__{security | max_spread: spread}
    else
      security
    end
  end
end
