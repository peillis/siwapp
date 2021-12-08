defmodule Siwapp.Repo do
  use Ecto.Repo,
    otp_app: :siwapp,
    adapter: Ecto.Adapters.Postgres
end
