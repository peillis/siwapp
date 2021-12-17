defmodule SiwappWeb.SeriesController do
  use SiwappWeb, :controller

  alias Siwapp.Settings
  alias Siwapp.Schema.Series

  def new(conn, _params) do
    changeset = Settings.change_series(%Series{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"series" => series_params}) do
    case Settings.create_series(series_params) do
      {:ok, _series} ->
        conn
        |> put_flash(:info, "Series was successfully created.")
        |> redirect(to: Routes.series_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    series = Settings.get_series!(id)
    changeset = Settings.change_series(series)
    render(conn, "edit.html", series: series, changeset: changeset)
  end

  def update(conn, %{"id" => id, "series" => series_params}) do
    series = Settings.get_series!(id)

    case Settings.update_series(series, series_params) do
      {:ok, _series} ->
        conn
        |> put_flash(:info, "Series was successfully updated.")
        |> redirect(to: Routes.series_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", series: series, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    series = Settings.get_series!(id)
    {:ok, _series} = Settings.delete_series(series)

    conn
    |> put_flash(:info, "Series was successfully destroyed.")
    |> redirect(to: Routes.series_path(conn, :index))
  end
end
