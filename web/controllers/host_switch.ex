defmodule Switch.HostSwitch do
  import Plug.Conn

  alias Switch.Repo
  import Ecto.Query

  @hostname Application.fetch_env!(:switch, Switch)[:hostname]
  @ets_cache_table Application.fetch_env!(:switch, Switch)[:ets_cache_table]

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
    case :ets.lookup(@ets_cache_table, url) do
      [{_, redirect} | _] ->
        {:ok, redirect}
      _ ->
        lookup_redirect_in_db(url)
    end
  end

  defp lookup_redirect_in_db(url) do
    query = from d in "domains",
            where: d.name == ^url,
            select: d.redirect

    case Repo.all(query) do
      [redirect | _] ->
        :ets.insert(@ets_cache_table, {url, redirect})
        {:ok, redirect}
      _ -> :no_match
    end
  end

end
