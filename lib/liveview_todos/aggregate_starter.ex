defmodule LiveviewTodos.ListAggregateStarter do
  alias LiveviewTodos.List.Supervisor
  alias LiveviewTodos.TodoApplicationService, as: Service
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    Service.lists()
    |> Enum.each(fn list -> Supervisor.start_list_aggregate(list) end)

    # Returning :ignore will cause start_link/3 to return :ignore 
    # and the process will exit normally
    :ignore
  end
end
