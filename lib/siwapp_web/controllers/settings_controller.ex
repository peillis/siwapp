defmodule SiwappWeb.SettingsController do
  use SiwappWeb, :controller

  alias Siwapp.SettingsForm

  plug :assign_changeset_and_labels

  def edit(conn, _params) do
    conn
    |> render("edit.html")
  end

  def update(conn, %{"form" => attrs}) do
    changeset = conn.assigns.changeset.data
                |> SettingsForm.change(attrs)
    case SettingsForm.apply_user_settings(changeset) do
      {:ok, _applied_settings} ->
        conn
        |> put_flash(:info, "Settings saved succesfully")
        |> render("edit.html")
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp assign_changeset_and_labels(conn, _opts) do
    pairs = SettingsForm.get_pairs
    data = SettingsForm.prepare_data
    conn
    |> assign(:pairs, pairs)
    |> assign(:changeset, SettingsForm.change(data))
  end

end
