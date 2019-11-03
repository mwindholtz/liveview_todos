defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.List

  describe "item" do
    setup do
      {:ok, list} = Service.create_list("Homework")
      attrs = %{"description" => "description", "list_id" => list.id}
      %{attrs: attrs}
    end

    test "get_item!/2", %{attrs: attrs} do
      LiveviewTodos.TodoTopic.subscribe()
      :ok = Service.create_item(attrs)

      assert_receive {LiveviewTodos.TodoTopic, [:todo, :created], todo}
      assert todo.title == "description"
    end

    test "create_item/1", %{attrs: attrs} do
      #      assert_repo_changed(Todo, 1, fn ->
      assert :ok = Service.create_item(attrs)
      # assert todo.title == "description"
      # assert todo.done == false
      #     end)
      Process.sleep(200)
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
        Process.sleep(200)
      end)
    end

    test "lists()", %{list: list} do
      [result | _] = Service.lists()

      assert list.name == result.name
    end
  end
end
