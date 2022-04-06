defmodule SiwappWeb.TemplatesLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view

  alias Siwapp.Templates

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(templates: Templates.list())
      |> assign(page_title: "Templates")

    {:ok, assign(socket, templates: Templates.list())}
  end

  @impl Phoenix.LiveView
  def handle_event("defaultClicked", %{"id" => id, "type" => type}, socket) do
    template = id |> String.to_integer() |> Templates.get()

    socket =
      cond do
        template.print_default and type == "print" ->
          put_flash(
            socket,
            :error,
            "You must have one default template. Please select one to swipe defaults."
          )

        template.email_default and type == "email" ->
          put_flash(
            socket,
            :error,
            "You must have one default template. Please select one to swipe defaults."
          )

        true ->
          Templates.set_default(String.to_atom(type), template)

          socket
          |> assign(templates: Templates.list())
          |> clear_flash()
      end

    {:noreply, socket}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.templates_edit_path(socket, :edit, id))}
  end
end
