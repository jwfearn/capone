defmodule Capone.Stats.DayTest do
  @moduledoc false
  use ExUnit.Case
  alias Capone.Stats.{Day}
  alias Quandl.Price
  doctest Day

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
          close: 100,
          date: ~D[2017-01-04],
          high: 105,
          low: 90,
          open: 95,
          ticker: "F",
          volume: 500
        )
      ]
    ]
  end

  describe "list_from_prices" do
    test "without filter", context do
      [a | [b]] = Day.list_from_prices(context.prices)
      a |> assert_day(~D[2017-01-03], "F", 1_500)
      b |> assert_day(~D[2017-01-04], "F", 500)
    end

    test "with filter", context do
      [a] = Day.list_from_prices(context.prices, &(&1.volume < 1000))
      a |> assert_day(~D[2017-01-04], "F", 500)
    end
  end

  def assert_day(%Day{} = day, date, ticker, volume) do
    assert day.date == date
    assert day.ticker == ticker
    assert day.volume == volume
  end
end
