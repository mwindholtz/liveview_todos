defmodule LiveviewTodos.List.Supervisor do
  use DynamicSupervisor
  alias LiveviewTodos.List

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    result = DynamicSupervisor.init(strategy: :one_for_one)

    result
  end

  def start_list_aggregate(list_id) when is_integer(list_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {LiveviewTodos.ListAggregate, list_id}
    )
  end
end
