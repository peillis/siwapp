defmodule Mix.Tasks.Siwapp do
  use Mix.Task

  @shortdoc "Prints Siwapp scripts help information"

  @impl true
  def run(args) do
    {_opts, args} = OptionParser.parse!(args, strict: [])

    case args do
      [] -> general()
      _ -> Mix.raise("Invalid arguments, expected: mix siwapp")
    end
  end

  defp general() do
    Application.ensure_all_started(:ecto)

    Mix.shell().info("Siwapp")

    Mix.shell().info(
      "An open source web application meant to help manage and create invoices in a simple, straightforward way."
    )

    Mix.shell().info("\nAvailable tasks:\n")

    Mix.Tasks.Help.run(["--search", "siwapp."])
  end
end
