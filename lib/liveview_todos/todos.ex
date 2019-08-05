defmodule LiveviewTodos.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias LiveviewTodos.Repo

  alias LiveviewTodos.Todos.Todo

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(LiveviewTodos.PubSub, @topic)
  end

  def broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(LiveviewTodos.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast_change({:error, changeset}, event) do
    Phoenix.PubSub.broadcast(LiveviewTodos.PubSub, @topic, {__MODULE__, event, :error, changeset})
    {:error, changeset}
  end

  def list_todo do
    Repo.all(Todo)
  end

  def get_todo!(id), do: Repo.get!(Todo, id)

  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:todo, :created])
  end

  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:todo, :updated])
  end

  def delete_todo(%Todo{} = todo) do
    todo
    |> Repo.delete()
    |> broadcast_change([:todo, :deleted])
  end

  def change_todo(%Todo{} = todo) do
    Todo.changeset(todo, %{})
  end
end
