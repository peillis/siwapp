defmodule SiwappWeb.MetaAttributesComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  def mount(socket) do
    {:ok, init_socket(socket)}
  end

  def render(assigns) do
    ~H"""
    <fieldset>
      <h2>Meta Attributes</h2>
      <%= for {k, v} <- @meta_attributes do %>
        <div class="field is-horizontal field-body">
          <input class="input field" type="text" name="meta[keys][]" value={k} />
          <input class="input field" type="text" name="meta[values][]" value={v} />
          <button class="button is-danger field" phx-click="remove" phx-value-key={k} phx-target={@myself}>Remove</button>
          <br/>
        </div>
      <% end %>
      <div class="field is-horizontal field-body">
        <input class="input field" type="text" name="meta[keys][]" phx-blur="changing-key" phx-target={@myself} placeholder="Key"/>
        <input class="input field" type="text" name="meta[values][]" phx-blur="changing-value" phx-target={@myself} placeholder="Value"/>
        <button class="button is-success field" phx-click="add" phx-target={@myself}>Add</button>
        <br/>
      </div>
    </fieldset>
    """
  end

  @doc """
  Merge the `params` received from the form with the meta_attributes.

  ## Examples

      iex> merge(
      ...>   %{"what" => "ever"},
      ...>   %{"keys" => ["mykey"], "values" => ["myvalue"]}
      ...>)
      %{"what" => "ever", "meta_attributes" => %{"mykey" => "myvalue"}}
  """
  @spec merge(map, map) :: map
  def merge(params, meta) do
    meta_attributes =
      Enum.zip(meta["keys"], meta["values"])
      |> Map.new()
      |> Map.delete("")

    Map.put(params, "meta_attributes", meta_attributes)
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

    {:noreply, init_socket(socket)}
  end

  defp init_socket(socket) do
    socket
    |> assign(:new_key, "")
    |> assign(:new_value, "")
  end
end
