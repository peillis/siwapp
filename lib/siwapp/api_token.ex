defmodule Siwapp.ApiToken do
  @signing_salt "siwapp_api"

  def sign(data) do
    Phoenix.Token.sign(SiwappWeb.Endpoint, @signing_salt, data)
  end

  def verify(token) do
    case Phoenix.Token.verify(SiwappWeb.Endpoint, @signing_salt, token) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end
end
