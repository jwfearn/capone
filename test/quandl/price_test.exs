defmodule Quandl.PriceTest do
  @moduledoc false
  use ExUnit.Case
  require Logger
  alias Quandl.Price
  doctest Price

  setup_all do
    json_str =
      """
      {
        "datatable": {
          "data": [
            [ "COF", "2017-01-03", 88.55, 88.87, 3441067 ],
            [ "COF", "2017-01-04", 89.13, 90.3, 2630905 ]
          ],
          "columns": [
            { "name": "ticker", "type": "String" },
            { "name": "date", "type": "Date" },
            { "name": "open", "type": "BigDecimal(34,12)" },
            { "name": "close", "type": "BigDecimal(34,12)" },
            { "name": "volume", "type": "BigDecimal(37,15)" }
          ]
        },
        "meta": { "next_cursor_id": null }
      }
      """

    [map: Jason.decode!(json_str)]
  end

  test "new_list", context do
    [a | [b]] = Price.new_list(context.map)
    a |> assert_price("COF", ~D[2017-01-03], 88.55, 88.87, 3441067)
    b |> assert_price("COF", ~D[2017-01-04], 89.13, 90.3, 2630905)
  end

  def assert_price(%Price{} = price, ticker, date, open, close, volume) do
    assert price.ticker == ticker
    assert price.date == date
    assert price.open == open
    assert price.close == close
    assert price.volume == volume
  end
end
