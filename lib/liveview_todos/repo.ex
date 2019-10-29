defmodule LiveviewTodos.Repo do
  use Ecto.Repo,
    otp_app: :liveview_todos,
    adapter: Ecto.Adapters.Postgres

  def count(table) do
    aggregate(table, :count, :id)
  end
end
