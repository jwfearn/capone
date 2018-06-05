defmodule Capone do
  @moduledoc false
  alias Quandl.Client
  alias Capone.Stats

  @default_tickers ~w[COF GOOGL MSFT]
  @default_date_range Date.range(~D[2017-01-01], ~D[2017-06-30])

  def challenge(date_range \\ @default_date_range, tickers \\ @default_tickers) do
    Client.new()
    |> Client.prices(tickers, date_range)
    |> Stats.from_prices()
    |> Stats.to_json_str()
  end
end
