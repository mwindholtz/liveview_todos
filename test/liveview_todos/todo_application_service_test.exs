defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.Todo

  describe "todo" do
    @valid_item_attrs %{"description" => "description", "list_id" => "1"}

    @update_attrs %{done: false, title: "some updated title", list_id: 1}
    @invalid_attrs %{"description" => nil, "list_id" => nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_item_attrs)
        |> Service.create_item()

      todo
    end

    test "get_todo2!/2 returns the todo with given id" do
      todo = todo_fixture()
      result = Service.get_todo2!(todo.list_id, todo.title)
      assert result == todo
    end

    test "create_item/1/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Service.create_item(@valid_item_attrs)
      assert todo.title == "description"
      assert todo.done == false
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Service.create_item(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = Service.update_todo(todo, @update_attrs)
      assert todo.done == false
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Service.update_todo(todo, @invalid_attrs)
      assert todo == Service.get_todo2!(todo.list_id, todo.title)
    end

    test "delete_todo/1 deletes the todo" do
      todo = %{todo_fixture() | title: "delete_todo"}
      assert {:ok, %Todo{}} = Service.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Service.get_todo2!(todo.list_id, todo.title) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Service.change_todo(todo)
    end
  end
end
