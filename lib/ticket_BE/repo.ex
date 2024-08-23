defmodule Ticket_BE.Repo do
  use Ecto.Repo,
    otp_app: :ticket_BE,
    adapter: Ecto.Adapters.Postgres
end
