defmodule Switch.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :admin, :boolean, default: false

    field :password, :string, virtual: true
    field :old_password, :string, virtual: true #used when updating password

    has_many :domains, Switch.Domains.Domain

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :admin])
    |> unique_constraint(:email)
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end

  def registration_changeset(user, params \\ %{}) do
    user
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def update_password_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:old_password, :password])
    |> validate_old_password()
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp validate_old_password(changeset) do
    old_password = get_field(changeset, :old_password)
    user = changeset.data
    if Comeonin.Bcrypt.checkpw(old_password, user.password_hash) do
      changeset
    else
      add_error(changeset, :old_password, "doesn't match")
    end
  end

end
