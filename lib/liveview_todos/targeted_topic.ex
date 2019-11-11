defmodule LiveviewTodos.TargetedTopic do
  @moduledoc """
  The TargetedTopic
  """
  @topic inspect(LiveviewTodos.TargetedTopic)
  @pubsub_name LiveviewTodos.PubSub

  def subscribe(id, pubsub_name \\ @pubsub_name) do
    topic = topic_with_id(id)
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

  def topic_with_id(id) do
    "#{@topic}:#{id}"
  end
end
