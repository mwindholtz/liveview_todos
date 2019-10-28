defmodule LiveviewTodosWeb.TodoLiveTest do
  use LiveviewTodosWeb.ConnCase
  alias LiveviewTodos.Todo
  alias LiveviewTodosWeb.TodoLive
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  defmodule TodoApplicationServiceStub do
    def get_item!(_list_id, title) do
      send(self(), {:get_item, title})
      %Todo{title: title}
    end

    def accept(event) do
      send(self(), {:accept, event})
      :ok
    end

    def create_list(attrs) do
      send(self(), {:create_list, attrs})
      :ok
    end

    def delete_list(attrs) do
      send(self(), {:delete_list, attrs})
      :ok
    end

    def create_item(attrs \\ %{}) do
      send(self(), {:create_item, attrs})
      {:ok, %Todo{}}
    end

    def update_todo(%Todo{} = todo, attrs) do
      send(self(), {:update_todo, todo, attrs})
      :update_todo
    end

    def toggle_item(list_id, item_title) do
      item = get_item!(String.to_integer(list_id), item_title)
      update_todo(item, %{done: !item.done})
    end
  end

  def socket_with_stub do
    %Socket{}
    |> LiveView.assign(:todo_application_service, TodoApplicationServiceStub)
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

      assert_receive {:delete_list, 99}
    end

    test "add-item" do
      item = %{title: "Buy milk and eggs", list_id: 1}

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

      assert_receive {:get_item, "title"}
      assert_receive {:update_todo, _todo, _attrs}
    end
  end
end
