defmodule Ticket_BE.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Ticket_BEWeb.Telemetry,
      Ticket_BE.Repo,
      {DNSCluster, query: Application.get_env(:ticket_BE, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ticket_BE.PubSub},
      # Start a worker by calling: Ticket_BE.Worker.start_link(arg)
      # {Ticket_BE.Worker, arg},
      # Start to serve requests, typically the last entry
      Ticket_BEWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ticket_BE.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Ticket_BEWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
