defmodule LiveviewTodosWeb.TodoLiveTest do
  use LiveviewTodosWeb.ConnCase
  alias LiveviewTodos.Todo
  alias LiveviewTodosWeb.TodoLive
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket
  alias LiveviewTodos.DomainEvent

  defmodule TodosStub do
    def get_todo!(item_id) do
      send(self(), {:get_todo, item_id})
      %Todo{id: item_id}
    end

    def accept(event) do
      send(self(), {:accept, event})
      :ok
    end

    def create_item(attrs \\ %{}) do
      send(self(), {:create_todo, attrs})
      {:ok, %Todo{}}
    end

    def update_todo(%Todo{} = todo, attrs) do
      send(self(), {:update_todo, todo, attrs})
      :update_todo
    end

    def delete_todo(%Todo{} = todo) do
      send(self(), {:delete_todo, todo})
      :delete_todo
    end

    def change_todo(%Todo{} = todo) do
      send(self(), {:change_todo, todo})
      :change_todo
    end
  end

  def socket_with_stub do
    %Socket{}
    |> LiveView.assign(:todo_application_service, TodosStub)
  end

  describe "TodoLive.handle_event" do
    test "create-list" do
      attrs = %{name: "Home stuff"}

      {:noreply, _mod_socket} =
        TodoLive.handle_event("create-list", %{"list" => attrs}, socket_with_stub())

      assert_receive {:accept, %DomainEvent{name: "create-list", attrs: attrs}}
    end

    test "add" do
      item = %{title: "Buy milk and eggs", list_id: 1}

      {:noreply, _mod_socket} =
        TodoLive.handle_event("add", %{"item" => item}, socket_with_stub())

      assert_receive {:create_todo, attrs}
    end

    test "toggle_done" do
      {:noreply, _mod_socket} =
        TodoLive.handle_event("toggle_done", %{"item-id" => "99"}, socket_with_stub())

      assert_receive {:get_todo, 99}
      assert_receive {:update_todo, _todo, _attrs}
    end
  end
end
