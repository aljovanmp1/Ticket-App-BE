defmodule Ticket_BE.Repo.Migrations.AddFacilityType do
  use Ecto.Migration

  def change do

    # Create `facility_type` table
    create table(:facility_type) do
      add :name, :string, null: false
      timestamps()
    end

    # Add new column `facility_type_id` to `facility` table
    alter table(:facility) do
      add :facility_type_id, references(:facility_type, on_delete: :nothing)
    end

    # Add a foreign key constraint on `facility_type_id` in the `facility` table
    create index(:facility, [:facility_type_id])
  end
end
