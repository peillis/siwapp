defmodule SiwappWeb.InvoicesLive.CustomerInputComponent do
  @moduledoc false
  use SiwappWeb, :live_component

  alias Siwapp.Customers

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, status: "is-active")}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    status =
      if changes_in_name?(assigns.f.source) and socket.assigns.status != "just-picked" do
        "is-active"
      else
        "not-active"
      end

    customer_name = Ecto.Changeset.get_field(assigns.f.source, :name)

    {:ok,
     socket
     |> assign(view: socket.view)
     |> assign(f: assigns.f)
     |> assign(customer_name: customer_name)
     |> assign(customer_suggestions: Customers.suggest_by_name(customer_name))
     |> assign(status: status)}
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
      <%= label(@f, :name, class: "label") %>
      <p class="control has-dropdown">
        <div class="input-with-dropdown control">
          <%= text_input(@f, :name,
            phx_debounce: "500",
            class: "input",
            value: @customer_name,
            autocomplete: "off"
          ) %>
          <div class={"dropdown below-input #{@status}"}>
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
        </div>
      </p>
      <%= error_tag(@f, :name) %>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("pick_customer", %{"id" => customer_id}, socket) do
    customer_params =
      customer_id
      |> Customers.get()
      |> IO.inspect()
      |> Map.take([
        :name,
        :identification,
        :contact_person,
        :email,
        :invoicing_address,
        :shipping_address      ])
      |> SiwappWeb.PageView.atom_keys_to_string()

    send(self(), {:params_updated, Map.merge(socket.assigns.f.params, customer_params)})

    {:noreply, assign(socket, status: "just-picked")}
  end

  defp changes_in_name?(changeset) do
    if Ecto.Changeset.get_change(changeset, :name), do: true, else: false
  end
end
