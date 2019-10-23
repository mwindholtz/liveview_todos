defmodule LiveviewTodosWeb.TodoLiveTest do
  use LiveviewTodosWeb.ConnCase
  alias LiveviewTodos.Todos.Todo
  alias LiveviewTodosWeb.TodoLive
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  defmodule TodosStub do
    def create_todo(attrs \\ %{}) do
      send(self(), {:create_todo, attrs})
      {:ok, %Todo{}}
    end

    def update_todo(%Todo{} = todo, attrs) do
      send(self(), {:update_todo, todo, attrs})
      :update_todo
    end

    def delete_todo(%Todo{} = todo) do
      send(self(), {:delete_todo, todo})
      :delete_todo
    end

    def change_todo(%Todo{} = todo) do
      send(self(), {:change_todo, todo})
      :change_todo
    end
  end

  def socket_with_stub do
    %Socket{}
    |> LiveView.assign(:todos, TodosStub)
  end

  test "TodoLive.handle_event(inc ..." do
    todo = %{title: "Buy milk and eggs"}
    {:noreply, _mod_socket} = TodoLive.handle_event("add", %{"todo" => todo}, socket_with_stub())

    assert_receive {:create_todo, attrs}
  end
end
