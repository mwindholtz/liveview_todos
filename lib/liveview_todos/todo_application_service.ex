defmodule LiveviewTodos.TodoApplicationService do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias LiveviewTodos.Todo
  alias LiveviewTodos.DomainEvent
  alias LiveviewTodos.List

  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  def accept(domain_event, deps \\ @deps)

  def accept(%DomainEvent{name: "create-list", attrs: attrs}, deps) do
    %List{}
    |> List.changeset(attrs)
    |> deps.repo.insert()
    |> deps.topic.broadcast_change([:lists, :created])

    :ok
  end

  def accept(%DomainEvent{name: "delete-list", attrs: %{list_id: list_id}}, deps) do
    list = deps.repo.get!(List, list_id)

    case deps.repo.delete(list) do
      {:ok, struct} ->
        deps.topic.broadcast_change({:ok, list}, [:lists, :deleted])
        :ok

      {:error, changeset} ->
        :error
    end
  end

  def accept(%DomainEvent{name: "create-item", attrs: attrs}, deps) do
    %List{}
    |> List.changeset(attrs)
    |> deps.repo.insert()
    |> deps.topic.broadcast_change([:todo, :created])

    :ok
  end

  def accept(event, deps) do
    IO.inspect("UNHANDED DOMAIN EVENT in Service================================= ")
    IO.inspect(event, label: "event")
    :ok
  end

  def create_item(%{"description" => description, "list_id" => list_id}, deps \\ @deps) do
    %Todo{}
    |> Todo.changeset(%{title: description, list_id: list_id})
    |> deps.repo.insert()
    |> deps.topic.broadcast_change([:todo, :created])
  end

  def create_todo(attrs \\ %{}, deps \\ @deps) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> deps.repo.insert()
    |> deps.topic.broadcast_change([:todo, :created])
  end

  def update_todo(%Todo{} = todo, attrs, deps \\ @deps) do
    todo
    |> Todo.changeset(attrs)
    |> deps.repo.update()
    |> deps.topic.broadcast_change([:todo, :updated])
  end

  def delete_todo(%Todo{} = todo, deps \\ @deps) do
    todo
    |> deps.repo.delete()
    |> deps.topic.broadcast_change([:todo, :deleted])
  end

  def change_todo(%Todo{} = todo) do
    Todo.changeset(todo, %{})
  end

  def list_todo(deps \\ @deps) do
    deps.repo.all(Todo)
  end

  def lists(deps \\ @deps) do
    List
    |> deps.repo.all()
    |> deps.repo.preload(:items)
  end

  def get_todo!(id, deps \\ @deps) do
    deps.repo.get!(Todo, id)
  end
end
