defmodule LiveviewTodos.TodoApplicationService do
  @moduledoc """
  This module is in the ApplicationService Layer
  Application Service Layer is responsible for .. 
  ... TODO:
  ... more stuff about Repos and transactions and Workflow ... blah, blah.
  ...
  Find or create the Aggregate in the Model, send it a request.  Wait if needed.
  In this app, the Aggregate is the "List"
  So the TodoApplicationService will only connect to the List
  """

  import Ecto.Query, warn: false
  alias LiveviewTodos.List
  alias LiveviewTodos.ListAggregate
  alias LiveviewTodos.DomainEvent

  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  def accept(domain_event, deps \\ @deps)

  def accept(%DomainEvent{name: :create_list, attrs: name}, deps) do
    result =
      %List{}
      |> List.changeset(%{name: name})
      |> deps.repo.insert()
      |> start_supervised_list_aggregate()
      |> deps.topic.broadcast_change([:lists, :created])

    result
  end

  def accept(%DomainEvent{} = event, _deps) do
    ListAggregate.accept(event)
  end

  def list_ids(deps \\ @deps) do
    # WIP TODO
    deps.repo.list_ids()
  end

  def get_list(list_id, deps \\ @deps) do
    deps.repo.get_list(list_id)
  end

  defp start_supervised_list_aggregate({:ok, list}) do
    LiveviewTodos.List.Supervisor.start_list_aggregate(list.id)
    {:ok, list}
  end

  # TODO: MOVE TO Service
  defp start_supervised_list_aggregate({:error, message}) do
    {:error, message}
  end
end
