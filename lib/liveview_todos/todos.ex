defmodule LiveviewTodos.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias LiveviewTodos.Repo

  alias LiveviewTodos.Todos.Todo
  alias LiveviewTodos.TodoTopic

  def list_todo do
    Repo.all(Todo)
  end

  def get_todo!(id), do: Repo.get!(Todo, id)

  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
    |> TodoTopic.broadcast_change([:todo, :created])
  end

  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
    |> TodoTopic.broadcast_change([:todo, :updated])
  end

  def delete_todo(%Todo{} = todo) do
    todo
    |> Repo.delete()
    |> TodoTopic.broadcast_change([:todo, :deleted])
  end

  def change_todo(%Todo{} = todo) do
    Todo.changeset(todo, %{})
  end
end
