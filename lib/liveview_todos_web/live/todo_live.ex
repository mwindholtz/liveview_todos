defmodule LiveviewTodosWeb.TodoLive do
  use Phoenix.LiveView
  alias LiveviewTodos.DomainEvent
  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.TodoTopic
  alias LiveviewTodos.TargetedTopic
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
      |> assign(list_map: %{})
      |> assign(:todo_application_service, Service)

    send(self(), :load_all)
    {:ok, socket}
  end

  def render(assigns) do
    TodoView.render("todos.html", assigns)
  end

  # --------- LiveView Events From the User Interface-----------
  def handle_event("create-list", %{"list" => %{"name" => name}}, socket) do
    name
    |> service(socket).create_list()

    {:noreply, socket}
  end

  def handle_event("delete-list", %{"list-id" => list_id}, socket) do
    :delete_list_requested
    |> domain_event_for_list(list_id)
    |> broadcast(list_id)

    {:noreply, socket}
  end

  def handle_event("add-item", %{"item" => item}, socket) do
    %{"description" => description, "list_id" => list_id} = item

    :create_item_requested
    |> domain_event_for_list(list_id, %{description: description})
    |> broadcast(list_id)

    {:noreply, socket}
  end

  def handle_event(
        "toggle_done",
        %{"list-id" => list_id, "item-title" => item_title},
        %Socket{} = socket
      ) do
    :toggle_item_requested
    |> domain_event_for_list(list_id, %{item_title: item_title})
    |> broadcast(list_id)

    {:noreply, socket}
  end

  def handle_event(event, args, socket) do
    Logger.error("UNHANDED LIVE EVENT: #{inspect(event)} ===== ARGS: #{inspect(args)}")
    {:noreply, socket}
  end

  # --------- Helpers -----------

  defp domain_event_for_list(name, list_id, attrs \\ %{}) do
    attrs_with_list_id = Map.merge(attrs, %{list_id: to_integer(list_id)})
    DomainEvent.new(name, attrs_with_list_id)
  end

  defp broadcast(domain_event, list_id) do
    # swap arg ordering to make pipe fit
    TargetedTopic.broadcast(list_id, domain_event)
  end

  defp to_integer(list_id) do
    list_id |> String.to_integer()
  end

  #  -------- PubSub From the Domain Layer ---------------
  def handle_info(%DomainEvent{name: :list_item_toggled, attrs: %{list_id: _list_id}}, socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info(%DomainEvent{name: :list_created, attrs: %{list_id: _list_id}}, socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info(
        %DomainEvent{name: :todo_created, attrs: %{list_id: _list_id, title: _}},
        socket
      ) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info(%DomainEvent{name: :list_deleted, attrs: %{list_id: _list_id}}, socket) do
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info(:load_all, %Socket{} = socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], :error, _}, socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], _}, socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], :error, _}, socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], _}, socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info(tuple, socket) do
    Logger.error("UNHANDED PUBSUB TUPLE: #{inspect(tuple)}")
    {:noreply, command(socket).refresh_lists(socket)}
  end

  # catchall --------------
  def handle_info(_, state) do
    {:noreply, state}
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
    def refresh_lists(socket) do
      socket =
        socket
        |> assign(list_map: %{})

      service(socket).list_ids()
      |> Enum.reduce(socket, &refresh_one_list/2)
    end

    def refresh_one_list(list_id, socket) do
      list = service(socket).get_list(list_id)
      mod_map = Map.put(socket.assigns.list_map, list_id, list)

      socket
      |> assign(list_map: mod_map)
    end

    def service(socket) do
      LiveviewTodosWeb.TodoLive.service(socket)
    end
  end
end
