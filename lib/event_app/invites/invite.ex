defmodule EventApp.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :user_email, :string, null: false
    field :response, :string
    belongs_to :event, EventApp.Events.Event

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:response, :user_email, :event_id])
    |> validate_required([:user_email])
    |> unique_constraint(:invitee_email, name: :invitee_email)
  end
end
