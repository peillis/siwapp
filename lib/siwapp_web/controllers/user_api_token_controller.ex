defmodule SiwappWeb.UserApiTokenController do
  use SiwappWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
