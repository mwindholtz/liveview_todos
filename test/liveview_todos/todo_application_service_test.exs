defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service
  alias LiveviewTodos.DomainEvent

  @wait_for_db_to_finish 100

  def wait_for_db_to_finish do
    Process.sleep(@wait_for_db_to_finish)
  end

  setup do
    LiveviewTodos.TodoTopic.subscribe()
    :ok
  end

  describe "item" do
    setup do
      event = DomainEvent.new(:create_list, "Homework", __MODULE__)
      {:ok, list} = Service.accept(event)

      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}

      attrs = %{"description" => "description", "list_id" => list.id}
      %{attrs: attrs}
    end

    test "get_item!/2", %{attrs: attrs} do
      :ok = Service.create_item(attrs)

      assert_receive {LiveviewTodos.TodoTopic, [:todo, :created], todo}
      assert todo.title == "description"
      wait_for_db_to_finish()
    end

    test "create_item/1", %{attrs: attrs} do
      :ok = Service.create_item(attrs)
      assert_receive {LiveviewTodos.TodoTopic, [:todo, :created], todo}
      wait_for_db_to_finish()
    end
  end

  describe "list" do
    setup do
      name_of_list = "Grocery"
      event = DomainEvent.new(:create_list, name_of_list, __MODULE__)

      {:ok, list} = Service.accept(event)
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}

      %{list: list, name_of_list: name_of_list}
    end

    test "create_list/1" do
      name_of_list = "School"
      event = DomainEvent.new(:create_list, name_of_list, __MODULE__)
      {:ok, _list} = Service.accept(event)

      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}
      wait_for_db_to_finish()
    end

    test "delete_list/1",
         %{list: list} do
      Service.delete_list(list.id)
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :deleted], new_list}
      wait_for_db_to_finish()
    end

    test "lists()", %{list: list} do
      [result | _] = Service.lists()

      assert list.name == result.name
      wait_for_db_to_finish()
    end
  end
end
