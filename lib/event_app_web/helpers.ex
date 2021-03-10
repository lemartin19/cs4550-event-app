defmodule EventAppWeb.Helpers do
  alias EventApp.Users.User
  alias EventApp.Invites.Invite
  alias EventApp.Invites

  def current_user_id(conn) do
    user = conn.assigns[:current_user]
    user && user.id
  end

  def have_current_user?(conn) do
    conn.assigns[:current_user] != nil
  end

  def current_user_is?(conn, %User{} = user) do
    current_user_is?(conn, user.id)
  end

  def current_user_is?(conn, user_id) do
    current_user_id(conn) == user_id
  end

  def current_user_invitation(conn, invites) do
    invites
    |> Enum.find(nil, &current_user_is?(conn, &1.user))
  end

  def invite_changeset_or_default(assigns) do
    Map.update(
      assigns,
      :invite_changeset,
      Invites.change_invite(%Invite{}), &(&1)
    )
  end
end
