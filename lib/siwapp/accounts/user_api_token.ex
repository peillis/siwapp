defmodule Siwapp.Accounts.UserApiToken do
  use Ecto.Schema

  @signing_salt "siwapp_api"

  schema "users_api_tokens" do
    field :token, :binary

    belongs_to :user, Siwapp.Accounts.User

    timestamps()
  end

  def build_api_token(user) do
    token = sign(%{user_id: user.id})
    {token, %Siwapp.Accounts.UserToken{token: token, user_id: user.id}}
  end

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
