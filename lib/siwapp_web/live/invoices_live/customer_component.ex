defmodule SiwappWeb.InvoicesLive.CustomerComponent do
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
    <fieldset class="fieldset">
      <h2>Customer</h2>

      <%= render(SiwappWeb.PageView, "customer_form.html",
        f: @f,
        myself: @myself,
        customer_name: @customer_name,
        customer_suggestions: @customer_suggestions
      ) %>

      <div class="field is-horizontal field-body">
        <div class="field">
          <%= label(@f, :terms, "Legal terms and conditions", class: "label") %>
          <p class="control">
            <%= textarea(@f, :terms, phx_debounce: "blur", class: "textarea") %>
          </p>
          <%= error_tag(@f, :terms) %>
        </div>

        <div class="field">
          <%= label(@f, :notes, class: "label") %>
          <p class="control">
            <%= textarea(@f, :notes, phx_debounce: "blur", class: "textarea") %>
          </p>
          <%= error_tag(@f, :notes) %>
        </div>
      </div>

    </fieldset>
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
