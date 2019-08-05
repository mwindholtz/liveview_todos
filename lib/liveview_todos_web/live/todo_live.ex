defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.Todos
  alias LiveviewTodosWeb.TodoView

  def mount(_session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    # ~L"Rendering LiveView"
    TodoView.render("todos.html", assigns)
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    {:ok, _todo} = Todos.create_todo(todo)
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, todos: Todos.list_todo())
  end
end
