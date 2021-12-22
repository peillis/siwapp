defmodule SiwappWeb.MetaAttributesComponent do
  use SiwappWeb, :live_component

  def render(assigns) do
    ~H"""
    <fieldset>
      <%= for {k, v} <- @meta_attributes do %>
        <input type="text" name="meta[keys][]" value={k} />
        <input type="text" name="meta[values][]" value={v} />
        <a phx-click="remove" phx-value-key={k} phx-target={@myself}>Remove</a>
        <br/>
      <% end %>
      <input type="text" name="meta[keys][]" phx-blur="changing-key" phx-target={@myself} />
      <input type="text" name="meta[values][]" phx-blur="changing-value" phx-target={@myself} />
      <a phx-click="add" phx-target={@myself}>Add</a>
      <br/>
    </fieldset>
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

  def handle_event("add", _params, socket) do
    new =
      Map.put(socket.assigns.meta_attributes, socket.assigns.new_key, socket.assigns.new_value)

    send_update(__MODULE__, id: "meta_attributes", meta_attributes: new)

    {:noreply, socket}
  end
end
