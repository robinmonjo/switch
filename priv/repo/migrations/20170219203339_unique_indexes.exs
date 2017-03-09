defmodule Switch.Repo.Migrations.DomainNameUniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:domains, [:name])
  end
end
