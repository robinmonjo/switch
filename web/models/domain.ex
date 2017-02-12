defmodule Switch.Domain do
  use Switch.Web, :model

  schema "domains" do
    field :name, :string
    field :redirect, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :redirect])
    |> validate_required([:name, :redirect])
  end
end
