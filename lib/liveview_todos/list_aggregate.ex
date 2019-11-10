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

  def accept(%DomainEvent{name: :create_list, attrs: name}) do
    create_list(name)
  end

  def create_list(name, deps \\ @deps) do
    result =
      %List{}
      |> List.changeset(%{name: name})
      |> deps.repo.insert()
      |> start_supervised_list_aggregate()
      |> deps.topic.broadcast_change([:lists, :created])

    result
  end

  defp start_supervised_list_aggregate({:ok, list}) do
    LiveviewTodos.List.Supervisor.start_list_aggregate(list.id)
    {:ok, list}
  end

  defp start_supervised_list_aggregate({:error, message}) do
    {:error, message}
  end

  def delete_list(list_id) do
    list_id
    |> via_tuple
    |> GenServer.cast(:delete_list)
  end

  def toggle_item(list_id, item_title) do
    list_id
    |> via_tuple
    |> GenServer.cast({:toggle_item, item_title})
  end

  def create_item(list_id, description) do
    list_id
    |> via_tuple
    |> GenServer.cast({:create_item, description})
  end

  # ---------  Server  -------------

  def init(list_id) when is_integer(list_id) do
    state = %State{list_id: list_id, name: "TBD", deps: @deps}
    {:ok, state, {:continue, list_id}}
  end

  def handle_continue(list_id, %State{deps: deps} = state) do
    list = deps.repo.get_list(list_id)

    state = %{state | name: list.name}
    {:noreply, state}
  end

  def handle_cast({:toggle_item, item_title}, %State{} = state) do
    do_toggle_item(state.list_id, item_title)
    {:noreply, state}
  end

  def handle_cast(:delete_list, %State{} = state) do
    list = list(state.list_id)
    List.delete(list)
    {:stop, :normal, state}
  end

  def handle_cast({:create_item, description}, %State{} = state) do
    list = list(state.list_id)

    {:ok, _todo} = List.create_item(list, %{"description" => description})

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

  def list(list_id, deps \\ @deps) do
    deps.repo.get_list(list_id)
  end

  def do_toggle_item(list_id, item_title, deps \\ @deps) do
    list = list(list_id, deps)
    List.toggle_item(list, item_title)
  end
end
