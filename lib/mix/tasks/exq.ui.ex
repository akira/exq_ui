defmodule Mix.Tasks.Exq.Ui do
  use Mix.Task

  @shortdoc "Starts the Exq UI Server"

  def run(_args) do
    ExqUi.launch_app
    :timer.sleep(:infinity)
  end
end
