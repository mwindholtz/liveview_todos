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
      |> assign(lists: Service.lists())
      |> assign(:todo_application_service, Service)

    {:ok, socket}
  end

  def render(assigns) do
    TodoView.render("todos.html", assigns)
  end

  # --------- LiveView Events -----------

  def handle_event("create-list", %{"list" => attrs}, socket) do
    domain_event = DomainEvent.new("create-list", attrs)
    todos(socket).accept(domain_event)
    {:noreply, socket}
  end

  def handle_event("delete-list", %{"list-id" => list_id}, socket) do
    IO.inspect(list_id, label: "list-id")
    domain_event = DomainEvent.new("delete-list", %{list_id: String.to_integer(list_id)})
    todos(socket).accept(domain_event)
    {:noreply, socket}
  end

  def handle_event("add", %{"item" => item}, socket) do
    todos(socket).create_item(item)
    {:noreply, socket}
  end

  def handle_event("toggle_done", %{"item-id" => item_id}, socket) do
    item = todos(socket).get_todo!(String.to_integer(item_id))
    todos(socket).update_todo(item, %{done: !item.done})
    {:noreply, socket}
  end

  def handle_event(event, args, socket) do
    IO.inspect("UNHANDED LIVE EVENT ================================= ")
    IO.inspect(event, label: "event")
    IO.inspect(args, label: "args")
    {:noreply, socket}
  end

  #  -------- PubSub ---------------

  @topic LiveviewTodos.TodoTopic

  def handle_info({@topic, [:todo | _], :error, _}, socket) do
    {:noreply, refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], _}, socket) do
    {:noreply, refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], _}, socket) do
    {:noreply, refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], :error, _}, socket) do
    {:noreply, refresh_lists(socket)}
  end

  def handle_info(tuple, socket) do
    IO.inspect(tuple, label: "unexpected TUPLE ==================== ")
    {:noreply, refresh_lists(socket)}
  end

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
