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

  def accept(%DomainEvent{} = event) do
    ListAggregate.accept(event)
  end

  def list_ids(deps \\ @deps) do
    # WIP TODO
    deps.repo.list_ids()
  end

  def get_list(list_id, deps \\ @deps) do
    deps.repo.get_list(list_id)
  end
end
