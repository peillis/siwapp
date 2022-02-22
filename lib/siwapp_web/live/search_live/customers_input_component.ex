defmodule SiwappWeb.SearchLive.CustomersInputComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Siwapp.Search

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign_customers(assigns)
     |> assign(:name, "")
     |> assign(:page, 0)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <input class="input" type="text" name="name" id="customers" phx-debounce="500" value={@name} />
      <%= if @customers_names != [] do %>
        <div class="customers_list">
          <div
            id="customers_list"
            class="customers_list_content"
            phx-hook="InfiniteScroll"
            data-page={@page}
            phx-target={@myself}
            role="menu"
          >
            <%= for name <- @customers_names do %>
              <option class="is-clickable" phx-click="pick_customer" phx-target={@myself}>
                <%= name %>
              </option>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("pick_customer", %{"value" => name}, socket) do
    {:noreply,
     socket
     |> assign(:name, name)
     |> assign(:customers_names, [])}
  end

  def handle_event("load-more", _, socket) do
    %{
      page: page,
      customers_names: customers_names,
      value: value
    } = socket.assigns

    next_page = page + 1

    {:noreply,
     assign(socket,
       customers_names: customers_names ++ Search.get_customers_names(value, next_page),
       page: next_page
     )}
  end

  @spec assign_customers(Phoenix.LiveView.Socket.t(), map()) :: Phoenix.LiveView.Socket.t()
  defp assign_customers(socket, %{customers_names: customers_names, value: value}) do
    socket
    |> assign(:customers_names, customers_names)
    |> assign(:value, value)
  end

  defp assign_customers(socket, _params) do
    assign(socket, :customers_names, [])
  end
end
