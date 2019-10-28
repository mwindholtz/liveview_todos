defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.Todo

  describe "todo" do
    @valid_attrs %{done: true, title: "some title", list_id: 1}
    @valid_item_attrs %{"description" => "description", "list_id" => "1"}

    @update_attrs %{done: false, title: "some updated title", list_id: 1}
    @invalid_attrs %{done: nil, title: nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Service.create_todo()

      todo
    end

    # test "list_todo/0 returns all todo" do
    #   todo = todo_fixture()
    #   assert Service.list_todo() == [todo]
    # end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Service.get_todo!(todo.id) == todo
    end

    test "create_item/1/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Service.create_item(@valid_item_attrs)
      assert todo.title == "description"
      assert todo.done == false
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Service.create_todo(@invalid_attrs)
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
      assert todo == Service.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Service.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Service.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Service.change_todo(todo)
    end
  end
end
