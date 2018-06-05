defmodule CaponeTest do
  use ExUnit.Case
  require Logger

  doctest Capone

  @moduletag timeout: 120_000

  @tag :external
  describe "challenge" do
    test "produces valid JSON" do
      actual =
        Date.range(~D[2017-01-03], ~D[2017-01-04])
        |> Capone.challenge()
    end

    @tag :skip
    test "print default output" do
      Capone.challenge()
      |> IO.puts()
    end
  end
end
