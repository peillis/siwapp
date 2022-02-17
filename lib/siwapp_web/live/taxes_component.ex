defmodule SiwappWeb.TaxesComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Phoenix.LiveView.JS
  alias SiwappWeb.InvoiceFormHelpers

  def update(assigns, socket) do
    "taxes-" <> index = assigns.id

    selected =
      assigns.changeset
      |> Ecto.Changeset.get_field(:items)
      |> Enum.at(String.to_integer(index))
      |> get_taxes()
      |> Enum.map(&{&1.name, &1.id})
      |> MapSet.new()

    {:ok,
     socket
     |> assign(selected: selected)
     |> assign(name: assigns.name)
     |> assign(index: index)
     |> assign(options: MapSet.new(assigns.options))
     |> assign(changeset: assigns.changeset)}
  end

  def render(assigns) do
    ~H"""
    <div class="control msa-wrapper">
      <%= for {k, _v} <- @selected do %>
        <input type="hidden" id="hidden_input" name={"#{@name}[]"} value={k}>
      <% end %>
      <div class="input input-presentation" phx-click={JS.toggle(to: "#tag-list-#{@index}")}>
        <span class="placeholder"></span>
        <%= for {k, v} <- @selected do %>
          <div class="tag-badge">
            <span>
              <%= k %>
            </span>
            <button
              type="button"
              phx-click={JS.push("remove", target: @myself, value: %{index: @index, key: k, val: v})}
            >
              x
            </button>
          </div>
        <% end %>
      </div>
      <ul id={"tag-list-#{@index}"} class="tag-list" style="display: none;">
        <%= for {k, v} <- not_selected(@options, @selected) do %>
          <li phx-click={JS.push("add", target: @myself, value: %{index: @index, key: k, val: v}) |> JS.toggle(to: "#tag-list-#{@index}")}>
            <%= k %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("remove", %{"index" => index, "key" => key, "val" => value}, socket) do
    selected =
      socket.assigns.selected
      |> MapSet.delete({key, value})

    send(
      self(),
      {:params_updated, get_params_with_taxes(socket.assigns.changeset, index, selected)}
    )

    {:noreply, assign(socket, selected: selected)}
  end

  def handle_event("add", %{"index" => index, "key" => key, "val" => value}, socket) do
    selected =
      socket.assigns.selected
      |> MapSet.put({key, value})

    send(
      self(),
      {:params_updated, get_params_with_taxes(socket.assigns.changeset, index, selected)}
    )

    {:noreply, assign(socket, selected: selected)}
  end

  defp not_selected(options, selected) do
    MapSet.difference(options, selected)
  end

  defp get_params_with_taxes(changeset, index, selected) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> InvoiceFormHelpers.get_params()
    |> put_in(
      ["items", index, "taxes"],
      Enum.map(selected, fn {k, _v} -> k end)
    )
  end

  defp get_taxes(item) do
    if is_struct(item, Siwapp.Invoices.Item) do
      Map.get(item, :taxes)
    else
      Ecto.Changeset.get_field(item, :taxes)
    end
  end
end
