defmodule TweetWeb.RoomChannel do
  use TweetWeb, :channel

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    # todo save message
    index = Redix.command!(:redix, ["GET", "index"])
    newIndex = case index do
                    nil ->
                        1
                    _ ->
                        String.to_integer(index) + 1
                end
    Redix.command(:redix, ["SET", "index", newIndex])

    # check retweet or not
    case payload["isRe"] do
      true ->
        Tweet.Message.set(newIndex, payload)
        Tweet.Message.update_top(newIndex, String.to_integer((payload["index"])))
      _ ->
        newPayload = Map.put(payload, "num_retw", 0)
                      |> Map.put("index", newIndex)
        Tweet.Message.set(newIndex, newPayload)
        Tweet.Message.update_top(newIndex, index)
    end

    # broadcast to other client
    tops = Tweet.Message.get("top")
    broadcast(socket, "clear", payload)
    case tops do
      nil ->
        :ok
      _ ->
        Enum.each(tops, fn(x) -> broadcast(socket, "shout", x) end)
    end

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    tops = Tweet.Message.get("top")
    case tops do
      nil ->
        1
      _ ->
        Enum.each(tops, fn(x) -> push(socket, "shout", x) end)
      end
    {:noreply, socket} # :noreply
  end

  defp authorized?(_payload) do
    true
  end
end
