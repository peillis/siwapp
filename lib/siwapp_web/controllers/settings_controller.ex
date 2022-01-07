defmodule SiwappWeb.SettingsController do
  use SiwappWeb, :controller

  #alias Siwapp.Settings
  alias Siwapp.SettingsForm

  plug :assign_changeset_and_labels

  def edit(conn, _params) do
    conn
    |> render("edit.html")
  end

  def update(conn, %{"form" => attrs} = params) do
    changeset = conn.assigns.changeset
    IO.inspect params
    conn
    case SettingsForm.apply_user_settings(changeset, attrs) do
      {:ok, _applied_form} ->
        conn
        |> put_flash(:info, "Settings saved succesfully")
        |> render("edit.html")
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end
  
  defp assign_changeset_and_labels(conn, _opts) do
    labels = SettingsForm.get_labels
    conn
    |> assign(:labels, labels)
    |> assign(:changeset, SettingsForm.change())
  end

  """
  def edit(conn, _params) do
    conn
    |> assign(:settings, Settings.prepare_current_settings())
    |> render("edit._old.html")
  end

  def update(conn, %{"key_values" => key_values_map}) do
    _data_base_feedback = for {key, value} <- Map.to_list(key_values_map), do: act(key, value)

    conn
    |> assign(:settings, Settings.prepare_current_settings())
    |> render("edit_old.html")
  end

  def act(key, value) do
    current = Settings.get(key)

    if is_nil(current) do
      if value != "", do: Settings.create({key, value})
    else
      if value == "" do
        Settings.delete(current)
      else
        if value != current.value, do: Settings.update(current, value)
      end
    end
  end
  """
end
