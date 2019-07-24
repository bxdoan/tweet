defmodule TweetWeb.PageController do
  use TweetWeb, :controller
  
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
