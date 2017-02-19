defmodule Switch.Domain do
  use Switch.Web, :model

  schema "domains" do
    field :name, :string
    field :redirect, :string

    field :name_checked, :boolean, default: false
    field :redirect_checked, :boolean, default: false

    timestamps()
  end

  def async_validate_name_and_redirect(domain) do
    Task.async fn ->
      name_ok = domain_exists?(domain.name)
      redirect_ok = domain_exists?(domain.redirect)
      cs = changeset(domain, %{name_checked: name_ok, redirect_checked: redirect_ok})
      Switch.Repo.update(cs) # ignoring potential errors
    end
  end

  defp domain_exists?(url) do
    host = URI.parse(url).host
    case host |> to_char_list |> :inet.gethostbyname do
      {:error, :nxdomain} -> false
      _ -> true
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(domain, params \\ %{}) do
    domain
    |> cast(params, [:name, :redirect, :name_checked, :redirect_checked])
    |> unique_constraint(:name) # this is not working :(
    |> validate_required([:name, :redirect])
    |> validate_redirect_not_equal_name
    |> validate_uri(:name)
    |> validate_uri(:redirect)
  end


  defp validate_uri(changeset, field) do
    validate_change changeset, field, fn _, url ->
      uri = URI.parse(url)
      with :ok <- validate_scheme(uri.scheme),
           :ok <- validate_host(uri.host),
           :ok <- validate_path(uri.path)
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

  defp validate_path(nil), do: :ok
  defp validate_path(_anything), do: {:error, "no path must be set"}

  defp validate_redirect_not_equal_name(changeset) do
    validate_change changeset, :redirect, fn _, redirect ->
      if get_change(changeset, :name) == redirect do
        [{:redirect, "must be different than name"}]
      else
        []
      end
    end
  end

end
