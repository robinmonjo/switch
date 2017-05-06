defmodule Switch.Domains do
  import Ecto

  alias Switch.Repo
  alias Switch.{Domain, User}
  alias Switch.DomainsCache, as: Cache

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
        async_validate_name_and_redirect(domain)
        {:ok, domain}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_domain(%Domain{} = domain, attrs) do
    changeset = Domain.changeset(domain, attrs)
    case Repo.update(changeset) do
      {:ok, domain} ->
        async_validate_name_and_redirect(domain)
        Cache.delete(domain.name)
        {:ok, domain}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp domain_exists?(url) do
    host = URI.parse(url).host
    case host |> to_char_list |> :inet.gethostbyname do
      {:error, :nxdomain} -> false
      _ -> true
    end
  end

  def async_validate_name_and_redirect(domain) do
    Task.async fn ->
      name_ok = domain_exists?(domain.name)
      redirect_ok = domain_exists?(domain.redirect)
      Domain.changeset(domain, %{name_checked: name_ok, redirect_checked: redirect_ok})
      |> Switch.Repo.update
    end
  end



end
