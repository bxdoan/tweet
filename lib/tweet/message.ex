defmodule Tweet.Message do
  @doc false
  def update_top(index, index_orig) do
    list_top = get("top")
    newListTop = case list_top do
                nil ->
                  [get(index)]
                _ ->
                  check(list_top, index, index_orig)
              end
    set("top", newListTop)
  end

  def check(list_top, index, index_orig) do
    list_index_tops = Enum.map(list_top, fn (x) -> x["index"] end)
    case Enum.member?(list_index_tops, index_orig) do
      true ->
        update_tweet(index_orig)
        update_list_top(list_top, index_orig)
      false ->
        case length(list_top) < 10 do
          true ->
              list_top2= list_top ++ [get(index)]
              Enum.sort_by(list_top2, fn(p) -> p["num_retw"] end)
          false ->
              list_top
        end
    end
  end

  def set(key, value) do
    Redix.command!(:redix, ["SET", key, Jason.encode!(value)])
  end

  def get(key) do
    case Redix.command!(:redix, ["GET", key]) do
      nil ->
        nil
        res ->
          Jason.decode!(res)
    end
  end


  def update_list_top(list_top, index_orig) do
    res = List.delete(list_top, Enum.find(list_top, fn(msg) ->
          msg["index"] == index_orig
        end))
    res ++ [get(index_orig)]
    |> Enum.sort_by(fn(p) -> p["num_retw"] end)
  end

  def update_tweet(index) do
    msg = get(index)
    IO.inspect(msg)
    msg1 = Map.update(msg, "num_retw", 0, &(&1 + 1))
    set(index, msg1)
  end

end
