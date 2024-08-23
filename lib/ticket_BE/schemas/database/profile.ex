defmodule Ticket_BE.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profile" do
    field :birth_date, :utc_datetime
    field :full_name, :string
    field :gender, :string
    field :phone_number, :string
    timestamps()
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:birth_date, :full_name, :gender, :phone_number])
    |> validate_required([:full_name])
  end

end
