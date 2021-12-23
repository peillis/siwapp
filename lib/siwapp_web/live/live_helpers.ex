defmodule SiwappWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView
  import Ecto.Changeset

  @doc """
  Renders a component inside the `SiwappWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(SiwappWeb.ModalComponent, modal_opts)
  end

  def display_errors(changeset) do
    errors = get_errors(changeset)

    errors
    |> Enum.map(fn {key, errors} -> "#{key}: #{Enum.join(errors, ", ")}" end)
    |> Enum.join("\n")
  end

  def redirect_to_index(socket) do
    case socket.assigns.changeset.data.__struct__ do
      Siwapp.Customers.Customer ->
        push_redirect(socket, to: Routes.customers_index_path(socket, :index))

      Siwapp.Invoices.Invoice ->
        push_redirect(socket, to: Routes.invoices_index_path(socket, :index))
    end
  end

  defp get_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
