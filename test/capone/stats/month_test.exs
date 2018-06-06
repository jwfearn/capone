defmodule Capone.Stats.MonthTest do
  @moduledoc false
  use ExUnit.Case
  alias Capone.Stats.{Month}
  alias Quandl.Price
  doctest Month

  setup_all do
    [
      prices: [
        Price.new(
          ticker: "F",
          date: ~D[2017-01-03],
          open: 90,
          high: 110,
          low: 80,
          close: 100,
          volume: 1_500
        ),
        Price.new(
          ticker: "F",
          date: ~D[2017-01-04],
          open: 100,
          high: 120,
          low: 90,
          close: 110,
          volume: 500
        )
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
    assert_float(Month.avg_open(month), avg_open)
    assert_float(Month.avg_close(month), avg_close)
    assert_volume(Month.avg_volume(month), avg_volume)
    assert_float(month.sum_open, avg_open * count)
    assert_float(month.sum_close, avg_close * count)
    assert_volume(month.sum_volume, avg_volume * count)
    month
  end

  @delta12 0.000_000_000_000_1
  @delta15 0.000_000_000_000_000_1

  def assert_float(a, b, delta \\ @delta12), do: assert_in_delta(a, b, delta)
  def assert_volume(a, b), do: assert_float(a, b, @delta15)
end
