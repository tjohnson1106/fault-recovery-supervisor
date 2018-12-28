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

  # start process and call deliver packages

  def handle_cast({:receive_packages, packages}, state) do
    IO.puts("received #{Enum.count(packages)}")

    {:ok, deliverator} = Deliverator.start()
    Process.monitor(deliverator)
    state = assign_packages(state, packages, deliverator)

    Deliverator.deliver_packages(deliverator, packages)
    {:noreply, state}
  end

  def handle_info({:package_delivered, package}, state) do
    IO.puts("package #{inspect(package)} was delivered")

    delivered_assignments =
      state.assignments
      |> Enum.filter(fn {assigned_package, _pid} ->
        assigned_package == package
      end)

    assignments = state.assignments -- delivered_assignments
    state = %{state | assignments: assignments}
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, deliverator, :normal}, state) do
    IO.puts("deliverator #{inspect(deliverator)} completed the mission and terminated")
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, deliverator, reason}, state) do
    IO.puts("deliverator #{inspect(deliverator)} went down. details: #{inspect(reason)}")
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
