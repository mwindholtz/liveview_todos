defmodule LiveviewTodos.List do
  @moduledoc """
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    has_many(:items, LiveviewTodos.Todo, on_delete: :delete_all)
    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
