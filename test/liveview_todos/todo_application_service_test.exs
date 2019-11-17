defmodule LiveviewTodos.TodoApplicationServiceTest do
  use LiveviewTodos.DataCase
  alias LiveviewTodos.DomainEvent

  alias LiveviewTodos.TodoApplicationService, as: Service

  @wait_for_db_to_finish 100

  def wait_for_db_to_finish do
    Process.sleep(@wait_for_db_to_finish)
  end

  setup do
    :ok
  end

  describe "item" do
    setup do
      {:ok, list} = Service.create_list("Homework", self())
      attrs = %{description: "description", list_id: list.id}
      %{attrs: attrs}
    end
  end

  describe "list" do
    setup do
      name_of_list = "Grocery"
      {:ok, list} = Service.create_list(name_of_list, self())

      assert_receive %DomainEvent{name: :list_created, attrs: %{list_id: list_id_from_event}}

      %{list: list, name_of_list: name_of_list}
    end

    @tag :skip
    test "create_list/1" do
      name_of_list = "School"
      # When
      {:ok, result_list} = Service.create_list(name_of_list, self())

      # Then 
      assert_receive %DomainEvent{name: :list_created, attrs: %{list_id: list_id_from_event}}
      assert result_list.id == list_id_from_event
      wait_for_db_to_finish()
    end
  end
end
