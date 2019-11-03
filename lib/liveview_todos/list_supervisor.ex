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

  def start_list_aggregate(%List{id: list_id} = list) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {LiveviewTodos.ListAggregate, list}
    )
  end
end
