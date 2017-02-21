defmodule Switch.HostSwitch do
  import Plug.Conn

  alias Switch.Repo
  import Ecto.Query

  @hostname Application.fetch_env!(:switch, Switch)[:hostname]

  # the plug that performs the domain switch
  def init(opts), do: opts

  # if host is app host, the user wants to access the app
  def call(%{host: @hostname} = conn, _opts), do: conn

  # else this request should be redirected
  def call(%{host: host, scheme: scheme, request_path: request_path, query_string: query_string} = conn, _opts) do
    query = from d in "domains",
            where: d.name == ^"#{scheme}://#{host}",
            select: d.redirect

    case Repo.all(query) do
      [redirect | _] ->
        query = if query_string == "", do: "", else: "?#{query_string}"
        conn
        |> put_resp_header("location", "#{redirect}#{request_path}#{query}")
        |> resp(302, "You are being redirected.")
        |> halt
      _ ->
        conn
        |> send_resp(404, "#{host} has no match")
        |> halt
    end
  end

end
