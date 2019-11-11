defmodule LiveviewTodosWeb.TodoLiveTest do
  use LiveviewTodosWeb.ConnCase
  alias LiveviewTodos.DomainEvent
  alias LiveviewTodosWeb.TodoLive
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket
  import ExUnit.CaptureLog

  @topic LiveviewTodosWeb.TodoLive.topic()

  defmodule TodoApplicationServiceStub do
    def create_list(name) do
      send(self(), {:create_list, name})
      :ok
    end

    def accept(%DomainEvent{} = event) do
      send(self(), {event.name, event})
      :ok
    end
  end

  defmodule CommandStub do
    def refresh_lists(%Socket{} = socket) do
      send(self(), {:refresh_lists, socket})
      :ok
    end
  end

  def socket_with_stub do
    %Socket{}
    |> LiveView.assign(:todo_application_service, TodoApplicationServiceStub)
    |> LiveView.assign(:command, CommandStub)
  end

  describe "TodoLive.handle_event" do
    test "create-list" do
      name = "Home stuff"
      attrs = %{"name" => name}

      {:noreply, _mod_socket} =
        TodoLive.handle_event("create-list", %{"list" => attrs}, socket_with_stub())

      assert_receive {:create_list, name}
    end

    test "delete-list" do
      attrs = %{"list-id" => "99"}
      {:noreply, _mod_socket} = TodoLive.handle_event("delete-list", attrs, socket_with_stub())

      assert_receive {:delete_list,
                      %LiveviewTodos.DomainEvent{
                        attrs: %{list_id: 99},
                        name: :delete_list
                      }}
    end

    test "add-item" do
      item = %{"description" => "Buy milk and eggs", "list_id" => "1"}

      {:noreply, _mod_socket} =
        TodoLive.handle_event("add-item", %{"item" => item}, socket_with_stub())

      assert_receive {:create_item, attrs}
    end

    test "toggle_done" do
      {:noreply, _mod_socket} =
        TodoLive.handle_event(
          "toggle_done",
          %{"list-id" => "99", "item-title" => "title"},
          socket_with_stub()
        )

      assert_receive {:toggle_item,
                      %LiveviewTodos.DomainEvent{
                        attrs: %{item_title: "title", list_id: 99},
                        name: :toggle_item
                      }}
    end
  end

  describe "TodoLive.handle_info" do
    test "UNHANDED" do
      expected_log_message = "UNHANDED PUBSUB TUPLE: {:unexpected, 99}"
      # When 
      log =
        capture_log(fn ->
          TodoLive.handle_info({:unexpected, 99}, socket_with_stub())
        end)

      assert log =~ expected_log_message
    end

    test "call refresh_lists for lists :ok events" do
      # When 
      {:noreply, _mod_socket} =
        TodoLive.handle_info({@topic, [:lists, nil], :ok}, socket_with_stub())

      assert_receive {:refresh_lists, _socket}
    end

    test "call refresh_lists for lists :error events" do
      # When 
      {:noreply, _mod_socket} =
        TodoLive.handle_info({@topic, [:lists, nil], :error}, socket_with_stub())

      assert_receive {:refresh_lists, _socket}
    end

    test "call refresh_lists for todo :error events" do
      # When 
      {:noreply, _mod_socket} =
        TodoLive.handle_info({@topic, [:todo, nil], :error}, socket_with_stub())

      assert_receive {:refresh_lists, _socket}
    end

    test "call refresh_lists for todo :ok events" do
      # When 
      {:noreply, _mod_socket} =
        TodoLive.handle_info({@topic, [:todo, nil], :ok}, socket_with_stub())

      assert_receive {:refresh_lists, _socket}
    end
  end

  # WIP, needs test for LiveviewTodosWeb.TodoLive.Command
end
