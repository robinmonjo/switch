defmodule Switch.Web.UrlSwitch do
  import Plug.Conn

  alias Switch.Urls

  @hostname Application.fetch_env!(:switch, Switch)[:hostname]

  # the plug that performs the domain switch
  def init(opts), do: opts

  # if host is app host, the user wants to access the app
  def call(%{host: @hostname} = conn, _opts), do: conn

  # else this request should be redirected
  def call(%{host: host, scheme: scheme, request_path: request_path, query_string: query_string} = conn, _opts) do
    url = "#{scheme}://#{host}#{request_path}"
    case Urls.lookup_destination(url) do
      {:ok, destination} ->
        query = if query_string == "", do: "", else: "?#{query_string}"
        conn
        |> put_resp_header("location", "#{destination}#{query}")
        |> resp(302, "You are being redirected.")
        |> halt
      :no_match ->
        conn
    end
  end
end
