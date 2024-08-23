defmodule Ticket_BE.FlightClasses do
  alias Ticket_BE.Repo
  import Ecto.Query, warn: false

  def list_classes do
    Repo.all(
      from(fc in "flight_class",
            select: %{id: fc.id, name: fc.name}
      )
    )
  end
end
