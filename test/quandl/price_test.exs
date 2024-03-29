defmodule Quandl.PriceTest do
  @moduledoc false
  use ExUnit.Case
  alias Quandl.Price
  doctest Price

  setup_all do
    json_str = """
    {
      "datatable": {
        "data": [
          [
            12.59,
            "2017-01-03",
            12.6,
            12.13,
            12.2,
            "F",
            40510821
          ],
          [
            13.17,
            "2017-01-04",
            13.27,
            12.74,
            12.77,
            "F",
            77631929
          ]
        ],
        "columns": [
          {
            "name": "close",
            "type": "BigDecimal(34,12)"
          },
          {
            "name": "date",
            "type": "Date"
          },
          {
            "name": "high",
            "type": "BigDecimal(34,12)"
          },
          {
            "name": "low",
            "type": "BigDecimal(34,12)"
          },
          {
            "name": "open",
            "type": "BigDecimal(34,12)"
          },
          {
            "name": "ticker",
            "type": "String"
          },
          {
            "name": "volume",
            "type": "BigDecimal(37,15)"
          }
        ]
      },
      "meta": {
        "next_cursor_id": null
      }
    }
    """

    [
      json_map: Jason.decode!(json_str),
      price:
        Price.new(
          close: 12.59,
          date: ~D[2017-01-03],
          high: 12.6,
          low: 12.13,
          open: 12.2,
          ticker: "F",
          volume: 40_510_821
        )
    ]
  end

  test "list_from_map", context do
    [a | [b]] = Price.list_from_map(context.json_map)
    a |> assert_price(12.59, ~D[2017-01-03], 12.6, 12.13, 12.2, "F", 40_510_821)
    b |> assert_price(13.17, ~D[2017-01-04], 13.27, 12.74, 12.77, "F", 77_631_929)
  end

  test "month_str", context do
    assert "2017-01" == Price.month_str(context.price)
  end

  test "gain", context do
    assert_float(Price.gain(context.price), 0.39)
  end

  test "spread", context do
    assert_float(Price.spread(context.price), 0.47)
  end

  def assert_price(%Price{} = price, close, date, high, low, open, ticker, volume) do
    assert_float(price.close, close)
    assert price.date == date
    assert_float(price.high, high)
    assert_float(price.low, low)
    assert_float(price.open, open)
    assert price.ticker == ticker
    assert_volume(price.volume, volume)
  end

  @delta12 0.000_000_000_000_1
  @delta15 0.000_000_000_000_000_1

  def assert_float(a, b, delta \\ @delta12), do: assert_in_delta(a, b, delta)
  def assert_volume(a, b), do: assert_float(a, b, @delta15)
end
