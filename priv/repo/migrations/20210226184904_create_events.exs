defmodule EventApp.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :date, :naive_datetime, null: false
      add :description, :text, null: false
      add :user_id, references(:users)

      timestamps()
    end

  end
end
