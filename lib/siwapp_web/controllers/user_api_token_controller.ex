defmodule SiwappWeb.UserApiTokenController do
  use SiwappWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end
  
  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end
end
