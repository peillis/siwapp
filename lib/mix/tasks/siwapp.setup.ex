defmodule Mix.Tasks.Siwapp.Setup do
  @shortdoc "Deletes all data and puts some demo data"

  @moduledoc """
  Only 'force' option can be provided in order to avoid
  being asked for confirmation. If any other is given,
  task won't be completed
  ## Examples

    $ mix siwapp.setup
    This will remove all data in database. Are you sure? [y/n]

    $ mix siwapp.setup force
    All data's been substituted by demo

    $ mix siwapp.setp DoesNotExistArg
    Sorry, can't understand that command
  """
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    validate_args!(args)

    take_action(args)
  end

  @spec take_action(list) :: :ok | no_return()
  defp take_action(["force"]) do
    setup_db()
  end

  defp take_action(_args) do
    case IO.gets("\n This will remove all data in database. Are you sure? [y/n]") do
      "y\n" ->
        setup_db()

      _ ->
        IO.puts("Operation aborted")
    end
  end

  @spec validate_args!(list | term()) :: no_return()
  defp validate_args!(["force"]), do: :ok

  defp validate_args!([]), do: :ok

  defp validate_args!(_) do
    raise_with_help("Sorry, can't understand that command")
  end

  @spec raise_with_help(binary) :: no_return()
  defp raise_with_help(msg) do
    Mix.raise("""
    #{msg}

    mix siwapp.setup only accepts 'force' argument as an
    option to confirm operation and avoid confirmation need

    You can try interactive task:
      mix siwapp.setup
    or force that with:
      mix siwapp.setup force
    """)
  end

  @spec setup_db :: :ok
  defp setup_db do
    Mix.Task.run("ecto.reset", [])
    Mix.Task.run("siwapp.register", ["demo@example.com", "secretsecret", "true"])
  end
end
