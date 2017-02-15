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
    |> validate_uri(:name)
    |> validate_uri(:redirect)
  end


  defp validate_uri(changeset, field) do
    validate_change changeset, field, fn _, url ->
      uri = URI.parse(url)
      with :ok <- validate_scheme(uri.scheme),
           :ok <- validate_host(uri.host)
      do
        []
      else
        {:error, mess} -> [{field, mess}]
      end
    end
  end

  defp validate_scheme("http"), do: :ok
  defp validate_scheme("https"), do: :ok
  defp validate_scheme(nil), do: {:error, "missing HTTP or HTTPS scheme"}
  defp validate_scheme(_invalid), do: {:error, "only HTTP and HTTPS schemes are alowed"}

  defp validate_host(nil), do: {:error, "host can't be nil"}
  defp validate_host(_anything), do: :ok

end
