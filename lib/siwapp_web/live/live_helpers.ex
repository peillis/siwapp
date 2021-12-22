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

  def checked?(checked, id) when is_map(checked) do
    Map.get(checked, Integer.to_string(id), false)
  end

  def checked?(_, _), do: false

  def pending?(due_date) do
    Date.diff(due_date, Date.utc_today()) >= 0
  end
end
