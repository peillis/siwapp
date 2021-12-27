defmodule SiwappWeb.TemplatesLive.Index do
  use SiwappWeb, :live_view

  alias Siwapp.Templates

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, templates: Templates.list())}
  end

  @impl true
  def handle_event("defaultClicked", %{"id" => id, "type" => type}, socket) do
    template = Templates.get(id)
    Templates.change_default(type, template)

    {:noreply, assign(socket, templates: Templates.list())}
  end
end
