defmodule SiwappWeb.SearchLive.SearchComponent do
  @moduledoc false
  use SiwappWeb, :live_component
  alias Phoenix.LiveView.JS
  alias Siwapp.Commons
  alias Siwapp.Searches
  alias Siwapp.Searches.Search

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket =
      socket
      |> assign_search()
      |> assign_changeset(assigns)
      |> assign(:series_names, Commons.list_series_names())
      |> assign(filters: assigns.filters)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("change", %{"search" => search_params}, %{assigns: %{search: search}} = socket) do
    changeset = Searches.change(search, search_params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("search", %{"search" => params}, socket) do
    params = Enum.reject(params, fn {_key, val} -> val in ["", "Choose..."] end)

    send(self(), {:search, params})

    {:noreply, socket}
  end

  @spec assign_search(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  defp assign_search(socket) do
    assign(socket, :search, %Search{})
  end

  @spec assign_changeset(Phoenix.LiveView.Socket.t(), map) :: Phoenix.LiveView.Socket.t()
  defp assign_changeset(%{assigns: %{changeset: changeset}} = socket, %{name: name}) do
    changes_params = Map.replace(changeset.changes, :name, name)

    changeset = Searches.change(socket.assigns.search, changes_params)
    assign(socket, :changeset, changeset)
  end

  defp assign_changeset(%{assigns: %{search: search}} = socket, _) do
    assign(socket, :changeset, Searches.change(search))
  end
end
