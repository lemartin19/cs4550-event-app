defmodule EventApp.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :response, :string
    field :user_email, :string
    belongs_to :event, EventApp.Events.Event

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:response, :user_email])
    |> validate_required([:response, :user_email])
    |> unique_constraint(:invitee_email, name: :invitee_email)
  end
end
