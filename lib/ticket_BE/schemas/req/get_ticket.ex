defmodule Ticket_BE.GetTicket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gettickets" do
    field :airlineId, {:array, :integer}
    field :arrivalCode, :string
    field :classId, :integer
    field :dataPerPage, :integer
    field :departureCode, :string
    field :departureDateEnd, :utc_datetime
    field :departureDateStart, :utc_datetime
    field :page, :integer
    field :passenger, :map
    field :sortBy, {:array, :string}
  end

  def changeset(gettickets, attrs) do
    gettickets
    |> cast(attrs, [
      :airlineId,
      :arrivalCode,
      :classId,
      :dataPerPage,
      :departureCode,
      :departureDateEnd,
      :departureDateStart,
      :page,
      :passenger,
      :sortBy
    ])
    |> validate_required([
      :airlineId,
      :arrivalCode,
      :classId,
      :dataPerPage,
      :departureCode,
      :departureDateEnd,
      :departureDateStart,
      :page,
      :passenger,
      :sortBy
    ])
    |> validate_change(:passenger, &validate_passengers/2)
  end

  defp validate_passengers(:passenger, %{} = passenger) do
    required_keys = ~w(adult infant child)
    missing_keys = required_keys -- Map.keys(passenger)

    if missing_keys == [] do
      []
    else
      error_message = "Passenger key must contain #{Enum.join(missing_keys, ", ")} keys"
      [{:passenger, error_message}]
    end
  end
end
