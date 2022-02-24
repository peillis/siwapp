defmodule SiwappWeb.ItemsComponent do
  @moduledoc false

  use SiwappWeb, :live_component

  alias Ecto.Changeset
  alias Phoenix.HTML.FormData
  alias SiwappWeb.PageView

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, :multiselect_options, Siwapp.Commons.list_taxes_for_multiselect())}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(f: assigns.f)
     |> assign(changeset: assigns.f.source)
     |> assign(currency: Changeset.get_field(assigns.f.source, :currency))
     |> assign(inputs_for: assigns.inputs_for)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("add", _, socket) do
    params = socket.assigns.f.params

    next_item_index =
      params["items"]
      |> Enum.count()
      |> Integer.to_string()

    send(
      self(),
      {:params_updated, put_in(params, ["items", next_item_index], PageView.get_item_params())}
    )

    {:noreply, socket}
  end

  def handle_event("remove", %{"item-id" => item_index}, socket) do
    params =
      socket.assigns.f.params
      |> pop_in(["items", item_index])
      |> elem(1)

    send(self(), {:params_updated, params})

    {:noreply, socket}
  end

  @spec item_net_amount(Changeset.t(), FormData.t()) :: binary
  defp item_net_amount(changeset, currency) do
    value = Changeset.get_field(changeset, :net_amount)
    PageView.money_format(value, currency, symbol: false, separator: "")
  end

  @spec net_amount(Ecto.Changeset.t()) :: binary
  defp net_amount(changeset) do
    changeset
    |> Changeset.get_field(:net_amount)
    |> PageView.money_format(Changeset.get_field(changeset, :currency))
  end

  @spec taxes_amounts(Ecto.Changeset.t()) :: list
  defp taxes_amounts(changeset) do
    changeset
    |> Changeset.get_field(:taxes_amounts)
    |> Enum.map(fn {k, v} ->
      {k, PageView.money_format(v, Changeset.get_field(changeset, :currency))}
    end)
  end

  @spec gross_amount(Ecto.Changeset.t()) :: binary
  defp gross_amount(changeset) do
    changeset
    |> Changeset.get_field(:gross_amount)
    |> PageView.money_format(Changeset.get_field(changeset, :currency))
  end
end
