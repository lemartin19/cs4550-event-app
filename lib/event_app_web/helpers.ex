defmodule EventAppWeb.Helpers do
  alias EventApp.Invites
  alias EventApp.Invites.Invite
  alias EventApp.Users.User

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

  def current_user_is_owner?(conn) do
    event = conn.assigns[:event]
    current_user_is_owner?(conn, event)
  end

  def current_user_is_owner?(conn, event) do
    current_user_is?(conn, event.user_id)
  end

  def is_user_invited?(conn) do
    event = conn.assigns[:event]
    is_user_invited?(conn, event)
  end

  def is_user_invited?(conn, event) do
    event.id
    |> Invites.list_invites()
    |> Enum.any?(fn invite ->
      current_user_is?(conn, invite.user)
    end)
  end

  def is_user_invited_or_owns?(conn) do
    event = conn.assigns[:event]
    is_user_invited_or_owns?(conn, event)
  end

  def is_user_invited_or_owns?(conn, event) do
    is_user_invited?(conn, event) || current_user_is_owner?(conn, event)
  end
end
