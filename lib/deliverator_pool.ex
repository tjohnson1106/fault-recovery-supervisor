defmodule Warehouse.DeliveratorPool do
  use GenServer
  alias Warehouse.{Deliverator}
  @max 20

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    state = %{
      deliverators: [],
      max: @max
    }

    {:ok, state}
  end

  @doc """
  returns {:ok, pid} or {:error, message}
  """

  def available_deliverator do
    #
  end

  def flag_deliverator_busy(deliverator) do
    #
  end

  def flag_deliverator_idle(deliverator) do
    #
  end

  def remove_deliverator(deliverator) do
    #
  end
end
