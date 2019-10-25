defmodule LiveviewTodos.TodoTopic do
  @moduledoc """
  The TodoTopic
  """

  @topic inspect(LiveviewTodos.TodoTopic)

  def subscribe do
    Phoenix.PubSub.subscribe(LiveviewTodos.PubSub, @topic)
  end

  def broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(LiveviewTodos.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast_change({:error, changeset}, event) do
    Phoenix.PubSub.broadcast(LiveviewTodos.PubSub, @topic, {__MODULE__, event, :error, changeset})
    {:error, changeset}
  end
end
