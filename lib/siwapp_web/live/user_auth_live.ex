defmodule SiwappWeb.UserAuthLive do
  import Phoenix.LiveView
  alias Siwapp.Accounts

  def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
    if current_user = Accounts.get_user_by_session_token(user_token) do
      {:cont, assign(socket, :current_user, current_user)}
    else
      {:halt, redirect(socket, to: "/users/log_in")}
    end
  end
end
