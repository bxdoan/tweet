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
    Redix.command(:redix, ["SET", newIndex, Jason.encode!(payload)])
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    # Tweet.Message.set_messages(payload)
    index = Redix.command!(:redix, ["GET", "index"])
    newIndex = case index do
                    nil ->
                        1
                    _ ->
                        index
                end
    Enum.each(9..0, fn(x) ->
        data = Redix.command!(:redix, ["GET", String.to_integer(newIndex) - x])
        case data do
            nil ->
                1
            _ ->
                push(socket, "shout", Jason.decode!(data))
        end
    end)
    {:noreply, socket} # :noreply
  end

  defp authorized?(_payload) do
    true
  end
end
