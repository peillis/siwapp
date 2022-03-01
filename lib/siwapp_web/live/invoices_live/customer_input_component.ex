defmodule SiwappWeb.InvoicesLive.CustomerInputComponent do
  @moduledoc false
  use SiwappWeb, :live_component

  alias Siwapp.Customers

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, status: :is_active)}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    status =
      if changes_in_name?(assigns.f.source) and socket.assigns.status != :just_picked do
        :active
      else
        :idle
      end

    customer_name = Ecto.Changeset.get_field(assigns.f.source, :name)

    {:ok,
     socket
     |> assign(view: socket.view)
     |> assign(f: assigns.f)
     |> assign(customer_name: customer_name)
     |> assign(
       customer_suggestions: Customers.suggest_by_name(customer_name, limit: 10, offset: 0)
     )
     |> assign(status: status)
     |> assign(display: if(status == :active, do: "is-active"))
     |> assign(:page, 0)}
  end

  @impl Phoenix.LiveComponent
  def render(%{view: SiwappWeb.CustomerLive.Edit} = assigns) do
    ~H"""
    <div class="field">
      <%= label(@f, :name, class: "label") %>
      <p class="control">
        <%= text_input(@f, :name, phx_debounce: "blur", class: "input") %>
      </p>
      <%= error_tag(@f, :name) %>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="field">
      <%= if @f.name != "search" do %>
        <%= label(@f, :name, class: "label") %>
      <% end %>
      <p class="control has-dropdown">
        <div class="input-with-dropdown control">
          <%= text_input(@f, :name,
            phx_debounce: "500",
            class: "input",
            value: @customer_name,
            autocomplete: "off"
          ) %>
          <div class={"dropdown below-input #{@display}"}>
            <div
              class="dropdown-menu dropdown-content"
              id="customers_list"
              phx-hook="InfiniteScroll"
              data-page={@page}
              phx-target={@myself}
              role="menu"
            >
              <%= for customer_suggestion <- @customer_suggestions do %>
                <a
                  href="#"
                  phx-click="pick_customer"
                  phx-value-id={customer_suggestion.id}
                  phx-target={@myself}
                  class="dropdown-item"
                >
                  <%= customer_suggestion.name %>
                </a>
              <% end %>
            </div>
          </div>
        </div>
      </p>
      <%= error_tag(@f, :name) %>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "pick_customer",
        %{"id" => customer_id},
        %{view: SiwappWeb.InvoicesLive.Edit} = socket
      ) do
    customer_params =
      customer_id
      |> Customers.get()
      |> Map.take([
        :name,
        :identification,
        :contact_person,
        :email,
        :invoicing_address,
        :shipping_address,
        :meta_attributes
      ])
      |> Mappable.to_map(keys: :strings)

    send(self(), {:params_updated, Map.merge(socket.assigns.f.params, customer_params)})

    {:noreply, assign(socket, status: :just_picked)}
  end

  def handle_event("pick_customer", %{"id" => customer_id}, socket) do
    name =
      customer_id
      |> Customers.get!()
      |> Map.get(:name)

    view = SiwappWeb.LayoutView.which_view(socket.view)

    send_update(SiwappWeb.SearchLive.SearchComponent, id: "search", view: view, name: name)

    {:noreply, assign(socket, status: :just_picked)}
  end

  def handle_event("load-more", _, socket) do
    %{
      page: page,
      customer_suggestions: customer_suggestions,
      customer_name: customer_name
    } = socket.assigns

    next_page = page + 1

    {:noreply,
     assign(socket,
       customer_suggestions:
         customer_suggestions ++
           Customers.suggest_by_name(customer_name, limit: 10, offset: 10 * next_page),
       page: next_page
     )}
  end

  @spec changes_in_name?(Ecto.Changeset.t()) :: boolean()
  defp changes_in_name?(changeset) do
    if Ecto.Changeset.get_change(changeset, :name), do: true, else: false
  end
end
