defmodule SiwappWeb.GlobalSettingsController do
  use SiwappWeb, :controller

  alias Siwapp.GlobalSettings

  def edit(conn, _params) do
    conn
    |> assign(:global_settings, GlobalSettings.prepare_current_global_settings())
    |> render("edit.html")
  end

  def update(conn, %{"key_values" => key_values_map}) do
    _data_base_feedback = for {key, value} <- Map.to_list(key_values_map), do: act(key, value)

    conn
    |> assign(:global_settings, GlobalSettings.prepare_current_global_settings())
    |> render("edit.html")
  end

  def act(key, value) do
    schema = GlobalSettings.schema_for_key(key)
    require IEx
    IEx.pry()

    cond do
      is_nil(schema) && value == "" -> nil
      is_nil(schema) -> GlobalSettings.create({key, value})
      value == "" -> GlobalSettings.delete(schema)
      schema.value == value -> nil
      true -> GlobalSettings.update(schema, value)
    end
  end
end
