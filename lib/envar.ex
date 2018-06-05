defmodule Envar do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def fetch(key), do: System.get_env(key) |> required!(key)
  def fetch(key, fallback), do: System.get_env(key) || fallback

  defp required!(nil, key), do: raise("missing environment variable #{key}")
  defp required!(v, _), do: v
end
