defmodule SiwappWeb.SeriesController do
  use SiwappWeb, :controller

  plug :assign_email_and_password_changesets

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end

end
