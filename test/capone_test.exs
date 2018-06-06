defmodule CaponeTest do
  use ExUnit.Case
  require Logger

  doctest Capone

  @moduletag timeout: 120_000

  @tag :external
  describe "challenge" do
    @tag :skip
    test "print default output" do
      Capone.challenge()
      |> IO.puts()
    end
  end
end
