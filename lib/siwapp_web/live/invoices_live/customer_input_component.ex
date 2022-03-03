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
    current_name = set_current_name(assigns, socket)
    status = set_status(assigns, current_name)
    customer_name = Ecto.Changeset.get_field(assigns.f.source, :name)
    customer_suggestions = set_customer_suggestions(status, customer_name)

    {:ok,
     socket
     |> assign(view: socket.view)
     |> assign(f: assigns.f)
     |> assign(customer_name: customer_name)
     |> assign(customer_suggestions: customer_suggestions)
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

    {:noreply, assign(socket, customer_name: customer_params["name"])}
  end

  def handle_event("pick_customer", %{"id" => customer_id}, socket) do
    name =
      customer_id
      |> Customers.get!()
      |> Map.get(:name)

    filters = SiwappWeb.LayoutView.which_filters(socket.view)

    send_update(SiwappWeb.SearchLive.SearchComponent, id: "search", filters: filters, name: name)

    {:noreply, assign(socket, customer_name: name)}
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

  @spec set_current_name(map, map) :: binary
  defp set_current_name(assigns, socket) do
    if Map.has_key?(socket.assigns, :customer_name),
      do: socket.assigns.customer_name,
      else: assigns.f.data.name
  end

  @spec set_status(map, binary) :: :idle | :active
  defp set_status(assigns, current_name) do
    if Ecto.Changeset.get_field(assigns.f.source, :name) == current_name,
      do: :idle,
      else: :active
  end

  @spec set_customer_suggestions(:idle | :active | :is_active, binary) :: [Customers.Customer.t()]
  defp set_customer_suggestions(status, customer_name) do
    if status == :active,
      do: Customers.suggest_by_name(customer_name, limit: 10, offset: 0),
      else: []
  end
end
