defmodule LiveviewTodos.TargetedTopic do
  @moduledoc """
  The TargetedTopic
  """
  @topic inspect(LiveviewTodos.TargetedTopic)
  @pubsub_name LiveviewTodos.PubSub

  def subscribe_for(list_id, pid, pubsub_name \\ @pubsub_name) when is_pid(pid) do
    topic = topic_with_id(list_id)
    :ok = Phoenix.PubSub.subscribe(pubsub_name, pid, topic)
  end

  def subscribe(list_id, pubsub_name \\ @pubsub_name) do
    topic = topic_with_id(list_id)
    :ok = Phoenix.PubSub.subscribe(pubsub_name, topic)
  end

  def broadcast(id, domain_event, pubsub_name \\ @pubsub_name) do
    topic = topic_with_id(id)
    :ok = Phoenix.PubSub.broadcast(pubsub_name, topic, domain_event)
  end

  def unsubscribe(id, pubsub_name \\ @pubsub_name) do
    topic = topic_with_id(id)
    :ok = Phoenix.PubSub.unsubscribe(pubsub_name, topic)
  end

  def topic_with_id(list_id) when is_integer(list_id) do
    "#{@topic}:#{list_id}"
  end

  # not an integer
  def topic_with_id(list_id) do
    list_id
    |> String.to_integer()
    |> topic_with_id()
  end
end
