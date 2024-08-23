defmodule Ticket_BEWeb.LandingPage do
    use Ticket_BEWeb, :controller

    def index(conn, _params) do
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "Haii!")
    end
end
