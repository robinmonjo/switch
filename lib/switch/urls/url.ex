defmodule Switch.Urls.Url do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "urls" do
    field :source, :string
    field :destination, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(url, params \\ %{}) do
    url
    |> cast(params, [:source, :destination])
    |> unique_constraint(:source)
    |> validate_required([:source, :destination])
  end
end
