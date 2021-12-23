defmodule SiwappWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

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

  def checked?(checked, id) do
    string_id = Integer.to_string(id)
    Enum.member?(checked, string_id)
  end

  def status(paid, due_date) do
    cond do
      paid -> :paid
      pending?(due_date) -> :pending
      true -> :past_due
    end
  end

  def invisible?(checked) do
    Enum.empty?(checked)
  end

  defp pending?(due_date) do
    Date.diff(due_date, Date.utc_today()) >= 0
  end
end
