defmodule Ticket_BEWeb.Authentication do
  use Ticket_BEWeb, :controller
  alias Ticket_BE.Users
  use Guardian, otp_app: :ticket_be

  def sign_up(conn, params) do
    try do
      case Users.sign_user(
        params["email"],
        params["password"],
        params["birthDate"],
        params["fullName"],
        params["gender"],
        params["phone_number"]
      ) do
        {:ok, data} ->
          conn
          |> put_status(:ok)
          |> json(%{data: %{}, message: "success"})

        {:error, changeset} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{data: [], errors: [handle_error(changeset.errors)]})
      end
    catch
      exception ->
        IO.inspect(exception, label: "Exception")

        conn
        |> put_status(:internal_server_error)
        |> json(%{message: exception})
    end
  end

  def sign_in(conn, params)do
    try do
      case Users.get_user_by_email_pwd(
        params["email"],
        params["password"]
      ) do
        {:ok, data} ->
          {:ok, token, _claims} = Guardian.encode_and_sign(data)
          conn
          |> put_status(:ok)
          |> json(%{data: %{
            token: token
          }, message: "success"})

        {:error, msg} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{data: [], errors: [msg]})
      end
    catch
      exception ->
        IO.inspect(exception, label: "Exception")

        conn
        |> put_status(:internal_server_error)
        |> json(%{message: exception})
    end
  end

  def handle_error(resp) do
    {key, {msg, _}} = Enum.at(resp, 0)
    to_string(key) <> ": " <> msg
  end
end
