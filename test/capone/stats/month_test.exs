defmodule Capone.Stats.MonthTest do
  @moduledoc false
  use ExUnit.Case
  alias Capone.Stats.{Month}
  alias Quandl.Price
  doctest Month

  setup_all do
    [
      prices: [
        %Price{
          ticker: "F",
          date: ~D[2017-01-03],
          open: 90,
          high: 110,
          low: 80,
          close: 100,
          volume: 1_500
        },
        %Price{
          ticker: "F",
          date: ~D[2017-01-04],
          open: 100,
          high: 120,
          low: 90,
          close: 110,
          volume: 500
        }
      ]
    ]
  end

  test "from_prices", context do
    context.prices
    |> Month.from_prices()
    |> assert_month(2, "F", "2017-01", 95, 105, 1_000)
  end

  defp assert_month(
         %Month{} = month,
         count,
         ticker,
         month_str,
         avg_open,
         avg_close,
         avg_volume
       ) do
    assert month.count == count
    assert month.ticker == ticker
    assert month.month_str == month_str
    assert Month.avg_open(month) == avg_open
    assert Month.avg_close(month) == avg_close
    assert Month.avg_volume(month) == avg_volume
    assert month.sum_open == avg_open * count
    assert month.sum_close == avg_close * count
    assert month.sum_volume == avg_volume * count
    month
  end
end
