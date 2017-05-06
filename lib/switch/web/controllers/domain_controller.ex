defmodule Switch.Web.DomainController do
  use Switch.Web, :controller

  alias Switch.Domain
  alias Switch.Domains
  alias Switch.DomainsCache, as: Cache

  def index(conn, _params, _user) do
    domains = Domains.list_domains()

    render(conn, "index.html", domains: domains)
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> build_assoc(:domains)
      |> Domain.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"domain" => domain_params}, user) do
    changeset =
      user
      |> build_assoc(:domains)
      |> Domain.changeset(domain_params)

    case Repo.insert(changeset) do
      {:ok, domain} ->
        Domain.async_validate_name_and_redirect(domain)
        conn
        |> put_flash(:info, "Domain created successfully.")
        |> redirect(to: domain_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _user) do
    domain = Repo.get!(Domain, id)
    render(conn, "show.html", domain: domain)
  end

  def edit(conn, %{"id" => id}, user) do
    domain = Repo.get!(user_domains(user), id)
    changeset = Domain.changeset(domain)
    render(conn, "edit.html", domain: domain, changeset: changeset)
  end

  def update(conn, %{"id" => id, "domain" => domain_params}, user) do
    domain = Repo.get!(user_domains(user), id)
    changeset = Domain.changeset(domain, domain_params)
    case Repo.update(changeset) do
      {:ok, domain} ->
        Domain.async_validate_name_and_redirect(domain)
        Cache.delete(domain.name)
        conn
        |> put_flash(:info, "Domain updated successfully.")
        |> redirect(to: domain_path(conn, :show, domain))
      {:error, changeset} ->
        render(conn, "edit.html", domain: domain, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    domain = Repo.get!(user_domains(user), id)
    Cache.delete(domain.name)

    Repo.delete!(domain)
    conn
    |> put_flash(:info, "Domain deleted successfully.")
    |> redirect(to: domain_path(conn, :index))
  end

  def action(conn, _opts) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  defp user_domains(user) do
    if user.admin, do: Domain, else: assoc(user, :domains)
  end

end
