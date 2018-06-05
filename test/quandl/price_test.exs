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

    [json_map: Jason.decode!(json_str)]
  end

  test "list_from_json_map", context do
    [a | [b]] = Price.list_from_json_map(context.json_map)
    a |> assert_price(12.59, ~D[2017-01-03], 12.6, 12.13, 12.2, "F", 40_510_821)
    b |> assert_price(13.17, ~D[2017-01-04], 13.27, 12.74, 12.77, "F", 77_631_929)
  end

  def assert_price(%Price{} = price, close, date, high, low, open, ticker, volume) do
    assert price.close == close
    assert price.date == date
    assert price.high == high
    assert price.low == low
    assert price.open == open
    assert price.ticker == ticker
    assert price.volume == volume
  end
end
