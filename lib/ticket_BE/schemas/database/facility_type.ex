defmodule Ticket_BE.FacilityType do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ticket_BE.Facility

  schema "facility_type" do
    field :name, :string
    has_many :facility, Facility
  end

  @doc false
  def changeset(airport, attrs) do
    airport
    |> cast(attrs, [:name, :city_id, :code, :is_deleted])
  end
end
