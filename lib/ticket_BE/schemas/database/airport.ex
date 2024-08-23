defmodule Ticket_BE.Airport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "airport" do
    field :name, :string
    field :city_id, :integer
    field :code, :string
    field :is_deleted, :boolean

    # timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(airport, attrs) do
    airport
    |> cast(attrs, [:name, :city_id, :code, :is_deleted])
  end
end
