defmodule Ticket_BEWeb.GuardianPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :ticket_BE,
    module: Ticket_BE.Guardian,
    error_handler: Ticket_BEWeb.GuardianErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
