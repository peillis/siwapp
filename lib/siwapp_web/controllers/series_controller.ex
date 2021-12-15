defmodule SiwappWeb.SeriesController do
  use SiwappWeb, :controller

  # alias *****.Series (CONTEXT)
  alias Siwapp.Schema.Series

  def index(conn, _params) do
    # TO DO
  end

  def new(conn, _params) do
    conn =
      conn
      |> assign(:form_action, :create)
      |> assign(:page_title, "New Series")
      |> assign(:changeset, Series.changeset(%Series{}, %{}))
      #|> assign(:changeset, Series.change_series(%Series{}))

    render(conn, "form.html")
  end

  def edit(conn, %{"id" => id}) do
    #series = Series.get!(id)

    conn =
      conn
      |> assign(:form_action, :update)
      #|> assign(:page_title, series.name)
      #|> assign(:series, series)
      #|> assign(:changeset, Accounts.change_series(series))

    render(conn, "form.html")
  end

  def update(conn, params) do
    # case Series.create_series(params) do
    #   {:ok, _series} ->
    #     conn
    #     |> put_flash(:info, "Series was successfully created.")
    #     |> redirect(to: Routes.series_path(conn, :index))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "form.html", changeset: changeset)
    # end
  end

  def create(conn, params) do
    # case Series.update_series(conn.assigns.series, params) do
    #   {:ok, _series} ->
    #     conn
    #     |> put_flash(:info, "Series was successfully created.")
    #     |> redirect(to: Routes.series_path(conn, :index))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "form.html", changeset: changeset)
    # end
  end
end
