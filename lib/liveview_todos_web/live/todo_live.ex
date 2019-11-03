defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodosWeb.TodoView
  alias LiveviewTodos.TodoTopic
  # --------- LiveView -----------

  def mount(_session, socket) do
    TodoTopic.subscribe()

    socket =
      socket
      |> assign(lists: [])
      |> assign(list_map: %{})
      |> assign(:todo_application_service, Service)

    send(self(), :load_all)
    {:ok, socket}
  end

  def render(assigns) do
    TodoView.render("todos.html", assigns)
  end

  # --------- LiveView Events -----------

  def handle_event("create-list", %{"list" => %{"name" => name}}, socket) do
    todos(socket).create_list(name)
    {:noreply, socket}
  end

  def handle_event("delete-list", %{"list-id" => list_id}, socket) do
    todos(socket).delete_list(list_id |> String.to_integer())
    {:noreply, socket}
  end

  def handle_event("add-item", %{"item" => item}, socket) do
    todos(socket).create_item(item)
    {:noreply, socket}
  end

  def handle_event("toggle_done", %{"list-id" => list_id, "item-title" => item_title}, socket) do
    todos(socket).toggle_item(list_id, item_title)
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

  def handle_info(:load_all, socket) do
    {:noreply, refresh_lists(socket)}
  end

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

  def refresh_lists(socket) do
    list = Service.lists()
    assign(socket, lists: last)
  end

  def todos(%{assigns: assigns} = _socket) do
    Map.fetch!(assigns, :todo_application_service)
  end
end
