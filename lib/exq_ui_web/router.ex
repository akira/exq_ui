defmodule ExqUIWeb.Router do
  @doc """

  Exposes ExqUI web interface at the specified
  `path`. `Phoenix.LiveView.Router.live_session/3` is used to wrap all
  the live routes.

  ## Options

  * live_session_name - Name of the live_session. Defaults to `:exq_ui_fork`
  * live_socket_path - Should match the value used for `socket "/live", Phoenix.LiveView.Socket`. Defaults to `/live`
  * live_session_on_mount - Declares an optional module callback to be invoked on the LiveView's mount
  """
  defmacro live_exq_ui(path, opts \\ []) do
    scope =
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

            if Application.compile_env(:exq_ui_fork, :exq_scheduler_name) do
              live "/recurring", ExqUIWeb.RecurringLive.Index, :index, route_opts
            end
          end
        end
      end

    # TODO: Remove check once we require Phoenix v1.7
    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)

        unless Module.get_attribute(__MODULE__, :exq_ui_prefix) do
          @exq_ui_prefix Phoenix.Router.scoped_path(__MODULE__, path)
          def __exq_ui_prefix__, do: @exq_ui_prefix
        end
      end
    else
      scope
    end
  end

  @doc false
  def __options__(options) do
    session_name = options[:live_session_name] || :exq_ui_fork

    session_opts = [
      session: {__MODULE__, :__session__, []},
      root_layout: {ExqUIWeb.LayoutView, :root}
    ]

    on_mount = options[:live_session_on_mount]

    session_opts =
      if on_mount do
        Keyword.put(session_opts, :on_mount, on_mount)
      else
        session_opts
      end

    route_opts = [
      private: %{live_socket_path: Keyword.get(options, :live_socket_path, "/live")},
      as: :exq_ui_fork
    ]

    {session_name, session_opts, route_opts}
  end

  @doc false
  def __session__(_conn) do
    %{}
  end
end
