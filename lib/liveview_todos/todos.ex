defmodule LiveviewTodos.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias LiveviewTodos.Repo
  alias LiveviewTodos.Todos.Todo

  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  def list_todo(deps \\ @deps) do
    deps.repo.all(Todo)
  end

  def get_todo!(id, deps \\ @deps) do
    deps.repo.get!(Todo, id)
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
end
