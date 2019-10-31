defmodule LiveviewTodos.TodoApplicationService do
  @moduledoc """
  This modeule is in the ApplicationService Layer
  Application Service Layer is responsible for .. 
  ... TODO:
  ... more stuff about Repos and transactions and Workflow ... blah, blah.
  ...
  Find or create the Aggregate in the Model, send it a request.  Wait if needed.
  In this app, the Aggregate is the "List"
  So the TodoApplicationService will only connect to the List
  """

  import Ecto.Query, warn: false
  alias LiveviewTodos.Todo
  alias LiveviewTodos.List

  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  def create_list(name, _deps \\ @deps) do
    LiveviewTodos.ListAggregate.create_list(name)
  end

  def delete_list(list_id, deps \\ @deps) do
    list = list(list_id, deps)
    List.delete(list)
  end

  def create_item(%{"description" => description, "list_id" => list_id}, deps \\ @deps) do
    list = list(list_id, deps)
    List.create_item(list, %{"description" => description})
  end

  def list(list_id, deps \\ @deps) do
    deps.repo.get!(List, list_id)
  end

  def lists(deps \\ @deps) do
    List
    |> deps.repo.all()
    |> deps.repo.preload(:items)
  end

  def get_item!(list_id, text, deps \\ @deps) do
    query = from(t in Todo, where: [list_id: ^list_id, title: ^text])
    deps.repo.one!(query)
  end

  def toggle_item(list_id, item_title, deps \\ @deps) do
    list = list(list_id, deps)
    List.toggle_item(list, item_title)
  end
end
