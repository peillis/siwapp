defmodule SiwappWeb.MultiselectComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.LiveView.JS

  def update(assigns, socket) do
    "ms-" <> index = assigns.id

    socket =
      socket
      |> assign(selected: MapSet.new(assigns.selected))
      |> assign(name: assigns.name)
      |> assign(index: index)
      |> assign(options: MapSet.new(assigns.options))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="control msa-wrapper">
      <%= for {k, _v} <- @selected do %>
        <input type="hidden" name={"#{@name}[]"} value={k}>
      <% end %>
      <div class="input input-presentation" phx-click={JS.toggle(to: "#tag-list-#{@index}")}>
        <span class="placeholder"></span>
        <%= for {k, v} <- @selected do %>
          <div class="tag-badge">
            <span><%= k %></span>
            <button type="button" phx-click={JS.push("remove", target: @myself, value: %{index: @index, key: k, val: v})}>x</button>
          </div>
        <% end %>
      </div>
      <ul id={"tag-list-#{@index}"} class="tag-list" style="display: none;">
        <%= for {k, v} <- not_selected(@options, @selected) do %>
          <li phx-click={JS.push("add", target: @myself, value: %{index: @index, key: k, val: v}) |> JS.toggle(to: "#tag-list-#{@index}")}><%= k %></li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("remove", %{"index" => index, "key" => key, "val" => value}, socket) do
    selected = MapSet.delete(socket.assigns.selected, {key, value})

    send(
      self(),
      {:taxes_updated,
       %{index: String.to_integer(index), selected: Enum.map(selected, fn {k, _v} -> k end)}}
    )

    {:noreply, assign(socket, :selected, selected)}
  end

  def handle_event("add", %{"index" => index, "key" => key, "val" => value}, socket) do
    selected = MapSet.put(socket.assigns.selected, {key, value})

    send(
      self(),
      {:taxes_updated,
       %{index: String.to_integer(index), selected: Enum.map(selected, fn {k, _v} -> k end)}}
    )

    {:noreply, assign(socket, :selected, selected)}
  end

  defp not_selected(options, selected) do
    MapSet.difference(options, selected)
  end
end
