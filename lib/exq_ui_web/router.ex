defmodule ExqUIWeb.Router do
  defmacro live_exq_ui(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        {session_name, session_opts, route_opts} = ExqUIWeb.Router.__options__(opts)
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        live_session session_name, session_opts do
          live "/", ExqUIWeb.DashboardLive, :root, route_opts
          live "/queues", ExqUIWeb.QueueLive.Index, :index, route_opts
          live "/queues/:name", ExqUIWeb.QueueLive.Show, :index, route_opts
          live "/retries", ExqUIWeb.RetryLive.Index, :index, route_opts
          live "/retries/:score/:jid", ExqUIWeb.RetryLive.Show, :index, route_opts
          live "/dead", ExqUIWeb.DeadLive.Index, :index, route_opts
          live "/dead/:score/:jid", ExqUIWeb.DeadLive.Show, :index, route_opts
          live "/scheduled", ExqUIWeb.ScheduledLive, :index, route_opts
        end
      end
    end
  end

  @doc false
  def __options__(options) do
    live_socket_path = Keyword.get(options, :live_socket_path, "/live")

    {
      options[:live_session_name] || :exq_ui,
      [
        session: {__MODULE__, :__session__, []},
        root_layout: {ExqUIWeb.LayoutView, :root}
      ],
      [
        private: %{live_socket_path: live_socket_path},
        as: :exq_ui
      ]
    }
  end

  @doc false
  def __session__(_conn) do
    %{}
  end
end
