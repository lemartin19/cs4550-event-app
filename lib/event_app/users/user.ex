defmodule EventApp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :avatar_hash, :string
    has_many :events, EventApp.Events.Event
    has_many :comments, EventApp.Events.Event

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :avatar_hash])
    |> validate_required([:name, :email, :avatar_hash])
    |> unique_constraint(:email)
  end
end
