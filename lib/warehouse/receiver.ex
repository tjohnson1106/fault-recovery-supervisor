defmodule Warehouse.Receiver do
  use GenServer
  alias Warehouse.Deliverator

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # define state consisting of package assignments

  def init(_) do
    state = %{
      assignments: []
    }

    {:ok, state}
  end

  # receive a batch of packages and start and assign processes 

  def receive_packages(packages) do
    GenServer.cast(__MODULE__, {:receive_packages, packages})
  end

  def handle_cast({:receive_packages, packages}, state) do
    IO.puts("received #{Enum.count(packages)}")
    {:ok, deliverator} = Deliverator.start()
    state = assign_packages(state, packages, deliverator)
    Warehouse.Deliverator.deliver_packages(deliverator, packages)
    {:noreply, state}
  end

  def handle_info({:package_delivered, package}, state) do
    IO.puts("package #{inspect(package)} was delivered")
    {:noreply, state}
  end

  defp assign_packages(state, packages, deliverator) do
    new_assignments =
      packages
      |> Enum.map(fn package -> {package, deliverator} end)

    assignments = state.assignments ++ new_assignments
    %{state | assignments: assignments}
  end
end
