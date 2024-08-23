defmodule Ticket_BE.Flights do
  alias Ticket_BE.Repo
  import Ecto.Query, warn: false

  def list_tickets(
        seat_count,
        departure_date_start,
        departure_date_end,
        class,
        with_airline,
        airlines,
        departure_airport_code,
        arrival_airport_code,
        passengers
      ) do
    sql_cmd = ~c"""
    select
      f.id
      , a."name" as departureName
      , a.code as departureCode
      , a.id as departureAirportId
      , fd.flight_date as departureTime
      , a2.code as arrivalCode
      , a2."name" as arrivalName
      , a2.id as arrivalAirportId
      , fd.flight_date + (INTERVAL '1 minute' * EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time)) / 60) as arrivalTime
      , f.duration
      , a3."name"
      , a3.id as airlineId
      , a3.icon_url as airlineIconUrl
      , as2.price
      , as2.discount
      , STRING_AGG (f2.id || ': ' || f2."name" || ': ' || ft."name", ',') as facility
    from
      flights f
    left join
      flight_date fd on fd.flight_id = f.id
    left join
      available_seat as2 on as2.flight_date_id = fd.id
    left join
      airport a on f.departure_airport_id = a.id
    left join
      city c on a.city_id = c.id
    left join
      airport a2 on f.destination_airport_id = a2.id
    left join
      city c2 on a2.city_id = c2.id
    left join
      airline a3 on f.airline_id = a3.id
    left join
      flight_facility ff on ff.flight_id = f.id
    left join
      facility f2 on f2.id = ff.facility_id
    left join
      facility_type ft on ft.id = f2.facility_type_id

    where
      as2.available_seat_total > $1
      and (fd.flight_date >= $2 and fd.flight_date < $3)
      and as2.flight_class_id = $4
      and (true = $5 or a3.id = any($6))
      and (a.code = $7 or c.code = $7)
      and (a2.code = $8 or c2.code = $8)
    group by
      f.id
      , a."name"
      , a.id
      , a.code
      , fd.flight_date
      , a2."name"
      , a2.id
      , a2.code
      , f.arrival_time
      , f.departure_time
      , f.duration
      , a3."name"
      , a3.id
      , a3.icon_url
      , as2.price
      , as2.discount
    order by
      departure_time
    """

    {:ok, date_start, 0} = DateTime.from_iso8601(departure_date_start)
    {:ok, date_end, 0} = DateTime.from_iso8601(departure_date_end)

    params = [
      seat_count,
      date_start,
      date_end,
      class,
      with_airline,
      airlines,
      departure_airport_code,
      arrival_airport_code
    ]

    result = Repo.query(sql_cmd, params)

    case result do
      {:ok, res} ->
        data =
          res.rows
          |> Enum.map(fn [
                           id,
                           departureCode,
                           departureName,
                           departureAirportId,
                           departureTime,
                           arrivalCode,
                           arrivalName,
                           arrivalAirportId,
                           arrivalTime,
                           duration,
                           airlineName,
                           airlineId,
                           airlineIconUrl,
                           price,
                           discount,
                           facility
                         ] ->
            %{
              ticketId: id,
              departureAirportCode: departureCode,
              departureAirportId: departureAirportId,
              departureTime: departureTime,
              arrivalArrivalCode: arrivalCode,
              arrivalAirportId: arrivalAirportId,
              arrivalTime: arrivalTime,
              durationInMin: duration,
              airline: %{name: airlineName, iconUrl: airlineIconUrl, airlineId: airlineId},
              basePricePerPerson: price,
              discountedPricePerPerson: price - discount,
              withFood: with_food?(facility),
              withLuggage: get_luggage_max(facility) > 0,
              luggage: get_luggage_max(facility),
              ticketDetails:
                get_ticket_details(
                  departureAirportId,
                  departureName,
                  departureTime,
                  arrivalAirportId,
                  arrivalName,
                  arrivalTime,
                  arrange_facility(facility),
                  duration,
                  price,
                  discount,
                  passengers
                )
            }
          end)

        {:ok, data}

      {:error, error} ->
        {:error, "Query error: " <> error.postgres.message}

      _ ->
        {:error, "Something went wrong"}
    end
  end

  defp arrange_facility(facility_string) do
    case facility_string do
      "" ->
        %{}

      _ ->
        String.split(facility_string, ",")
        |> Enum.map(fn item ->
          [id, facility, type] = String.split(item, ": ")

          name =
            case type do
              "Luggage" -> type <> " " <> facility
              "Cabin Luggage" -> type <> " " <> facility
              _ -> facility
            end

          %{
            id: id,
            name: name
          }
        end)
    end
  end

  defp with_food?(facility_string) do
    case facility_string do
      "" ->
        false

      _ ->
        String.split(facility_string, ",")
        |> Enum.any?(fn item ->
          [_, _, type] = String.split(item, ": ")
          type == "Food"
        end)
    end
  end

  defp get_luggage_max(facility_string) do
    case facility_string do
      "" ->
        0

      _ ->
        String.split(facility_string, ",")
        |> Enum.filter(fn item ->
          [_, _, type] = String.split(item, ": ")
          type == "Luggage" || type == "Cabin Luggage"
        end)
        |> Enum.map(fn item ->
          [_, facility, _] = String.split(item, ": ")
          [num, _] = String.split(facility, " ")
          String.to_integer(num)
        end)
        |> Enum.max()
    end
  end

  defp get_ticket_details(
         dep_airport_id,
         dep_airport_name,
         dep_time,
         arr_airport_id,
         arr_airport_name,
         arr_time,
         facility,
         duration_in_min,
         price,
         discount,
         passengers
       ) do
    %{
      departure: %{
        airportId: dep_airport_id,
        airportName: dep_airport_name,
        dateTime: dep_time
      },
      arrival: %{
        airportId: arr_airport_id,
        airportName: arr_airport_name,
        dateTime: arr_time
      },
      facility: facility,
      durationInMin: duration_in_min,
      priceDetails: get_price_details(price, discount, passengers)
    }
  end

  defp get_price_details(price, discount, passengers) do
    basePrice =
      Enum.map(passengers, fn item ->
        {key, value} = item

        case key do
          "infant" ->
            %{
              key => %{
                passengerCount: value,
                price: round(price * 0.1 * value)
              }
            }

          _ ->
            %{
              key => %{
                passengerCount: value,
                price: price * value
              }
            }
        end
      end)

    totalDiscount =
      Enum.reduce(passengers, 0, fn (item, acc) ->
        {key, value} = item

        case key do
          "infant" ->
            acc

          _ ->
            discount * value + acc
        end
      end)

    totalBasePrice =
      Enum.reduce(basePrice, 0, fn (item, acc) ->
        value = Enum.map(item, fn map_data ->
          {_, value} = map_data
          value
        end)
        IO.inspect(item, label: "item")
        Enum.at(value, 0).price + acc
      end)

    %{
      basePriceBreakdown: basePrice,
      totalDiscount: totalDiscount,
      tax: 0,
      total: totalBasePrice - totalDiscount
    }
  end

  def available_airline(
        seat_count,
        departure_date_start,
        departure_date_end,
        class,
        with_airline,
        airlines,
        departure_airport_code,
        arrival_airport_code
      ) do
    sql_cmd = ~c"""
    select
      a3."name"
      , a3.id as airlineId
      , a3.icon_url as airlineIconUrl
    from
      flights f
    left join
      flight_date fd on fd.flight_id = f.id
    left join
      available_seat as2 on as2.flight_date_id = fd.id
    left join
      airport a on f.departure_airport_id = a.id
    left join
      city c on a.city_id = c.id
    left join
      airport a2 on f.destination_airport_id = a2.id
    left join
      city c2 on a2.city_id = c2.id
    left join
      airline a3 on f.airline_id = a3.id
    where
      as2.available_seat_total > $1
      and (fd.flight_date >= $2 and fd.flight_date < $3)
      and as2.flight_class_id = $4
      and (true = $5 or a3.id = any($6) or true=true)
      and (a.code = $7 or c.code = $7)
      and (a2.code = $8 or c2.code = $8)
    group by
      a3."name"
      , a3.id
      , a3.icon_url
    """

    {:ok, date_start, 0} = DateTime.from_iso8601(departure_date_start)
    {:ok, date_end, 0} = DateTime.from_iso8601(departure_date_end)

    params = [
      seat_count,
      date_start,
      date_end,
      class,
      with_airline,
      airlines,
      departure_airport_code,
      arrival_airport_code
    ]

    result = Repo.query(sql_cmd, params)

    case result do
      {:ok, res} ->
        data =
          res.rows
          |> Enum.map(fn [
                           airlineName,
                           airlineId,
                           airlineIconUrl
                         ] ->
            %{
              airlineName: airlineName,
              airlineId: airlineId,
              airlineIconUrl: airlineIconUrl
            }
          end)

        {:ok, data}

      {:error, error} ->
        {:error, "Query error: " <> error.postgres.message}

      _ ->
        {:error, "Something went wrong"}
    end
  end

  def get_ticket_resp(
        seat_count,
        departure_date_start,
        departure_date_end,
        class,
        with_airline,
        airlines,
        departure_airport_code,
        arrival_airport_code,
        passengers
      ) do
    tickets =
      list_tickets(
        seat_count,
        departure_date_start,
        departure_date_end,
        class,
        with_airline,
        airlines,
        departure_airport_code,
        arrival_airport_code,
        passengers
      )

    airlines =
      available_airline(
        seat_count,
        departure_date_start,
        departure_date_end,
        class,
        with_airline,
        airlines,
        departure_airport_code,
        arrival_airport_code
      )

    with {:ok, ticket_data} <- tickets,
         {:ok, airlines_data} <- airlines do
      data = %{availabeAirlines: airlines_data, availableFlight: ticket_data}
      {:ok, data}
    end
  end
end
