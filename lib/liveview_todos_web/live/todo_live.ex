defmodule LiveViewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.Todos
  alias LiveviewTodosWeb.TodoView

  def mount(_session, socket) do
    {:ok, assign(socket, todos: Todos.list_todo())}
  end

  def render(assigns) do
    # ~L"Rendering LiveView"
    TodoView.render("todos.html", assigns)
  end
end
