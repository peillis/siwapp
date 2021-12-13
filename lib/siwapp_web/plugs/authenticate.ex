defmodule SiwappWeb.Plugs.Authenticate do
  import Plug.Conn
  require Logger

  def init(default), do: default

  def call(conn, _opts) do
    with ["Token token=" <> token] <- get_req_header(conn, "Authorization"),
         {:ok, data} <- Siwapp.ApiToken.verify(token) do
      conn
      |> assign(:current_user, Siwapp.Accounts.get_user!(data.user_id))
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(SiwappWeb.ErrorView)
        |> Phoenix.Controller.render(:"401")
        |> halt()
    end
  end
end
