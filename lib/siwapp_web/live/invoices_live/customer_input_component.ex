defmodule SiwappWeb.InvoicesLive.CustomerInputComponent do
  @moduledoc false
  use SiwappWeb, :live_component

  alias Siwapp.Customers

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(:customer_name, "")
     |> assign(:customer_suggestions, [])}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    changeset = assigns.f.source

    customer_name = %{
      data: Ecto.Changeset.get_field(changeset, :name),
      change: Ecto.Changeset.get_change(changeset, :name)
    }

    customer_suggestions =
      if socket.assigns.customer_name == customer_name.change,
        do: socket.assigns.customer_suggestions,
        else: Customers.suggest_by_name(customer_name.change)

    socket =
      socket
      |> assign(f: assigns.f)
      |> assign(customer_name: customer_name.data)
      |> assign(customer_suggestions: customer_suggestions)
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="field">
      <%= label(@f, :name, class: "label") %>
      <%= if Map.has_key?(assigns, :customer_suggestions) do %>
        <p class="control has-dropdown">
          <div class="input-with-dropdown control">
            <%= text_input(@f, :name,
              phx_debounce: "500",
              class: "input",
              value: @customer_name,
              autocomplete: "off"
            ) %>
            <%= if @customer_suggestions != [] do %>
              <div class="dropdown below-input is-active">
                <div class="dropdown-menu dropdown-content" id="dropdown-menu" role="menu">
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
            <% end %>
          </div>
        </p>
      <% else %>
        <p class="control">
          <%= text_input(@f, :name, phx_debounce: "blur", class: "input") %>
        </p>
      <% end %>
      <%= error_tag(@f, :name) %>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("pick_customer", %{"id" => customer_id}, socket) do
    customer_params =
      customer_id
      |> Customers.get()
      |> Map.take([
        :name,
        :identification,
        :contact_person,
        :email,
        :invoicing_address,
        :shipping_address
      ])
      |> SiwappWeb.PageView.atom_keys_to_string()

    send(self(), {:params_updated, Map.merge(socket.assigns.f.params, customer_params)})

    {:noreply, socket}
  end
end
