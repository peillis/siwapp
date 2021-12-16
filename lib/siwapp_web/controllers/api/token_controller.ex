defmodule SiwappWeb.Api.TokenController do
  use SiwappWeb, :controller

  alias Siwapp.Accounts
  alias Siwapp.Accounts.User
  alias Siwapp.ApiToken

  def create(conn, %{"email" => email, "password" => password}) do
    with %User{} = user <- Accounts.get_user_by_email_and_password(email, password),
         token <- ApiToken.sign(%{user_id: user.id}) do
      conn
      |> render("token.json", token: token)
    else
      nil ->
        conn
        |> render("error.json", error_message: "Invalid email or password")
    end
  end

  def show(conn, _params) do
    conn
    |> render("valid_token.json", email: conn.assigns.current_user.email)
  end
end
