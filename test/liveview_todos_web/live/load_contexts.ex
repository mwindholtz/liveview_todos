defmodule LiveviewTodosWeb.LoadContexts do
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _opts) do
    conn
    |> load_context(:command, "DddCounter.Command")
  end

  # rename to: assign_new(socket, key, func)
  defp load_context(conn, atom, module) do
    if conn.assigns[atom] do
      conn
    else
      assign(conn, atom, module)
    end
  end
end
