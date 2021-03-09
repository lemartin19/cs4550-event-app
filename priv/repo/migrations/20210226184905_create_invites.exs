defmodule EventApp.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :response, :string
      add :event_id, references(:events, on_delete: :nothing), null: false
      add :user_email, :string, null: false

      timestamps()
    end

    create unique_index(:invites, [:event_id, :user_email], name: :invitee_email)
  end
end
