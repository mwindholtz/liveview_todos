defmodule LiveviewTodos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todo" do
    field :done, :boolean, default: false
    field :title, :string
    belongs_to(:list, LiveviewTodos.List)

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done, :list_id])
    |> validate_required([:title, :done, :list_id])
  end
end
