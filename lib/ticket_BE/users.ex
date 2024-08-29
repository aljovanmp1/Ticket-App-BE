defmodule Ticket_BE.Users do
  alias Ticket_BE.Repo
  alias Ticket_BE.User
  alias Ticket_BE.Profile
  import Ecto.Query, warn: false

  def get_user_by_email_pwd(email, pwd) do
    user =
      Repo.one(
        from(u in Ticket_BE.User,
          where: u.is_deleted == false and u.email == ^email
        )
      )

    case user do
      %User{password: hashed_pwd} ->
        if Bcrypt.verify_pass(pwd, hashed_pwd) do
          {:ok, user}
        else
          {:error, "invalid_password"}
        end
      nil ->
        {:error, "User not found"}
    end
  end

  def get_user_by_id(id) do
    Repo.one(
      from(u in Ticket_BE.User,
        where: u.is_deleted == false and u.id == ^id
      )
    )
  end

  def sign_user(email, password, birth_date, full_name, gender, phone_number) do
    user_attr = %{
      email: email,
      password: password,
      enabled: false,
      is_deleted: false,
      created_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    profile_attr = %{
      birth_date: birth_date,
      full_name: full_name,
      gender: gender,
      phone_number: phone_number
    }

    Repo.transaction(fn ->
      with {:ok, profile_data} <-
             %Profile{}
             |> Profile.changeset(profile_attr)
             |> Repo.insert(),
           {:ok, user_attr} <-
             %User{}
             |> User.changeset(Map.put(user_attr, :profile_id, profile_data.id))
             |> Repo.insert() do
        {:ok, "success"}
      else
        {:error, err} ->
          Repo.rollback(err)
      end
    end)
  end

  def get_user_profile(id) do
    sql_cmd = """
    select
      u.email
      , p.birth_date
      , p.full_name
      , p.gender
      , p.phone_number
    from
      users u
    left join
      profile p on u.profile_id = p.id
    where
      u.id = $1
    """
    params = [id]
    result = Repo.query(sql_cmd, params)

    case result do
      {:ok, res} ->
        data =
          res.rows
          |> Enum.map(fn [
            email,
            birth_date,
            full_name,
            gender,
            phone_number
          ] ->
            %{
              email: email,
              birthDate: birth_date,
              fullName: full_name,
              gender: gender,
              phoneNumber: phone_number
            }
          end)
        {:ok, data}
      {:error, error} ->
        {:error, "Query error: " <> error.postgres.message}

      _ ->
        {:error, "Something went wrong"}
    end

  end
end
