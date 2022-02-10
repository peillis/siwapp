defmodule SiwappWeb.Api.InvoicesController do
  use SiwappWeb, :controller

  def download(conn, params) do
    SiwappWeb.PageController.download(conn, params)
  end
end
