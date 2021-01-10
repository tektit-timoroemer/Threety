defmodule Fourty.Helpers do
  @moduledoc """
  A collection of general application helper functions.
  """
	
  @doc """
  Trim leading and/or trailing blanks from the given map item.
  """
  @spec trim_item(map(), keyword()) :: map()
  def trim_item(%{} = map, item) do
  	(s = Map.get(map, item)) && Map.put(map, item, String.trim(s)) || map
  end

  @doc """
  Trim leading and/or trailing blanks from the given map items.
  """
  @spec trim_items(map(), list(String.t())) :: map()
  def trim_items(%{} = map, items) do
  	for {k,v} <- map, into: %{}, do: if(v && (k in items), do: {k,String.trim(v)}, else: {k,v})
  end

end
