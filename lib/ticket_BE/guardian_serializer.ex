defmodule Ticket_BE.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Ticket_BE.User
  alias Ticket_BE.Users

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("User:" <> id), do: {:ok, Users.get_user_by_id(id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end
