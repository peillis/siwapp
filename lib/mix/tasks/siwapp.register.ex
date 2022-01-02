defmodule Mix.Tasks.Siwapp.Register do
  use Mix.Task
  alias Siwapp.Accounts

  @shortdoc "Register a new user"

  @moduledoc """
  Register a new user for a given email and password passed by the arguments.

  ## Examples

    $ mix siwapp.register "demo@example.com" "secret_pass"
  """
  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    validate_args!(args)

    [email, password] = args

    register_user(email, password)
  end

  defp register_user(email, password) do
    case Accounts.register_user(%{email: email, password: password}) do
      {:ok, user} ->
        IO.puts("User with email #{user.email} created successfully.")
        :ok

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts(changeset.errors)
        Mix.raise("Sorry. The user hasn't been created.")
    end
  end

  defp validate_args!([_, _]), do: :ok

  defp validate_args!(_) do
    raise_with_help("Invalid arguments")
  end

  defp raise_with_help(msg) do
    Mix.raise("""
    #{msg}

    mix siwapp.register expects an email and a password for the user
    that is going to be registered in the Siwapp system.

    For example:
        mix siwapp.register "demo@example.com" "secret_pass"
    """)
  end
end
