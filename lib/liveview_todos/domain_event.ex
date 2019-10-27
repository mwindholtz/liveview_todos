defmodule LiveviewTodos.DomainEvent do
  defstruct name: :not_set, attrs: []

  def new(name, attrs) do
    %LiveviewTodos.DomainEvent{name: name, attrs: attrs}
  end
end
