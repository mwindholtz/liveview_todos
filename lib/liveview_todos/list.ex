defmodule LiveviewTodos.List do
  @moduledoc """
  List is the Aggregate in our example app.
  It guarantees invarients.
  (1) When all items are done, the list should be marked as done
  (2) Each list has a WIP (Work in Process) Limit of 5 items, no more may be added

  And it does not reveal the details of the contained Entities (the Items).
  So no item ids will leak out of this Aggregate.
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
