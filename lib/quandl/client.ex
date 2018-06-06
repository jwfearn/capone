defmodule Quandl.Client do
  @moduledoc false
  use Tesla
  alias Quandl.Price

  @default_base_url "https://www.quandl.com"
  @default_retry_delay_ms 500
  @default_retries 10

  def new(base_url \\ @default_base_url) do
    Tesla.build_client([
      {Tesla.Middleware.BaseUrl, Envar.fetch("QUANDL_API_HOST", base_url)},
      {Tesla.Middleware.Query, api_key: Envar.fetch("QUANDL_API_KEY")},
      {Tesla.Middleware.Retry, delay: @default_retry_delay_ms, max_retries: @default_retries},
      {Tesla.Middleware.JSON, engine: Jason}
    ])
  end

  def prices(_, [], _), do: []

  def prices(client, tickers, %Date.Range{first: start_date, last: end_date} = date_range) do
    query = [
      ticker: tickers |> Enum.join(","),
      "date.gte": start_date |> Date.to_iso8601(),
      "date.lte": end_date |> Date.to_iso8601(),
      "qopts.columns": Price.columns() |> Enum.join(",")
    ]

    with response <- Tesla.get(client, "/api/v3/datatables/WIKI/PRICES.json", query: query) do
      Price.list_from_json_map(response.body)
    end
  end

  def prices(client, tickers, %Date{} = start_date) do
    prices(client, tickers, Date.range(start_date, start_date))
  end

  def prices(client, tickers, %Date{} = start_date, %Date{} = end_date) do
    prices(client, tickers, Date.range(start_date, end_date))
  end
end
