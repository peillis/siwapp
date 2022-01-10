defmodule SiwappWeb.LiveHelpers do
  @moduledoc false
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

  def type_of_period(period_type, period) do
    case period_type do
      "Daily" -> singular_or_plural(period, "day")
      "Monthly" -> singular_or_plural(period, "month")
      "Yearly" -> singular_or_plural(period, "year")
    end
  end

  defp singular_or_plural(period, str) do
    if period > 1 do
      str <> "s"
    else
      str
    end
  end
end
