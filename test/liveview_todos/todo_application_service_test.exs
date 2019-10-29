defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.Todo
  alias LiveviewTodos.List

  describe "item" do
    @valid_item_attrs %{"description" => "description", "list_id" => "1"}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_item_attrs)
        |> Service.create_item()

      todo
    end

    test "get_item!/2" do
      todo = todo_fixture()
      result = Service.get_item!(todo.list_id, todo.title)
      assert result == todo
    end

    test "create_item/1" do
      assert_repo_changed(Todo, 1, fn ->
        assert {:ok, %Todo{} = todo} = Service.create_item(@valid_item_attrs)
        assert todo.title == "description"
        assert todo.done == false
      end)
    end
  end

  describe "list" do
    setup do
      name_of_list = "Grocery"
      {:ok, list} = Service.create_list(name_of_list)

      %{list: list, name_of_list: name_of_list}
    end

    test "create_list/1" do
      name_of_list = "School"

      assert_repo_changed(List, 1, fn ->
        result = Service.create_list(name_of_list)
        assert {:ok, %List{} = list} = result
        assert list.name == name_of_list
      end)
    end

    test "delete_list/1",
         %{list: list} do
      assert_repo_changed(List, -1, fn ->
        Service.delete_list(list.id)
      end)
    end

    test "lists()", %{list: list} do
      [result | _] = Service.lists()

      assert list.name == result.name
    end
  end
end
