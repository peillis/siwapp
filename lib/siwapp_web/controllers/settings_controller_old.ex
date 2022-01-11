defmodule SiwappWeb.OldSettingsController do
  use SiwappWeb, :controller

  alias Siwapp.Settings
  alias Siwapp.SettingsForm

  def edit(conn, _params) do
    conn
    |> assign(:settings, SettingsForm.prepare_current_settings())
    |> render("edit_old.html")
  end

  def update(conn, %{"key_values" => key_values_map}) do
    _data_base_feedback = for {key, value} <- Map.to_list(key_values_map), do: act(key, value)

    conn
    |> assign(:settings, SettingsForm.prepare_current_settings())
    |> render("edit_old.html")
  end

  defp act(key, value) do
    current = Settings.get(key)

    if is_nil(current) do
      if value != "" do
        IO.inspect({key, value})
        Settings.create({key, value})
      end
    else
      if value == "" do
        Settings.delete(current)
      else
        if value != current.value, do: Settings.update(current, value)
      end
    end
  end
end
