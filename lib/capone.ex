defmodule Capone do
  @moduledoc false
  alias Quandl.Client
  alias Capone.Stats
  alias Capone.Stats.{Month, Security}

  @default_tickers ~w[COF GOOGL MSFT]
  @default_date_range Date.range(~D[2017-01-01], ~D[2017-06-30])
  @default_precision 4

  def challenge(date_range \\ @default_date_range, tickers \\ @default_tickers, opts) do
    Client.new()
    |> Client.prices(tickers, date_range)
    |> Stats.from_prices()
    |> report(opts)
  end

  defp report(stats, opts \\ []) do
    opts =
      Keyword.merge(
        [
          show_biggest_loser: false,
          show_busy_days: false,
          show_max_spread_days: false,
          precision: 4
        ],
        opts
      )

    map =
      stats.months
      |> Enum.reduce(%{}, fn {ticker, _} = pair, acc ->
        acc |> Map.put(ticker, months_list(pair, opts))
      end)

    map =
      if opts[:show_biggest_loser] do
        map |> Map.put("biggest_loser", loser_row(stats.biggest_loser, opts))
      else
        map
      end

    map =
      if opts[:show_busy_days] do
        map |> Map.put("busy_days", busy_list(stats, opts))
      else
        map
      end

    map =
      if opts[:show_max_spread_days] do
        map |> Map.put("maximum_spread_days", spread_list(stats, opts))
      else
        map
      end

    map |> Jason.encode!(maps: :strict, escape: :html_safe)
  end

  defp months_list({_, months}, opts), do: months |> months_list(opts)
  defp months_list(months, opts), do: months |> Enum.map(&month_row(&1, opts))
  defp busy_list(stats, opts), do: stats.busy_days |> Enum.map(&busy_row(&1, stats, opts))
  defp spread_list(stats, opts), do: stats.max_spread_days |> Enum.map(&spread_row(&1, opts))

  defp month_row(month, opts) do
    row =
      %{}
      |> put_string_as("month", month.month_str, opts)
      |> put_float_as("average_open", Month.avg_open(month), opts)
      |> put_float_as("average_close", Month.avg_close(month), opts)

    if opts[:show_busy_days] do
      row |> put_float_as("average_volume", Month.avg_volume(month), opts)
    else
      row
    end
  end

  defp loser_row(security, opts) do
    %{}
    |> put_string_as("ticker", security.ticker, opts)
    |> put_count_as("losing_days_count", security.losing_days_count, opts)
  end

  defp busy_row(day, stats, opts) do
    ticker = day.ticker
    volume = day.volume

    avg_volume =
      stats
      |> Stats.security(ticker)
      |> Security.avg_volume()

    pct = 100.0 * volume / avg_volume

    %{}
    |> put_date_as("date", day.date, opts)
    |> put_string_as("ticker", ticker, opts)
    |> put_float_as("volume", volume, opts)
    |> put_float_as("percent_of_average_volume", pct, Keyword.merge(opts, precision: 0))
    |> put_float_as("average_volume", avg_volume, opts)
  end

  defp spread_row(day, opts) do
    %{}
    |> put_string_as("ticker", day.ticker, opts)
    |> put_date_as("date", day.date, opts)
    |> put_float_as("spread", day.spread, opts)
  end

  defp put_string_as(map, k, v, _) when is_binary(v), do: map |> Map.put(k, v)
  defp put_count_as(map, k, v, _) when is_integer(v), do: map |> Map.put(k, v)
  defp put_date_as(map, k, %Date{} = v, _), do: map |> Map.put(k, Date.to_iso8601(v))

  defp put_float_as(map, k, v, opts) when is_float(v) do
    precision = Keyword.get(opts, :precision, @default_precision)
    map |> Map.put(k, Float.round(v, precision))
  end
end
