defmodule LiveviewTodos.TodoApplicationService do
  @moduledoc """
  This module is in the ApplicationService Layer
  Application Service Layer is responsible for .. 
  ... TODO:
  ... more stuff about Repos and transactions and Workflow ... blah, blah.
  ...
  Find or create the Aggregate in the Model, send it a request.  Wait if needed.
  In this app, the Aggregate is the "List"
  So the TodoApplicationService will only connect to the List
  """

  alias LiveviewTodos.List
  alias LiveviewTodos.TargetedTopic

  @deps %{repo: LiveviewTodos.Repo}

  def create_list(name, observer_pid, deps \\ @deps) when is_pid(observer_pid) do
    {:ok, list} =
      List.create_list(name)
      |> start_supervised_list_aggregate()

    TargetedTopic.subscribe_for(list.id, observer_pid)

    {:ok, list}
  end

  def list_ids(deps \\ @deps) do
    deps.repo.list_ids()
  end

  def get_list(list_id, deps \\ @deps) do
    deps.repo.get_list(list_id)
  end

  defp start_supervised_list_aggregate({:ok, list}) do
    LiveviewTodos.List.Supervisor.start_list_aggregate(list.id)
    {:ok, list}
  end

  defp start_supervised_list_aggregate({:error, message}) do
    {:error, message}
  end
end
