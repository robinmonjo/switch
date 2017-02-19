defmodule Switch.Repo.Migrations.UniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:domains, [:name])
  end
end
