defmodule Capone.Stats do
  @moduledoc false
  alias Quandl.Price
  alias Capone.Stats.{Day, Month, Security}
  require Protocol

  defstruct biggest_loser: nil,
            busy_days: [],
            max_spread_days: [],
            months: %{},
            # TODO: make this a map for direct access to securities by ticker
            securities: []

  # TODO: Clarify: exceeds 10% of a: monthly avg vol or b) avg vol over full date range?
  @type t :: %__MODULE__{}

  Protocol.derive(Jason.Encoder, __MODULE__)
  Protocol.derive(Jason.Encoder, Day)
  Protocol.derive(Jason.Encoder, Month)
  Protocol.derive(Jason.Encoder, Security)

  @default_busy_factor 1.1

  def from_prices(prices) do
    prices_by_ticker =
      prices
      |> Enum.group_by(& &1.ticker)

    securities_by_ticker =
      prices_by_ticker
      |> Enum.map(&aggregate_ticker/1)
      |> Enum.into(%{})

    biggest_loser_security =
      securities_by_ticker
      |> Map.values()
      |> Enum.max_by(& &1.losing_days_count)

    busy_days =
      prices
      |> Day.list_from_prices(&busy?(&1, securities_by_ticker, @default_busy_factor))

    max_spread_days =
      prices
      |> Day.list_from_prices(&max_spread?(&1, securities_by_ticker))
      |> Enum.uniq_by(& &1.ticker)

    months_by_ticker =
      prices
      |> Enum.group_by(& &1.ticker)
      |> Enum.map(&aggregate_months/1)
      |> Enum.into(%{})

    securities =
      securities_by_ticker
      |> Map.values()
      |> Enum.sort_by(& &1.ticker)

    %__MODULE__{
      biggest_loser: biggest_loser_security,
      busy_days: busy_days,
      max_spread_days: max_spread_days,
      months: months_by_ticker,
      securities: securities
    }
  end

  def security(%__MODULE__{} = stats, ticker) do
    stats.securities |> Enum.find(&(&1.ticker == ticker))
  end

  #  def to_json_str(%__MODULE__{} = stats) do
  #    stats
  #    |> Map.from_struct()
  #    |> Jason.encode!(maps: :strict, escape: :html_safe)
  #  end
  #
  defp busy?(%Price{volume: volume, ticker: ticker}, %{} = securities_by_ticker, busy_factor) do
    avg_volume =
      securities_by_ticker
      |> Map.get(ticker)
      |> Security.avg_volume()

    volume > avg_volume * busy_factor
  end

  defp max_spread?(%Price{ticker: ticker} = price, %{} = securities_by_ticker) do
    Price.spread(price) == Map.get(securities_by_ticker, ticker).max_spread
  end

  defp aggregate_months({month_str, ticker_prices}) do
    months =
      ticker_prices
      |> Enum.group_by(&Price.month_str/1)
      |> Map.values()
      |> Enum.map(&Month.from_prices/1)

    {month_str, months}
  end

  defp aggregate_ticker({ticker, ticker_prices}) do
    {ticker, Security.from_prices(ticker_prices)}
  end
end
