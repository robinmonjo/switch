defmodule Switch.DomainController do
  use Switch.Web, :controller

  alias Switch.Domain

  def index(conn, _params, user) do
    domains = Repo.all(user_domains(user))
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
        async_validate_name_and_redirect(domain)
        conn
        |> put_flash(:info, "Domain created successfully.")
        |> redirect(to: domain_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    domain = Repo.get!(user_domains(user), id)
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
        async_validate_name_and_redirect(domain)
        delete_cache_entry(domain)
        conn
        |> put_flash(:info, "Domain updated successfully.")
        |> redirect(to: domain_path(conn, :show, domain))
      {:error, changeset} ->
        render(conn, "edit.html", domain: domain, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    domain = Repo.get!(user_domains(user), id)
    delete_cache_entry(domain)

    Repo.delete!(domain)
    conn
    |> put_flash(:info, "Domain deleted successfully.")
    |> redirect(to: domain_path(conn, :index))
  end

  def action(conn, _opts) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  defp user_domains(user) do
    assoc(user, :domains)
  end

  def async_validate_name_and_redirect(domain) do
    Task.async fn ->
      name_ok = Domain.domain_exists?(domain.name)
      redirect_ok = Domain.domain_exists?(domain.redirect)
      changeset = Domain.changeset(domain, %{name_checked: name_ok, redirect_checked: redirect_ok})
      Repo.update(changeset) # ignoring potential errors
    end
  end

  defp delete_cache_entry(domain) do
    table = Application.fetch_env!(:switch, Switch)[:ets_cache_table]
    :ets.delete(table, domain.name)
  end
end
