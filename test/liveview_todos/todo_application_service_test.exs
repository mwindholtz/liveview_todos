defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.List

  setup do
    LiveviewTodos.TodoTopic.subscribe()
    :ok
  end

  describe "item" do
    setup do
      {:ok, list} = Service.create_list("Homework")
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}

      attrs = %{"description" => "description", "list_id" => list.id}
      %{attrs: attrs}
    end

    test "get_item!/2", %{attrs: attrs} do
      :ok = Service.create_item(attrs)

      assert_receive {LiveviewTodos.TodoTopic, [:todo, :created], todo}
      assert todo.title == "description"
    end

    test "create_item/1", %{attrs: attrs} do
      assert :ok = Service.create_item(attrs)
      assert_receive {LiveviewTodos.TodoTopic, [:todo, :created], todo}
    end
  end

  describe "list" do
    setup do
      name_of_list = "Grocery"
      {:ok, list} = Service.create_list(name_of_list)
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}

      %{list: list, name_of_list: name_of_list}
    end

    test "create_list/1" do
      name_of_list = "School"

      Service.create_list(name_of_list)
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}
    end

    test "delete_list/1",
         %{list: list} do
      Service.delete_list(list.id)
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :deleted], new_list}
    end

    test "lists()", %{list: list} do
      [result | _] = Service.lists()

      assert list.name == result.name
    end
  end
end
