defmodule Ticket_BE.Facility do
  use Ecto.Schema
  # import Ecto.Changeset
  alias Ticket_BE.FacilityType

  schema "facility" do
    belongs_to :facility_type_id, FacilityType

    # timestamps(type: :utc_datetime)
  end
end
