defmodule Siwapp.InvoicesGenerator do
  @moduledoc """
  Module to generate invoices automatically
  """
  use GenServer

  alias Siwapp.RecurringInvoices

  @spec start_link([]) :: {:ok, pid}
  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  @spec init(nil) :: {:ok, nil}
  def init(nil) do
    RecurringInvoices.generate_invoices()
    schedule_work()
    {:ok, nil}
  end

  @spec handle_info(:generate_invoices, nil) :: {:noreply, nil}
  def handle_info(:generate_invoices, nil) do
    RecurringInvoices.generate_invoices()
    schedule_work()
    {:noreply, nil}
  end

  @spec schedule_work :: reference()
  defp schedule_work do
    Process.send_after(self(), :generate_invoices, :timer.hours(24))
  end
end
