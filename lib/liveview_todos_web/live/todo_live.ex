defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.Todos
  alias LiveviewTodosWeb.TodoView
  alias LiveviewTodos.TodoTopic

  def mount(_session, socket) do
    TodoTopic.subscribe()
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    # ~L"Rendering LiveView"
    TodoView.render("todos.html", assigns)
  end

  # --------- LiveView -----------

  def handle_event("add", %{"todo" => todo}, socket) do
    {:ok, _todo} = todos(socket).create_todo(todo)
    {:noreply, socket}
  end

  def handle_event("toggle_done", todo_id, socket) do
    todo = Todos.get_todo!(todo_id)
    Todos.update_todo(todo, %{done: !todo.done})
    {:noreply, socket}
  end

  #  -------- PubSub ---------------

  def handle_info({Todos, [:todo | _], :error, _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, todos: Todos.list_todo())
  end

  def todos(socket), do: socket.assigns.todos
end
