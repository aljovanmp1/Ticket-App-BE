defmodule Ticket_BE.Airports do
  alias Ticket_BE.Repo
  import Ecto.Query, warn: false

  def list_airport do
    Repo.all(
      from(u in Ticket_BE.Airport,
        where: u.is_deleted == false
      )
    )
    |> Enum.map(fn airport ->
      airport
      |> Map.from_struct()
      |> Map.delete(:__meta__)
    end)
  end

  def list_airport_with_city do
    sql_cmd = ~c"""
    with
      get_max_id as (
        select
          MAX(a.id) as maxId
        from
          airport a
      )

    select
      a.id
      , a."name"
      , a.code
      , c."name"
    from
      airport a
    left join
      city c ON a.city_id = c.id
    where
      a.is_deleted = false
    union
    select
      gmi.maxId + ROW_NUMBER() OVER (ORDER BY c2."name") AS id
      , CONCAT('Semua bandara di ', c2."name")
      , c2.code
      , c2."name"
    from
      city c2
    cross join
      get_max_id as gmi
    where
      c2.multiple_airport_flag = true
    order by
      id
    """

    result = Repo.query(sql_cmd)
    # IO.inspect(result)
    # result = {:error}

    case result do
      {:ok, res} ->
        data = res.rows
        |> Enum.map(fn [id, name, code, city_name] ->
          %{
            id: id,
            name: name,
            code: code,
            cityName: city_name
          }
        end)
        {:ok, data}
      {:error, _} ->
        {:error, "Query failed"}
      _ ->
        {:error, "Something went wrong"}
    end
  end
end
