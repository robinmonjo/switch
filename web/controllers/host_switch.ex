defmodule Switch.HostSwitch do
  import Plug.Conn

  alias Switch.Repo
  alias Switch.DomainsCache, as: Cache

  import Ecto.Query

  @hostname Application.fetch_env!(:switch, Switch)[:hostname]

  # the plug that performs the domain switch
  def init(opts), do: opts

  # if host is app host, the user wants to access the app
  def call(%{host: @hostname} = conn, _opts), do: conn

  # else this request should be redirected
  def call(%{host: host, scheme: scheme, request_path: request_path, query_string: query_string} = conn, _opts) do
    case lookup_redirect("#{scheme}://#{host}") do
      {:ok, redirect} ->
        query = if query_string == "", do: "", else: "?#{query_string}"
        conn
        |> put_resp_header("location", "#{redirect}#{request_path}#{query}")
        |> resp(302, "You are being redirected.")
        |> halt
      :no_match ->
        conn
        |> Phoenix.Controller.render(Switch.RootView, "not_found.html", %{})
        |> halt
    end
  end

  defp lookup_redirect(url) do
    case Cache.lookup(url) do
      :not_found ->
        lookup_redirect_in_db(url)
      redirect_url ->
        {:ok, redirect_url}
    end
  end

  defp lookup_redirect_in_db(url) do
    query = from d in "domains",
            where: d.name == ^url,
            select: d.redirect

    case Repo.all(query) do
      [redirect | _] ->
        Cache.add(url, redirect)
        {:ok, redirect}
      _ ->
        :no_match
    end
  end

end
