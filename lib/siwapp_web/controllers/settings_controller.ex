defmodule SiwappWeb.SettingsController do
  use SiwappWeb, :controller

  alias Siwapp.Settings

  def edit(conn, _params) do
    data = Settings.current_bundle()
    changeset = Settings.change_bundle(data)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"setting_bundle" => attrs}) do
    case Settings.apply_user_bundle(attrs) do
      {:ok, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_flash(:info, "Settings saved succesfully")
        |> render("edit.html")

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
