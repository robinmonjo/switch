defmodule Switch.DomainChannel do
  use Switch.Web, :channel

  def join("domains:" <> domain_id, _params, socket) do
    :timer.send_interval(5_000, :ping)
    {:ok, assign(socket, :domain_id, domain_id)}
  end

  def handle_in("check_domain", domain_id, socket) do
    broadcast! socket, "check_domain", %{id: domain_id}
    {:reply, :ok, socket}
  end
end
