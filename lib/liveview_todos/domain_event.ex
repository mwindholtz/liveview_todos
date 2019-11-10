defmodule LiveviewTodos.DomainEvent do
  @enforce_keys [:name, :attrs]
  defstruct name: :not_set, attrs: %{}

  def new(name, attrs) do
    %LiveviewTodos.DomainEvent{name: name, attrs: attrs}
  end
end
