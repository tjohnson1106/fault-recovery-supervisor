defmodule Warehouse.Receiver do
  use GenServer

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
end
