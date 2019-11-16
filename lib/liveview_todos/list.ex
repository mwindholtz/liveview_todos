defmodule LiveviewTodos.List do
  @moduledoc """
  List is the AggregateRoot in our example app.
  It guarantees invarients.
  (1) When all items are done, the list should be marked as done
  (2) Each list has a WIP (Work in Process) Limit of 5 items, no more may be added

  And it does not reveal the details of the contained Entities (the Items).
  So no item ids will leak out of this Aggregate.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveviewTodos.List
  alias LiveviewTodos.Todo
  alias LiveviewTodos.DomainEvent
  alias LiveviewTodos.TargetedTopic

  @deps %{repo: LiveviewTodos.Repo, topic: LiveviewTodos.TodoTopic}

  schema "lists" do
    field :name, :string
    has_many(:items, LiveviewTodos.Todo, on_delete: :delete_all)
    timestamps()
  end

  def create_list(name, deps \\ @deps) do
    result =
      %List{}
      |> List.changeset(%{name: name})
      |> deps.repo.insert()
      |> deps.topic.broadcast_change([:lists, :created])

    {:ok, list} = result
    broadcast(:list_created, %{list_id: list.id})
    result
  end

  def create_item(list, %{"description" => description}, deps \\ @deps) do
    %Todo{}
    |> Todo.changeset(%{title: description, list_id: list.id})
    |> deps.repo.insert()

    broadcast(:todo_created, %{list_id: list.id, title: description})
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def delete(list, deps \\ @deps) do
    case deps.repo.delete(list) do
      {:ok, _struct} ->
        deps.topic.broadcast_change({:ok, list}, [:lists, :deleted])
        broadcast(:list_deleted, %{list_id: list.id})
        :ok

      {:error, _changeset} ->
        :error
    end
  end

  def toggle_item(list, item_title, deps \\ @deps) do
    item =
      list.items
      |> Enum.find(fn item -> item.title == item_title end)

    item
    |> Todo.changeset(%{done: !item.done})
    |> deps.repo.update()

    broadcast(:list_item_toggled, %{list_id: list.id})
  end

  defp broadcast(event_name, %{list_id: list_id} = attrs) do
    domain_event = %DomainEvent{name: event_name, attrs: attrs}
    TargetedTopic.broadcast(list_id, domain_event)
  end
end
