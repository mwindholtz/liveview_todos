defmodule LiveviewTodos.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
