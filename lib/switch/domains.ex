defmodule Switch.Domains do
  import Ecto

  alias Switch.Repo
  alias Switch.{Domain, User}

  def list_domains() do
    domains = Repo.all(Domain) |> Repo.preload(:user)
  end

  def create_domain(%User{} = user, attrs \\ {}) do
    changeset =
      user
      |> build_assoc(:domains)
      |> Domain.changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, domain} ->
        Domain.async_validate_name_and_redirect(domain)
        {:ok, domain}
      {:error, changeset} ->
        {:error, changeset}
    end
  end



end
