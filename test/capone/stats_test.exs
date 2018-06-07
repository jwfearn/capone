defmodule Capone.StatsTest do
  @moduledoc false
  use ExUnit.Case
  alias Capone.Stats
  alias Capone.Stats.{Day, Month, Security}
  alias Quandl.Price
  doctest Stats

  setup_all do
    [
      prices: [
        Price.new(
          close: 95,
          date: ~D[2017-01-03],
          high: 100,
          low: 85,
          open: 100,
          ticker: "F",
          volume: 1_500
        ),
        Price.new(
          close: 100,
          date: ~D[2017-01-04],
          high: 110,
          low: 90,
          open: 95,
          ticker: "F",
          volume: 500
        ),
        Price.new(
          close: 10,
          date: ~D[2017-01-03],
          high: 10,
          low: 10,
          open: 10,
          ticker: "T",
          volume: 601
        ),
        Price.new(
          close: 10,
          date: ~D[2017-01-04],
          high: 10,
          low: 10,
          open: 10,
          ticker: "T",
          volume: 599
        )
      ]
    ]
  end

  test "without filter", context do
    expected_loser = %Security{
      count: 2,
      losing_days_count: 1,
      max_spread: 20.0,
      sum_volume: 2_000.0,
      ticker: "F"
    }

    expected_busy_days = [
      %Day{date: ~D[2017-01-03], spread: 15.0, ticker: "F", volume: 1_500.0}
    ]

    expected_max_spread_days = [
      %Day{date: ~D[2017-01-03], spread: 0.0, ticker: "T", volume: 601.0},
      %Day{date: ~D[2017-01-04], spread: 20.0, ticker: "F", volume: 500.0}
    ]

    expected_months = %{
      "F" => [
        %Month{
          count: 2,
          month_str: "2017-01",
          sum_close: 195.0,
          sum_open: 195.0,
          sum_volume: 2_000.0,
          ticker: "F"
        }
      ],
      "T" => [
        %Month{
          count: 2,
          month_str: "2017-01",
          sum_close: 20.0,
          sum_open: 20.0,
          sum_volume: 1_200.0,
          ticker: "T"
        }
      ]
    }

    expected_securities = [
      expected_loser,
      %Security{
        count: 2,
        losing_days_count: 0,
        max_spread: 0.0,
        sum_volume: 1_200.0,
        ticker: "T"
      }
    ]

    context.prices
    |> Stats.from_prices()
    |> assert_stats(
      expected_loser,
      expected_busy_days,
      expected_max_spread_days,
      expected_months,
      expected_securities
    )
  end

  test "security provides access by ticker symbol", context do
    actual =
      context.prices
      |> Stats.from_prices()
      |> Stats.security("F")

    assert actual
  end

  defp assert_stats(
         %Stats{} = stats,
         biggest_loser,
         busy_days,
         max_spread_days,
         months,
         securities
       ) do
    # NOTE: The following assertions are simple element-by-element equality
    # comparisons. Test data has been chosen to avoid values that cannot be
    # precisely represented in floating point. We do more robust floating point
    # testing in the Day, Month, and Security modules.

    assert stats.biggest_loser == biggest_loser
    assert stats.busy_days == busy_days
    assert stats.max_spread_days == max_spread_days
    assert stats.months == months
    assert stats.securities == securities
  end
end
