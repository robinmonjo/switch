defmodule Switch.User do
  use Switch.Web, :model

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :admin, :boolean, default: false

    has_many :domains, Switch.Domain

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

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

end
