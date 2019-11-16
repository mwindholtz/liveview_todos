defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase

  alias LiveviewTodos.TodoApplicationService, as: Service

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
      result = Service.create_list(name_of_list)

      # Then 
      assert {:ok, result_list} = result
      assert_receive {LiveviewTodos.TodoTopic, [:lists, :created], list_from_event}
      assert result_list == list_from_event
      wait_for_db_to_finish()
    end
  end
end
