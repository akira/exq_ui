children = [
  {Phoenix.PubSub, name: ExqUI.PubSub},
  DemoWeb.Endpoint,
  {Redix, name: :redix}
]

{:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)

ExUnit.start()
