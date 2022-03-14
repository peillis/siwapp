defmodule SiwappWeb.UsersLive.Index do
  @moduledoc false
  use SiwappWeb, :live_view
  alias Siwapp.Accounts
  alias Siwapp.Accounts.User

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:checked, MapSet.new())
     |> assign(:users, Accounts.list_users())}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("click_checkbox", params, socket) do
    checked = update_checked(params, socket)

    {:noreply, assign(socket, checked: checked)}
  end

  def handle_event("delete", _params, socket) do
    socket.assigns.checked
    |> MapSet.to_list()
    |> Enum.reject(&(&1 == 0))
    |> Enum.map(&Accounts.get_user!(&1))
    |> Enum.each(&Accounts.delete_user(&1))

    {:noreply, socket
      |> put_flash(:info, "Users succesfully deleted")
      |> assign(:checked, MapSet.new)
      |> assign(:users, Accounts.list_users)}
  end

  # def handle_event("upgrade", _params, socket) do
  #   socket.assigns.checked
  # end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Users")
    |> assign(:user, nil)
  end

  @spec update_checked(map(), Phoenix.LiveView.Socket.t()) :: MapSet.t()
  defp update_checked(%{"id" => "0", "value" => "on"}, socket) do
    socket.assigns.users
    |> MapSet.new(& &1.id)
    |> MapSet.put(0)
  end

  defp update_checked(%{"id" => "0"}, _) do
    MapSet.new()
  end

  defp update_checked(%{"id" => id, "value" => "on"}, socket) do
    MapSet.put(socket.assigns.checked, String.to_integer(id))
  end

  defp update_checked(%{"id" => id}, socket) do
    socket.assigns.checked
    |> MapSet.delete(String.to_integer(id))
    |> MapSet.delete(0)
  end
end
