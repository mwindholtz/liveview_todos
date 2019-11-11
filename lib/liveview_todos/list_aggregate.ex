defmodule LiveviewTodos.ListAggregate do
  @moduledoc """
  """
  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  use GenServer, restart: :transient
  alias LiveviewTodos.List
  alias LiveviewTodos.ListAggregate.State
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

  def accept(%DomainEvent{attrs: %{list_id: list_id}} = event) do
    list_id
    |> via_tuple
    |> GenServer.cast({:domain_event, event})
  end

  # ---------  Server  -------------

  def init(list_id) when is_integer(list_id) do
    state = %State{list_id: list_id, name: "TBD", deps: @deps}
    {:ok, state, {:continue, list_id}}
  end

  def handle_continue(list_id, %State{} = state) do
    list = list(state)

    state = %{state | name: list.name}
    {:noreply, state}
  end

  def handle_cast(
        {:domain_event, %DomainEvent{name: :toggle_item, attrs: attrs}},
        %State{} = state
      ) do
    state
    |> list()
    |> List.toggle_item(attrs.item_title)

    {:noreply, state}
  end

  def handle_cast(
        {:domain_event, %DomainEvent{name: :delete_list}},
        %State{} = state
      ) do
    state
    |> list()
    |> List.delete()

    {:stop, :normal, state}
  end

  def handle_cast(
        {:domain_event, %DomainEvent{name: :create_item, attrs: %{description: description}}},
        %State{} = state
      ) do
    {:ok, _todo} =
      state
      |> list()
      |> List.create_item(%{"description" => description})

    {:noreply, state}
  end

  def handle_cast(request, %State{} = state) do
    Logger.error("UNEXPECTED REQUEST: #{inspect(request)}")
    {:noreply, state}
  end

  # ----------  Implementation ------

  def via_tuple(list_id) do
    {:via, Registry, {LiveviewTodos.ListAggregateRegistry, "#{list_id}"}}
  end

  def list(%State{list_id: list_id, deps: deps}) do
    deps.repo.get_list(list_id)
  end
end
