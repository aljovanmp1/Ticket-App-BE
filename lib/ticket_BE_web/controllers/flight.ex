defmodule Ticket_BEWeb.Flight do
  use Ticket_BEWeb, :controller
  alias Ticket_BE.Airports
  alias Ticket_BE.FlightClasses
  alias Ticket_BE.GetTicket
  alias Ticket_BE.Flights

  def get_flight_class(conn, _params) do
    try do
      classes = FlightClasses.list_classes()
      # IO.inspect(classes)
      conn
      |> put_status(:ok)
      |> json(%{data: classes})
    catch
      exception ->
        IO.inspect(exception, label: "Exception")

        conn
        |> put_status(:internal_server_error)
        |> json(%{message: exception})
    end
  end

  def get_airport(conn, _params) do
    try do
      airport = Airports.list_airport_with_city()

      # IO.inspect(airport)
      case airport do
        {:ok, data} ->
          conn
          |> put_status(:ok)
          |> json(%{data: data})

        {:error, msg} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{msg: msg})
      end
    catch
      exception ->
        IO.inspect(exception, label: "Exception")

        conn
        |> put_status(:internal_server_error)
        |> json(%{message: exception})
    end
  end

  def get_ticket(conn, params) do
    try do
      changeset = GetTicket.changeset(%GetTicket{}, params)

      # IO.inspect(changeset, label: "changeset123")
      # IO.inspect(params,  label: "passenger32")

      if !changeset.valid? do
        conn
        |> put_status(:bad_request)
        |> json(%{data: %{}, errors: changeset.errors})
      else
        seat = params["passenger"]["adult"] + params["passenger"]["child"]
        with_airline = length(params["airlineId"]) < 1

        tickets =
          Flights.get_ticket_resp(
            seat,
            params["departureDateStart"],
            params["departureDateEnd"],
            params["classId"],
            with_airline,
            params["airlineId"],
            params["departureCode"],
            params["arrivalCode"],
            params["passenger"]
          )

        case tickets do
          {:ok, data} ->
            conn
            |> put_status(:ok)
            |> json(%{data: data})
          {:error, msg} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{data: [], errors: [msg]})
        end


      end
    catch
      exception ->
        IO.inspect(exception, label: "Exception")

        conn
        |> put_status(:internal_server_error)
        |> json(%{message: exception})
    end
  end
end
