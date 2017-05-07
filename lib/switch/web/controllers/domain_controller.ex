defmodule Switch.Web.DomainController do
  use Switch.Web, :controller

  alias Switch.Domains

  def index(conn, _params, _user) do
    domains = Domains.list_domains()
    render(conn, "index.html", domains: domains)
  end

  def new(conn, _params, user) do
    changeset = Domains.new_domain_changeset(user)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"domain" => domain_params}, user) do
    case Domains.create_domain(user, domain_params) do
      {:ok, _domain} ->
        conn
        |> put_flash(:info, "Domain created successfully.")
        |> redirect(to: domain_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _user) do
    domain = Domains.get_domain!(id)
    render(conn, "show.html", domain: domain)
  end

  def edit(conn, %{"id" => id}, user) do
    domain = Domains.get_domain!(user, id)
    changeset = Domains.domain_changeset(domain)
    render(conn, "edit.html", domain: domain, changeset: changeset)
  end

  def update(conn, %{"id" => id, "domain" => domain_params}, user) do
    domain = Domains.get_domain!(user, id)
    case Domains.update_domain(domain, domain_params) do
      {:ok, domain} ->
        conn
        |> put_flash(:info, "Domain updated successfully.")
        |> redirect(to: domain_path(conn, :show, domain))
      {:error, changeset} ->
        render(conn, "edit.html", domain: domain, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    domain = Domains.get_domain!(user, id)

    {:ok, _domain} = Domains.delete_domain(domain)

    conn
    |> put_flash(:info, "Domain deleted successfully.")
    |> redirect(to: domain_path(conn, :index))
  end

  def action(conn, _opts) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end
end
