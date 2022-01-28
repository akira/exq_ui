defmodule ExqUIWeb.Router do
  @doc """

  Exposes ExqUI web interface at the specified
  `path`. `Phoenix.LiveView.Router.live_session/3` is used to wrap all
  the live routes.

  ## Options

  * live_session_name - Name of the live_session. Defaults to `:exq_ui`
  * live_socket_path - Should match the value used for `socket "/live", Phoenix.LiveView.Socket`. Defaults to `/live`
  """
  defmacro live_exq_ui(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        {session_name, session_opts, route_opts} = ExqUIWeb.Router.__options__(opts)
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        live_session session_name, session_opts do
          live "/", ExqUIWeb.DashboardLive, :root, route_opts
          live "/queues", ExqUIWeb.QueueLive.Index, :index, route_opts
          live "/queues/:name", ExqUIWeb.QueueLive.Show, :index, route_opts
          live "/busy", ExqUIWeb.BusyLive.Index, :index, route_opts
          live "/retries", ExqUIWeb.RetryLive.Index, :index, route_opts
          live "/retries/:score/:jid", ExqUIWeb.RetryLive.Show, :index, route_opts
          live "/dead", ExqUIWeb.DeadLive.Index, :index, route_opts
          live "/dead/:score/:jid", ExqUIWeb.DeadLive.Show, :index, route_opts
          live "/scheduled", ExqUIWeb.ScheduledLive.Index, :index, route_opts
          live "/scheduled/:score/:jid", ExqUIWeb.ScheduledLive.Show, :index, route_opts
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
        root_layout: {ExqUIWeb.LayoutView, :root},
        on_mount: options[:live_session_on_mount] || __MODULE__
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

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
