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

  def domain_event_for_list(name, list_id, attrs \\ %{}) do
    attrs_with_list_id = Map.merge(attrs, %{list_id: to_integer(list_id)})
    DomainEvent.new(name, attrs_with_list_id)
  end

  def handle_event("create-list", %{"list" => %{"name" => name}}, %Socket{} = socket) do
    name
    |> service(socket).create_list()

    {:noreply, socket}
  end

  def handle_event("delete-list", %{"list-id" => list_id}, %Socket{} = socket) do
    domain_event =
      :delete_list
      |> domain_event_for_list(list_id)

    TargetedTopic.broadcast(list_id, domain_event)
    {:noreply, socket}
  end

  def handle_event("add-item", %{"item" => item}, %Socket{} = socket) do
    %{"description" => description, "list_id" => list_id} = item

    domain_event =
      :create_item
      |> domain_event_for_list(list_id, %{description: description})

    # WIP use more of this
    TargetedTopic.broadcast(list_id, domain_event)

    {:noreply, socket}
  end

  def handle_event(
        "toggle_done",
        %{"list-id" => list_id, "item-title" => item_title},
        %Socket{} = socket
      ) do
    domain_event =
      :toggle_item
      |> domain_event_for_list(list_id, %{item_title: item_title})

    TargetedTopic.broadcast(list_id, domain_event)

    {:noreply, socket}
  end

  def handle_event(event, args, %Socket{} = socket) do
    Logger.error("UNHANDED LIVE EVENT: #{event} ===== ARGS: #{args}")
    {:noreply, socket}
  end

  defp to_integer(list_id) do
    list_id |> String.to_integer()
  end

  #  -------- PubSub From the Domain Layer ---------------

  def handle_info(:load_all, %Socket{} = socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], :error, _}, %Socket{} = socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:todo | _], _}, %Socket{} = socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], :error, _}, %Socket{} = socket) do
    # WIP TODO listen for Target
    {:noreply, command(socket).refresh_lists(socket)}
  end

  def handle_info({@topic, [:lists | _], _}, %Socket{} = socket) do
    # WIP TODO listen for Target
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
      |> Enum.reduce(socket, &refresh_one_list/2)
    end

    def refresh_one_list(list_id, %Socket{} = socket) do
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
