defmodule LiveviewTodos.Repo.Migrations.AddListIdToTodos do
  use Ecto.Migration

  def change do
    alter table(:todo) do
      add(:list_id, :integer)
    end
  end
end
