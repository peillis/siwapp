defmodule SiwappWeb.InvoicesLive.CustomerComponent do
  @moduledoc false
  use SiwappWeb, :live_component

  alias Siwapp.Customers

  def update(assigns, socket) do
    changeset = assigns.f.source

    customer_name = %{
      data: Ecto.Changeset.get_field(changeset, :name),
      change: Ecto.Changeset.get_change(changeset, :name)
    }

    customer_suggestions =
      if Customers.exists_with_name?(customer_name.change),
        do: [],
        else: Customers.suggest_by_name_input(customer_name.change)

    socket =
      socket
      |> assign(f: assigns.f)
      |> assign(customer_name: customer_name.data)
      |> assign(customer_suggestions: customer_suggestions)
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <fieldset class="fieldset">
      <h2>Customer</h2>

      <%= render(SiwappWeb.PageView, "customer_form.html", f: @f, myself: @myself, customer_name: @customer_name, customer_suggestions: @customer_suggestions) %>

      <div class="field is-horizontal field-body">
        <div class="field">
          <%= label @f, :terms, "Legal terms and conditions", class: "label" %>
          <p class="control">
            <%= textarea @f, :terms, phx_debounce: "blur", class: "textarea" %>
          </p>
          <%= error_tag @f, :terms %>
        </div>

        <div class="field">
          <%= label @f, :notes, class: "label" %>
          <p class="control">
            <%= textarea @f, :notes, phx_debounce: "blur", class: "textarea" %>
          </p>
          <%= error_tag @f, :notes %>
        </div>
      </div>

    </fieldset>
    """
  end

  def handle_event("pick_customer", %{"id" => customer_id}, socket) do
    customer_params =
      Customers.get(customer_id)
      |> Map.take([
        :name,
        :identification,
        :contact_person,
        :email,
        :invoicing_address,
        :shipping_address
      ])

    invoice_params = socket.assigns.changeset.changes
    items_params = Enum.map(invoice_params.items, & &1.changes)

    params =
      invoice_params
      |> Map.merge(%{items: items_params})
      |> Map.merge(customer_params)

    send(self(), {:update_changeset, params})

    {:noreply, socket}
  end
end
