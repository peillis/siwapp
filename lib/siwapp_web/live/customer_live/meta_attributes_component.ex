defmodule SiwappWeb.CustomerLive.MetaAttributesComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> init_socket()}
  end

  def handle_event("changing-key", %{"value" => value}, socket) do
    {:noreply, assign(socket, :new_key, value)}
  end

  def handle_event("changing-value", %{"value" => value}, socket) do
    {:noreply, assign(socket, :new_value, value)}
  end

  def handle_event("add", _params, %{assigns: assigns} = socket) do
    new_meta_attributes =
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

    send_update(__MODULE__, id: "meta_attributes", meta_attributes: new_meta_attributes)

    {:noreply, socket}
  end

  def handle_event("remove", %{"key" => key}, socket) do
    new_meta_attributes = Map.delete(socket.assigns.meta_attributes, key)
    send_update(__MODULE__, id: "meta_attributes", meta_attributes: new_meta_attributes)

    {:noreply, socket}
  end

  defp init_socket(socket) do
    socket
    |> assign(:new_key, "")
    |> assign(:new_value, "")
  end
end
