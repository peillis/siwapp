defmodule Siwapp.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :siwapp

  def send_email(invoice) do
    if invoice.email, do: :ok, else: :error
  end
end
