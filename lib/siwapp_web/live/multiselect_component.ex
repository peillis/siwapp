defmodule SiwappWeb.MultiselectComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.LiveView.JS

  def update(assigns, socket) do
    socket =
      socket
      |> assign(selected: [])
      |> assign(not_selected: [])
      |> assign(options: assigns.options)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="msa-wrapper">
      <label for="msa-input">Choose some cars:</label>
      <input type="hidden" id="msa-input">
      <div class="input-presentation" phx-click={JS.toggle(to: "#tag-list")}>
        <span class="placeholder">Select Tags</span>
        <div class="tag-badge">
          <span>saab</span>
          <button>x</button>
        </div>
        <div class="tag-badge">
          <span>Seat</span>
          <button>x</button>
        </div>
      </div>
      <ul id="tag-list" style="display: none;">
        <%= for {k, v} <- @options do %>
        <li><%= k %></li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("remove", %{"key" => key}, socket) do
    new = Map.delete(socket.assigns.meta_attributes, key)
    send_update(__MODULE__, id: "meta_attributes", meta_attributes: new)

    {:noreply, socket}
  end

  def handle_event("changing-key", %{"value" => value}, socket) do
    {:noreply, assign(socket, :new_key, value)}
  end

  def handle_event("changing-value", %{"value" => value}, socket) do
    {:noreply, assign(socket, :new_value, value)}
  end

  def handle_event("add", _params, %{assigns: assigns} = socket) do
    new =
      case assigns.new_key do
        "" ->
          assigns.meta_attributes

        _ ->
          Map.put(
            assigns.meta_attributes,
            assigns.new_key,
            assigns.new_value
          )
      end

    send_update(__MODULE__, id: "meta_attributes", meta_attributes: new)

    {:noreply, socket}
  end
end
