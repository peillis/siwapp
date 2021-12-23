defmodule SiwappWeb.Helpers do
  use SiwappWeb, :live_view

  import Ecto.Changeset

  def render(assigns) do
    ~H"""

    """
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
