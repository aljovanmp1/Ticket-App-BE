defmodule Ticket_BE.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:email]}
  schema "users" do
    field :email, :string
    field :enabled, :boolean
    field :otp, :string
    field :otp_expired_date, :utc_datetime
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :password, :string
    field :is_deleted, :boolean
    belongs_to :profile, Ticket_BE.Profile
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :enabled, :is_deleted, :created_at, :updated_at, :profile_id])
    |> validate_required([:email, :password])
    |> unique_constraint(:email, name: :users_email_key)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if changeset |> get_change(:password) do
      put_change(changeset, :password, Bcrypt.hash_pwd_salt(changeset |> get_change(:password)))
    else
      changeset
    end
  end
end
