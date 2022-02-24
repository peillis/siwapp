defmodule Siwapp.InvoicesGenerator do
  @moduledoc """
  Module to generate invoices automatically
  """
  use GenServer

  alias Siwapp.RecurringInvoices

  @spec start_link :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  @spec init(%{}) :: {:ok, %{}}
  def init(state) do
    generate_invoices()
    schedule_work()
    {:ok, state}
  end

  @spec handle_info(:generate_invoices, %{}) :: {:noreply, %{}}
  def handle_info(:generate_invoices, state) do
    generate_invoices()
    schedule_work()
    {:noreply, state}
  end

  @spec schedule_work :: reference()
  defp schedule_work do
    Process.send_after(self(), :generate_invoices, 24 * 60 * 60 * 1000)
  end

  @spec generate_invoices :: :ok
  defp generate_invoices do
    [select: [:id], limit: false]
    |> RecurringInvoices.list()
    |> Enum.each(&RecurringInvoices.generate_invoices(&1.id))
  end
end
