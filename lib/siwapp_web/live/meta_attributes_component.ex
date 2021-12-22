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
      <input type="text" name="meta[keys][]" />
      <input type="text" name="meta[values][]" />
      <br/>
    </fieldset>
    """
  end

  def handle_event("remove", %{"key" => key}, socket) do
    new_meta_attributes = Map.delete(socket.assigns.meta_attributes, key)
    send_update(__MODULE__, id: "meta_attributes", meta_attributes: new_meta_attributes)

    {:noreply, socket}
  end
end
