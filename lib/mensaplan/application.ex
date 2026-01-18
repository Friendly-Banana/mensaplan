defmodule Mensaplan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MensaplanWeb.Telemetry,
      Mensaplan.Repo,
      {DNSCluster, query: Application.get_env(:mensaplan, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mensaplan.PubSub},
      # Start a worker by calling: Mensaplan.Worker.start_link(arg)
      # {Mensaplan.Worker, arg},
      # Start to serve requests, typically the last entry
      MensaplanWeb.Endpoint
    ]

    children =
      if Application.get_env(:mensaplan, :environment, :dev) == :test,
        do: children,
        else: [Mensaplan.Periodically] ++ children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mensaplan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MensaplanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
