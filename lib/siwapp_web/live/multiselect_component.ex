defmodule SiwappWeb.MultiselectComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.LiveView.JS

  def update(assigns, socket) do
    socket =
      socket
      |> assign(selected: MapSet.new(assigns.selected))
      |> assign(name: assigns.name)
      |> assign(id: assigns.id)
      |> assign(options: MapSet.new(assigns.options))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="control msa-wrapper">
      <%= for {k, _v} <- @selected do %>
        <input type="hidden" id="hidden_input" name={"#{@name}[]"} value={k}>
      <% end %>
      <div class="input input-presentation" phx-click={JS.toggle(to: "#tag-list-#{@id}")}>
        <span class="placeholder"></span>
        <%= for {k, v} <- @selected do %>
          <div class="tag-badge">
            <span>
              <%= k %>
            </span>
            <button type="button" phx-click={JS.push("remove", target: @myself, value: %{key: k, val: v})}>
              x
            </button>
          </div>
        <% end %>
      </div>
      <ul id={"tag-list-#{@id}"} class="tag-list" style="display: none;">
        <%= for {k, v} <- not_selected(@options, @selected) do %>
          <li phx-click={JS.push("add", target: @myself, value: %{key: k, val: v}) |> JS.toggle(to: "#tag-list-#{@id}")}>
            <%= k %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("remove", %{"key" => key, "val" => value}, socket) do
    {key, value} = convert({key, value})

    {:noreply, update(socket, :selected, &MapSet.delete(&1, {key, value}))}
  end

  def handle_event("add", %{"key" => key, "val" => value}, socket) do
    {key, value} = convert({key, value})

    {:noreply, update(socket, :selected, &MapSet.put(&1, {key, value}))}
  end

  defp convert({key, value}) do
    {String.to_atom(key), value}
  end

  defp not_selected(options, selected) do
    MapSet.difference(options, selected)
  end
end
