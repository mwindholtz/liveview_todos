defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodosWeb.TodoView
  alias LiveviewTodos.TodoTopic
  alias LiveviewTodos.DomainEvent
  # --------- LiveView -----------

  def mount(_session, socket) do
    TodoTopic.subscribe()

    socket =
      socket
      |> assign(todos: Service.list_todo())
      |> assign(lists: Service.lists())
      |> assign_new(:todo_application_service, fn -> Service end)

    {:ok, socket}
  end

  def render(assigns) do
    TodoView.render("todos.html", assigns)
  end

  # --------- LiveView Events -----------

  def handle_event("list-create", %{"list" => attrs}, socket) do
    domain_event = DomainEvent.new("create-list", attrs)
    todos(socket).accept(domain_event)
    {:noreply, socket}
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    {:ok, _todo} = todos(socket).create_todo(todo)
    {:noreply, socket}
  end

  def handle_event("toggle_done", todo_id, socket) do
    todo = Service.get_todo!(todo_id)
    Service.update_todo(todo, %{done: !todo.done})
    {:noreply, socket}
  end

  #  -------- PubSub ---------------

  @topic LiveviewTodos.TodoTopic

  def handle_info({@topic, [:todo | _], :error, _}, socket) do
    {:noreply, refresh_todos(socket)}
  end

  def handle_info({@topic, [:todo | _], _}, socket) do
    {:noreply, refresh_todos(socket)}
  end

  def handle_info({@topic, [:list | _], _}, socket) do
    {:noreply, refresh_lists(socket)}
  end

  def handle_info({@topic, [:list | _], :error, _}, socket) do
    {:noreply, refresh_lists(socket)}
  end

  # def handle_info(tuple, socket) do
  #   IO.inspect(tuple, label: "unexpected TUPLE ==================== ")
  #   {:noreply, refresh_lists(socket)}
  # end

  # -------  Implementation ---------------

  def refresh_todos(socket) do
    assign(socket, todos: Service.list_todo())
  end

  def refresh_lists(socket) do
    assign(socket, lists: Service.lists())
  end

  def todos(%{assigns: assigns} = _socket) do
    Map.fetch!(assigns, :todo_application_service)
  end
end
