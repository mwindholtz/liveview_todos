defmodule LiveviewTodos.Repo do
  use Ecto.Repo,
    otp_app: :liveview_todos,
    adapter: Ecto.Adapters.Postgres

  alias LiveviewTodos.List

  def count(table) do
    aggregate(table, :count, :id)
  end

  def get_list(list_id) when is_integer(list_id) do
    get(List, list_id)
    |> preload(:items)
  end
end
