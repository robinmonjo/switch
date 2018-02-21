defmodule Switch.Urls do
  import Ecto
  import Ecto.Query

  alias Switch.Domains.Cache
  alias Switch.Repo

  def lookup_destination(source) do
    case Cache.lookup(source) do
      :not_found ->
        lookup_destination_in_repo(source)
      destination ->
        {:ok, destination}
    end
  end

  defp lookup_destination_in_repo(source) do
    query = from u in "urls",
            where: u.source == ^source,
            select: u.destination

    case Repo.all(query) do
      [destination | _] ->
        Cache.add(source, destination)
        {:ok, destination}
      _ ->
        :no_match
    end
  end
end
