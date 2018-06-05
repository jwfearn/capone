defmodule Quandl.ClientTest do
  @moduledoc false
  use ExUnit.Case
  require Logger
  alias Quandl.{Client, Price}
  doctest Client

  describe "videos/2" do
    test "accepts empty ticker list and returns empty enumerable" do
      actual = Client.new() |> Client.prices([], ~D[2017-01-03])
      refute Enum.any?(actual)
    end

    @tag :external
    test "accepts a ticker list and returns an enumerable of Prices" do
      actual = Client.new() |> Client.prices(~w[F T], Date.range(~D[2017-01-03], ~D[2017-01-04]))
      assert Enum.count(actual) == 4
      assert Enum.all?(actual, &(%Price{} = &1))
    end
  end
end
