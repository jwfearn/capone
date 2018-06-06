defmodule Capone.Stats.TickerTest do
  @moduledoc false
  use ExUnit.Case
  alias Capone.Stats.{Security}
  alias Quandl.Price
  doctest Security

  setup_all do
    [
      prices: [
        Price.new(
          close: 95,
          date: ~D[2017-01-03],
          high: 100,
          low: 85,
          open: 90,
          ticker: "F",
          volume: 1_500
        ),
        Price.new(
          close: 80,
          date: ~D[2017-01-04],
          high: 105,
          low: 70,
          open: 95,
          ticker: "F",
          volume: 500
        )
      ]
    ]
  end

  test "from_prices", context do
    context.prices
    |> Security.from_prices()
    |> assert_security(2, 1, 35, 2_000, "F")
  end

  def assert_security(
        %Security{} = security,
        count,
        losing_days_count,
        max_spread,
        sum_volume,
        ticker
      ) do
    assert security.count == count
    assert security.losing_days_count == losing_days_count
    assert_float(security.max_spread, max_spread)
    assert_volume(security.sum_volume, sum_volume)
    assert security.ticker == ticker
  end

  @delta12 0.000_000_000_000_1
  @delta15 0.000_000_000_000_000_1

  def assert_float(a, b, delta \\ @delta12), do: assert_in_delta(a, b, delta)
  def assert_volume(a, b), do: assert_float(a, b, @delta15)
end
