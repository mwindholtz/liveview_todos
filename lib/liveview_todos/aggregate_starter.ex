defmodule LiveviewTodos.ListAggregateStarter do
  alias LiveviewTodos.List.Supervisor
  alias LiveviewTodos.TodoApplicationService, as: Service
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    Service.list_ids()
    |> Enum.each(fn list_id -> Supervisor.start_list_aggregate(list_id) end)

    # Returning :ignore will cause start_link/3 to return :ignore 
    # and the process will exit normally
    :ignore
  end
end
