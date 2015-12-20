defmodule ExqUi do
  require Logger
  alias Exq.Support.Config
  use Application

  # OTP Application
  def start(_type, _args) do
    Exq.Manager.Supervisor.start_link
  end
end
