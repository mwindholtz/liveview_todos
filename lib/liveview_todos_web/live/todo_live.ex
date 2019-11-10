defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.DomainEvent
  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.TodoTopic
  alias LiveviewTodosWeb.TodoView
  alias LiveviewTodosWeb.TodoLive.Command
  alias Phoenix.LiveView.Socket
  require Logger
  @topic LiveviewTodos.TodoTopic

  def topic, do: @topic

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
    event = DomainEvent.new(:create_list, name, __MODULE__)
    service(socket).accept(event)
    {:noreply, socket}
  end

  def handle_event("delete-list", %{"list-id" => list_id}, %Socket{} = socket) do
    event = DomainEvent.new(:delete_list, %{list_id: list_id |> String.to_integer()}, __MODULE__)

    service(socket).accept(event)
    {:noreply, socket}
  end

  def handle_event("add-item", %{"item" => item}, %Socket{} = socket) do
    service(socket).create_item(item)
    {:noreply, socket}
  end

  def handle_event(
        "toggle_done",
        %{"list-id" => list_id, "item-title" => item_title},
        %Socket{} = socket
      ) do
    event = DomainEvent.new(:toggle_item, %{list_id: list_id, item_title: item_title}, __MODULE__)
    service(socket).accept(event)
    {:noreply, socket}
  end

  def handle_event(event, args, %Socket{} = socket) do
    Logger.error("UNHANDED LIVE EVENT: #{event} ===== ARGS: #{args}")
    {:noreply, socket}
  end

  #  -------- PubSub From the Domain Layer ---------------

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
    Logger.error("UNHANDED PUBSUB TUPLE: #{inspect(tuple)}")
    {:noreply, command(socket).refresh_lists(socket)}
  end

  # injection helper, retrieve the previously injected module 
  def service(%Socket{assigns: assigns} = _socket) do
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

      service(socket).list_ids()
      |> Enum.reduce(socket, fn list_id, socket -> refresh_one_list(socket, list_id) end)
    end

    def refresh_one_list(%Socket{} = socket, list_id) do
      list = service(socket).get_list(list_id)
      mod_map = Map.put(socket.assigns.list_map, list_id, list)

      socket
      |> assign(list_map: mod_map)
    end

    def service(%Socket{} = socket) do
      LiveviewTodosWeb.TodoLive.service(socket)
    end
  end
end
