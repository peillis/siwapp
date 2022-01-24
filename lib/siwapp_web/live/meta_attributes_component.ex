defmodule SiwappWeb.MetaAttributesComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.HTML.Form

  def update(assigns, socket) do
    attributes =
      case Form.input_value(assigns.f, :meta_attributes) do
        "" -> %{}
        attrs -> attrs
      end

    socket =
      socket
      |> assign(new_key: "")
      |> assign(new_value: "")
      |> assign(attributes: attributes)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <fieldset>
      <h2>Meta Attributes</h2>
      <%= for {k, v} <- @attributes do %>
        <div class="field is-horizontal field-body">
          <input class="input field" type="text" name="meta[values][]" value={k} />
          <input class="input field" type="text" name={"customer[meta_attributes][#{k}]"} value={v} />
          <a class="button is-danger field" phx-click="remove" phx-value-key={k} phx-target={@myself}>Remove</a>
        </div>
      <% end %>

      <%= if @attributes == %{} do %>
        <input type="hidden" name="customer[meta_attributes]" />
      <% end %>

      <div class="field is-horizontal field-body">
        <input class="input field" type="text" name="meta[keys][]" phx-blur="changing-key" phx-target={@myself} placeholder="Key"/>
        <input class="input field" type="text" name="meta[values][]" phx-blur="changing-value" phx-target={@myself} placeholder="Value"/>
        <a class="button is-success field" phx-click="add" phx-target={@myself}>Add</a>
      </div>
    </fieldset>
    """
  end

  def handle_event("remove", %{"key" => key}, socket) do
    {:noreply, update(socket, :attributes, &Map.delete(&1, key))}
  end

  def handle_event("changing-key", %{"value" => value}, socket) do
    {:noreply, assign(socket, :new_key, value)}
  end

  def handle_event("changing-value", %{"value" => value}, socket) do
    {:noreply, assign(socket, :new_value, value)}
  end

  def handle_event("add", _params, %{assigns: assigns} = socket) do
    socket = update(socket, :attributes, &Map.put(&1, assigns.new_key, assigns.new_value))

    {:noreply, socket}
  end
end
