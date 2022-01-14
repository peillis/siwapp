defmodule SiwappWeb.TemplatesLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Templates

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(templates: Templates.list())
      |> assign(page_title: "Templates")

    {:ok, assign(socket, templates: Templates.list())}
  end

  @impl true
  def handle_event("defaultClicked", %{"id" => id, "type" => type}, socket) do
    template = id |> String.to_integer() |> Templates.get()
    Templates.set_default(String.to_atom(type), template)

    {:noreply, assign(socket, templates: Templates.list())}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.templates_edit_path(socket, :edit, id))}
  end
end
