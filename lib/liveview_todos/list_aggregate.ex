defmodule LiveviewTodos.ListAggregate do
  @moduledoc """
  Aggregates historical telemetry records
  """
  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  use GenServer, restart: :transient
  alias LiveviewTodos.List
  # alias LiveviewTodos.Todo
  require Logger

  # ---------  Client Interface  -------------

  def start_link(list) do
    GenServer.start_link(__MODULE__, list)
  end

  def create_list(name, deps \\ @deps) do
    result =
      %List{}
      |> List.changeset(%{name: name})
      |> deps.repo.insert()
      |> LiveviewTodos.List.Supervisor.start_list_aggregate()
      |> deps.topic.broadcast_change([:lists, :created])

    result
  end


  # ---------  Server  -------------

  def init(list) do
    Logger.info("Loading list #{list.name}")
    state = %{list_id: list.id, deps: @deps}
    {:ok, state}
  end

  def handle_cast(_request, state) do
    {:noreply, state}
  end

  # ----------  Implementation ------

  def via_tuple(list_id) do
    {:via, Registry, {LiveviewTodos.ListAggregateRegistry, list_id}}
  end

end
