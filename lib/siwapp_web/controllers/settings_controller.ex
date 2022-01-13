defmodule SiwappWeb.SettingsController do
  use SiwappWeb, :controller

  alias Siwapp.SettingsForm

  def edit(conn, _params) do
    data = SettingsForm.prepare_data()
    changeset = SettingsForm.change(data)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"settings_form" => attrs}) do
    data = SettingsForm.prepare_data()
    changeset = SettingsForm.change(data, attrs)

    case SettingsForm.apply_user_settings(changeset) do
      {:ok, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_flash(:info, "Settings saved succesfully")
        |> render("edit.html")

      {:error, changeset} ->
        render(conn, "edit.html", changeset: %{changeset | action: :insert})
    end
  end
end
