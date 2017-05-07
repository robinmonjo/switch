defmodule Switch.Domains do
  import Ecto

  alias Switch.Repo
  alias Switch.{Domain, User}
  alias Switch.DomainsCache, as: Cache

  def list_domains() do
    domains = Repo.all(Domain)
    Repo.preload(domains, :user)
  end

  def get_domain!(%User{} = user, id) do
    Repo.get!(user_domains(user), id)
  end

  def get_domain!(id), do: Repo.get!(Domain, id)

  defp user_domains(user) do
    if user.admin, do: Domain, else: assoc(user, :domains)
  end

  def new_domain_changeset(%User{} = user) do
    user
    |> build_assoc(:domains)
    |> Domain.changeset()
  end

  def domain_changeset(%Domain{} = domain) do
    Domain.changeset(domain)
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

  def delete_domain(%Domain{} = domain) do
    Cache.delete(domain.name)
    Repo.delete(domain)
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
      changeset = Domain.changeset(domain, %{name_checked: name_ok, redirect_checked: redirect_ok})
      Switch.Repo.update(changeset)
    end
  end

end
