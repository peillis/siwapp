defmodule SiwappWeb.MetaAttributesComponent do
  use SiwappWeb, :live_component

  def render(%{meta_attributes: meta_attributes} = assigns) do
    ~H"""
    <fieldset>
    <%= for {k, v} <- meta_attributes do %>
      <input type="text" name="meta[keys][]" value={k} />
      <input type="text" name="meta[values][]" value={v} />
      <br/>
    <% end %>
      <input type="text" name="meta[keys][]" />
      <input type="text" name="meta[values][]" />
      <br/>
    </fieldset>
    """
  end
end
