defmodule Siwapp.ApiToken do
  @signing_salt "siwapp_api"

  # 3 hours
  @token_age_secs 3 * 3_600

  def sign(data) do
    Phoenix.Token.sign(SiwappWeb.Endpoint, @signing_salt, data)
  end

  def verify(token) do
    case Phoenix.Token.verify(SiwappWeb.Endpoint, @signing_salt, token, max_age: @token_age_secs) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end
end
