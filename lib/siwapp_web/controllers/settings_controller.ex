defmodule SiwappWeb.SettingsController do
  use SiwappWeb, :controller

  alias Siwapp.SettingsForm

  def edit(conn, _params) do
    conn
    |> assign_changeset_and_labels()
    |> render("edit.html")
  end

  def update(conn, %{"form" => attrs}) do
    conn = assign_changeset_and_labels(conn)
    data = conn.assigns.changeset.data
    changeset = SettingsForm.change(data, attrs)

    case SettingsForm.apply_user_settings(changeset) do
      {:ok, changeset} ->
        conn
        |> assign_changeset_and_labels()
        |> put_flash(:info, "Settings saved succesfully")
        |> render("edit.html")

      {:error, changeset} ->
        render(conn, "edit.html", changeset: %{changeset | action: :insert})
    end
  end

  def assign_changeset_and_labels(conn) do
    pairs = SettingsForm.get_pairs()
    data = SettingsForm.prepare_data()
    changeset = SettingsForm.change(data)

    conn
    |> assign(:pairs, pairs)
    |> assign(:changeset, changeset)
  end
end
