defmodule LiveviewTodos.DomainEvent do
  @enforce_keys [:name, :attrs]
  defstruct name: :not_set, attrs: [], source: :not_set

  def new(name, attrs, source) do
    %LiveviewTodos.DomainEvent{name: name, attrs: attrs, source: source}
  end
end
