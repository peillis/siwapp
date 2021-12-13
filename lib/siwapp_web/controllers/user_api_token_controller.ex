defmodule SiwappWeb.UserApiTokenController do
  use SiwappWeb, :controller

  alias Siwapp.Accounts
  alias SiwappWeb.UserAuth

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => user_params}) do

    user = conn.assigns.current_user


  end
end
