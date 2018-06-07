defmodule CaponeTest do
  use ExUnit.Case
  require Logger

  doctest Capone

  @moduletag timeout: 120_000

  @tag :external
  describe "challenge" do
    test "encodes as valid JSON with expected structure" do
      Capone.challenge(
        Date.range(~D[2017-01-01], ~D[2017-01-05]),
        ~w[H I],
        show_biggest_loser: true,
        show_busy_days: true,
        show_max_spread_days: true
      )
      |> assert_challenge_json_shape()
    end
  end

  defp assert_challenge_json_shape(json_str) do
    month_shape = """
    {
      "month": "",
      "average_open": 0,
      "average_close": 0
    }
    """

    loser_shape = """
    {
      "ticker": "",
      "losing_days_count": 0
    }
    """

    busy_shape = """
    {
      "date": "",
      "ticker": "",
      "volume": 0,
      "percent_of_average_volume": 0,
      "average_volume": 0
    }
    """

    spread_shape = """
    {
      "ticker": "",
      "date": "",
      "spread": 0
    }
    """

    challenge_json_shape = """
    {
      "H": [#{month_shape}],
      "I": [#{month_shape}],
      "biggest_loser": #{loser_shape},
      "busy_days": [#{busy_shape}],
      "maximum_spread_days": [#{spread_shape}]
    }
    """

    assert_json_shape(challenge_json_shape, json_str)
  end

  def assert_json_shape(expected_json_shape_str, actual_json_str) do
    {:ok, expected} = Jason.decode(expected_json_shape_str)
    {:ok, actual} = Jason.decode(actual_json_str)
    assert match_json_shape?(expected, actual)
  end

  defp match_json_shape?(nil, nil), do: true
  defp match_json_shape?(true, true), do: true
  defp match_json_shape?(false, false), do: true
  defp match_json_shape?(a, b) when is_binary(a) and is_binary(b), do: true
  defp match_json_shape?(a, b) when is_number(a) and is_number(b), do: true
  defp match_json_shape?([], []), do: true
  defp match_json_shape?([], [_ | _]), do: true
  defp match_json_shape?([_ | _], []), do: true
  defp match_json_shape?([a | _], [b | _]), do: match_json_shape?(a, b)

  defp match_json_shape?(expected, actual) when is_map(expected) and is_map(actual) do
    expected
    |> Enum.all?(fn {k, v} when is_binary(k) -> match_json_shape?(v, Map.get(actual, k)) end)
  end
end
