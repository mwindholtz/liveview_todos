defmodule LiveviewTodos.ListAggregate do
  @moduledoc """
  """
  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  use GenServer, restart: :transient
  alias LiveviewTodos.List
  alias LiveviewTodos.ListAggregate.State
  alias LiveviewTodos.TargetedTopic
  alias LiveviewTodos.DomainEvent
  require Logger

  defmodule State do
    @enforce_keys [:list_id, :name, :deps]
    defstruct [:list_id, :name, :deps]
  end

  # ---------  Client Interface  -------------

  def start_link(list_id) do
    GenServer.start_link(__MODULE__, list_id, name: via_tuple(list_id))
  end

  def accept(%DomainEvent{attrs: attrs} = event) do
    attrs.list_id
    |> via_tuple
    |> GenServer.cast({:domain_event, event})
  end

  # ---------  Server  -------------

  def init(list_id) when is_integer(list_id) do
    state = %State{list_id: list_id, name: "TBD", deps: @deps}

    {:ok, state, {:continue, :ok}}
  end

  def handle_continue(:ok, %State{} = state) do
    list = list(state)
    TargetedTopic.subscribe(list.id)

    state = %{state | name: list.name}
    {:noreply, state}
  end

  # WIP TODO deprecated 
  def handle_cast(
        {:domain_event, %DomainEvent{name: :toggle_item_requested, attrs: attrs}},
        state
      ) do
    state
    |> list()
    |> List.toggle_item(attrs.item_title)

    {:noreply, state}
  end

  # WIP TODO deprecated 

  def handle_cast({:domain_event, %DomainEvent{name: :delete_list_requested}}, state) do
    list = list(state)
    List.delete(list)
    TargetedTopic.unsubscribe(list.id)

    {:stop, :normal, state}
  end

  # WIP TODO deprecated 
  def handle_cast(
        {:domain_event, %DomainEvent{name: :create_item_requested, attrs: attrs}},
        %State{} = state
      ) do
    {:ok, _todo} =
      state
      |> list()
      |> List.create_item(%{"description" => attrs.description})

    {:noreply, state}
  end

  def handle_cast(request, state) do
    Logger.error("UNEXPECTED REQUEST: #{inspect(request)}")
    {:noreply, state}
  end

  def handle_info(%DomainEvent{name: :toggle_item_requested, attrs: attrs}, state) do
    state
    |> list()
    |> List.toggle_item(attrs.item_title)

    {:noreply, state}
  end

  def handle_info(%DomainEvent{name: :create_item_requested, attrs: attrs}, state) do
    state
    |> list()
    |> List.create_item(%{"description" => attrs.description})

    {:noreply, state}
  end

  # def handle_info(domain_event, %State{} = state) do
  #   IO.inspect(domain_event, label: "UNKNWN ============================")
  #   {:noreply, state}
  # end

  # ----------  Implementation ------

  def via_tuple(list_id) do
    {:via, Registry, {LiveviewTodos.ListAggregateRegistry, "#{list_id}"}}
  end

  def list(%State{list_id: list_id, deps: deps}) do
    deps.repo.get_list(list_id)
  end
end
