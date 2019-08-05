defmodule LiveViewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.Todos

  def mount(_session, socket) do
    {:ok, assign(socket, todos: Todos.list_todo())}
  end

  def render(assigns) do
    ~L"Rendering LiveView"
  end
end
