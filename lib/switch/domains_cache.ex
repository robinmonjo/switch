defmodule Switch.DomainsCache do
  use GenServer

  def ets_table do
    :"Switch.DomainsCache.table"
  end

  # Client API

  def add(domain_url, redirect_url) do
    GenServer.cast(__MODULE__, {:add, domain_url, redirect_url})
  end

  def add_sync(domain_url, redirect_url) do
    GenServer.call(__MODULE__, {:add, domain_url, redirect_url})
  end

  def lookup(domain_url) do
    case :ets.lookup(ets_table(), domain_url) do
      [{_, redirect_url} | _] ->
        redirect_url
      _ ->
        :not_found
    end
  end

  def delete(domain_url) do
    GenServer.cast(__MODULE__, {:delete, domain_url})
  end

  def delete_sync(domain_url) do
    GenServer.call(__MODULE__, {:delete, domain_url})
  end


  # Callbacks
  def start_link() do
    GenServer.start_link(__MODULE__, ets_table(), name: __MODULE__)
  end

  def init(cache_table) do
    table = :ets.new(cache_table, [:named_table, read_concurrency: true])
    {:ok, table}
  end

  def handle_cast({:add, domain_url, redirect_url}, table) do
    add_in_cache_table(table, {domain_url, redirect_url})
    {:noreply, table}
  end

  def handle_cast({:delete, domain_url}, table) do
    delete_in_cache_table(table, domain_url)
    {:noreply, table}
  end

  def handle_call({:add, domain_url, redirect_url}, _from, table) do
    {:reply, add_in_cache_table(table, {domain_url, redirect_url}), table}
  end

  def handle_call({:delete, domain_url}, _from, table) do
    {:reply, delete_in_cache_table(table, domain_url), table}
  end

  defp add_in_cache_table(table, entry), do: :ets.insert(table, entry)
  defp delete_in_cache_table(table, key), do: :ets.delete(table, key)

end
