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
        %Price{
          close: 95,
          date: ~D[2017-01-03],
          high: 100,
          low: 85,
          open: 100,
          ticker: "F",
          volume: 1_500
        },
        %Price{
          close: 100,
          date: ~D[2017-01-04],
          high: 105,
          low: 90,
          open: 95,
          ticker: "F",
          volume: 500
        },
        %Price{
          close: 10,
          date: ~D[2017-01-03],
          high: 10,
          low: 10,
          open: 10,
          ticker: "T",
          volume: 501
        },
        %Price{
          close: 10,
          date: ~D[2017-01-04],
          high: 10,
          low: 10,
          open: 10,
          ticker: "T",
          volume: 499
        }
      ]
    ]
  end

  test "without filter", context do
    expected_loser = %Security{
      count: 2,
      loser_count: 1,
      max_spread: 15,
      sum_volume: 2_000,
      ticker: "F"
    }

    expected_busy_days = [
      %Day{date: ~D[2017-01-03], ticker: "F", volume: 1_500}
    ]

    expected_max_spread_days = %{}

    expected_months = %{
      "F" => [
        %Month{
          count: 2,
          month_str: "2017-01",
          sum_close: 195,
          sum_open: 195,
          sum_volume: 2_000,
          ticker: "F"
        }
      ],
      "T" => [
        %Month{
          count: 2,
          month_str: "2017-01",
          sum_close: 20,
          sum_open: 20,
          sum_volume: 1_000,
          ticker: "T"
        }
      ]
    }

    expected_securities = [
      expected_loser,
      %Security{count: 2, loser_count: 0, max_spread: 0, sum_volume: 1_000, ticker: "T"}
    ]

    context.prices
    |> Stats.from_prices()
    |> assert_stats(expected_loser, expected_busy_days, expected_months, expected_securities)
  end

  test "encodes as valid JSON with expected structure", context do
    context.prices
    |> Stats.from_prices()
    |> Stats.to_json_str()
    |> assert_stats_json_structure()
  end

  defp assert_stats(%Stats{} = stats, biggest_loser, busy_days, months, securities) do
    assert stats.biggest_loser == biggest_loser
    assert stats.busy_days == busy_days
    assert stats.months == months
    assert stats.securities == securities
  end

  defp assert_stats_json_structure(json_str) do
    security_json_structure = """
    {
      "count": 0,
      "loser_count": 0,
      "max_spread": 0,
      "sum_volume": 0,
      "ticker": ""
    }
    """

    day_json_structure = """
    {
      "date": "",
      "ticker": "",
      "volume": 0
    }
    """

    stats_json_structure_str = """
    {
      "biggest_loser": #{security_json_structure},
      "busy_days": [#{day_json_structure}],
      "months": {},
      "securities": [#{security_json_structure}]
    }
    """

    assert_json_structure(stats_json_structure_str, json_str)
  end

  def assert_json_structure(expected_json_structure_str, actual_json_str) do
    {:ok, expected} = Jason.decode(expected_json_structure_str)
    {:ok, actual} = Jason.decode(actual_json_str)
    assert match_json_structure?(expected, actual)
  end

  defp match_json_structure?(nil, nil), do: true
  defp match_json_structure?(true, true), do: true
  defp match_json_structure?(false, false), do: true
  defp match_json_structure?(a, b) when is_binary(a) and is_binary(b), do: true
  defp match_json_structure?(a, b) when is_number(a) and is_number(b), do: true
  defp match_json_structure?([], []), do: true
  defp match_json_structure?([], [_ | _]), do: true
  defp match_json_structure?([_ | _], []), do: true
  defp match_json_structure?([a | _], [b | _]), do: match_json_structure?(a, b)

  defp match_json_structure?(a, b) when is_map(a) and is_map(b) do
    a |> Enum.all?(fn {k, v} when is_binary(k) -> match_json_structure?(v, Map.get(b, k)) end)
  end
end
