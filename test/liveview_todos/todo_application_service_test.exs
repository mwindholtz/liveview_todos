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
      {:ok, list} = Service.create_list("Homework")

      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}

      attrs = %{description: "description", list_id: list.id}
      %{attrs: attrs}
    end

    test "create_item/1", %{attrs: attrs} do
      # When
      DomainEvent.new(:create_item, attrs)
      |> Service.accept()

      assert_receive {LiveviewTodos.TodoTopic, [:todo, :created], new_list}

      wait_for_db_to_finish()
    end

    # WIP TODO needs toggle
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
      # When
      Service.create_list(name_of_list)

      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], new_list}
      wait_for_db_to_finish()
    end

    test "delete_list/1", %{list: list} do
      event = DomainEvent.new(:delete_list, %{list_id: list.id})
      Service.accept(event)
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :deleted], old_list}
      assert old_list.name == list.name
      wait_for_db_to_finish()
    end
  end
end
