defmodule SiwappWeb.SeriesController do
  use SiwappWeb, :controller

  # alias *****.Settings (CONTEXT)
  alias Siwapp.Schema.Series

  def index(_conn, _params) do
    # TO DO
  end

  def new(conn, _params) do
    # changeset = Settings.change_series(%Series{})
    # render(conn, "new.html", changeset: changeset)
    render(conn, "new.html", changeset: Series.changeset(%Series{}, %{}))
  end

  def create(_conn, %{"series" => _series_params}) do
    # case Settings.create_series(series_params) do
    #   {:ok, series} ->
    #     conn
    #     |> put_flash(:info, "Series was successfully created.")
    #     |> redirect(to: Routes.series_path(conn, :index))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "new.html", changeset: changeset)
    # end
  end

  def edit(_conn, %{"id" => _id}) do
    # series = Settings.get_series!(id)
    # changeset = Settings.change_series(series)
    # render(conn, "edit.html", series: series, changeset: changeset)
  end

  def update(_conn, %{"id" => _id, "series" => _series_params}) do
    # series = Settings.get_series!(id)

    # case Settings.update_series(series, series_params) do
    #   {:ok, series} ->
    #     conn
    #     |> put_flash(:info, "Series was successfully updated.")
    #     |> redirect(to: Routes.series_path(conn, :index))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", series: series, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => _id}) do
    # series = Settings.get_series!(id)
    # {:ok, series} = Settings.delete_series(series)

    conn
    |> put_flash(:info, "Series was successfully destroyed.")
    |> redirect(to: Routes.series_path(conn, :index))
  end

end
