defmodule Switch.DomainService do
  use Switch.Web, :service

  alias Switch.Domain

  def insert(params) do
    changeset = Domain.changeset(%Domain{}, params)
    Repo.insert(changeset) |> after_save
  end

  def update(domain, params) do
    changeset = Domain.changeset(domain, params)
    Repo.update(changeset) |> after_save
  end

  defp after_save(repo_op_result) do
    case repo_op_result do
      {:ok, domain} ->
        async_validate_name_and_redirect(domain)
      _ -> :ok
    end
    repo_op_result
  end

  def delete(domain) do
    # delete cache
    table = Application.fetch_env!(:switch, Switch)[:ets_cache_table]
    :ets.delete(table, domain.name)
    Repo.delete!(domain)
  end

  def async_validate_name_and_redirect(%{id: id}) do
    Task.async fn ->
      domain = Repo.get!(Domain, id)
      name_ok = domain_exists?(domain.name)
      redirect_ok = domain_exists?(domain.redirect)
      cs = Domain.changeset(domain, %{name_checked: name_ok, redirect_checked: redirect_ok})
      Repo.update(cs) # ignoring potential errors
    end
  end

  defp domain_exists?(url) do
    host = URI.parse(url).host
    case host |> to_char_list |> :inet.gethostbyname do
      {:error, :nxdomain} -> false
      _ -> true
    end
  end

end
