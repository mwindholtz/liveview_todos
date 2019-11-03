defmodule LiveviewTodos.ListAggregate do
  @moduledoc """
  Aggregates historical telemetry records
  """
  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  use GenServer, restart: :transient
  alias LiveviewTodos.List
  alias LiveviewTodos.ListAggregate.State
  require Logger

  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  defmodule State do
    @enforce_keys [:list_id, :name, :deps]
    defstruct [:list_id, :name, :deps]
  end

  # ---------  Client Interface  -------------

  def start_link(list) do
    GenServer.start_link(__MODULE__, list, name: via_tuple(list.id))
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

  defp start_supervised_list_aggregate({:ok, list}) do
    LiveviewTodos.List.Supervisor.start_list_aggregate(list)
    {:ok, list}
  end

  defp start_supervised_list_aggregate({:error, message}) do
    {:error, message}
  end

  # ---------  Server  -------------

  def init(%List{} = list) do
    Logger.info("Loading list #{list.name}")
    state = %State{list_id: list.id, name: list.name, deps: @deps}
    {:ok, state}
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
