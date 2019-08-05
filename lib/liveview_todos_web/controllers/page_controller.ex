defmodule LiveviewTodosWeb.PageController do
  use LiveviewTodosWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
