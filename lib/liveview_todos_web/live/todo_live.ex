defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.TodoTopic
  alias LiveviewTodosWeb.TodoView
  alias LiveviewTodosWeb.TodoLive.Command
  alias Phoenix.LiveView.Socket

  require Logger
  # --------- LiveView -----------

  def mount(_session, %Socket{} = socket) do
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

  # --------- LiveView Events From the User Interface-----------

  def handle_event("create-list", %{"list" => %{"name" => name}}, %Socket{} = socket) do
    todos(socket).create_list(name)
    {:noreply, socket}
  end

  def handle_event("delete-list", %{"list-id" => list_id}, %Socket{} = socket) do
    todos(socket).delete_list(list_id |> String.to_integer())
    {:noreply, socket}
  end

  def handle_event("add-item", %{"item" => item}, %Socket{} = socket) do
    todos(socket).create_item(item)
    {:noreply, socket}
  end

  def handle_event(
        "toggle_done",
        %{"list-id" => list_id, "item-title" => item_title},
        %Socket{} = socket
      ) do
    todos(socket).toggle_item(list_id, item_title)
    {:noreply, socket}
  end

  def handle_event(event, args, %Socket{} = socket) do
    Logger.error("UNHANDED LIVE EVENT: #{event} ===== ARGS: #{args}")
    {:noreply, socket}
  end

  #  -------- PubSub From the Domain Layer ---------------

  @topic LiveviewTodos.TodoTopic

  def handle_info(:load_all, %Socket{} = socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], :error, _}, %Socket{} = socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], _}, %Socket{} = socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], :error, _}, %Socket{} = socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], _}, %Socket{} = socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info(tuple, %Socket{} = socket) do
    Logger.error("UNHANDED PUBSUB TUPLE: #{tuple}")
    {:noreply, command(socket).refresh_lists(socket)}
  end

  # injection helper, retrieve the previously injected module 
  def todos(%Socket{assigns: assigns} = _socket) do
    Map.fetch!(assigns, :todo_application_service)
  end

  # injection helper, retrieve the previously injected module 
  def command(%Socket{assigns: assigns} = _socket) do
    Map.get(assigns, :command, Command)
  end

  # -------  Implementation ---------------

  defmodule Command do
    def refresh_lists(%Socket{} = socket) do
      socket =
        socket
        |> assign(list_map: %{})

      Service.list_ids()
      |> Enum.reduce(socket, fn list_id, socket -> refresh_one_list(socket, list_id) end)
    end

    def refresh_one_list(%Socket{} = socket, list_id) do
      list = Service.get_list(list_id)
      mod_map = Map.put(socket.assigns.list_map, list_id, list)

      socket
      |> assign(list_map: mod_map)
    end
  end
end
