defmodule LiveviewTodos.Repo do
  use Ecto.Repo,
    otp_app: :liveview_todos,
    adapter: Ecto.Adapters.Postgres
end
