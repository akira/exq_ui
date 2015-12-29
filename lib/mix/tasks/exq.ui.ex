defmodule Mix.Tasks.Exq.Ui do
  use Mix.Task

  @shortdoc "Starts the Exq UI Server"

  def run(args) do
    Mix.Task.run "run", ["--no-halt"] ++ args
  end

end
