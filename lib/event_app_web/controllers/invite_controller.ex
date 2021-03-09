defmodule EventAppWeb.InviteController do
  use EventAppWeb, :controller

  alias EventApp.Invites
  alias EventApp.Invites.Invite
  import EventAppWeb.EventView

  alias EventAppWeb.Plugs
  plug Plugs.RequireUser
  plug Plugs.FetchEvent when action in [:create]
  plug Plugs.RequireOwner when action in [:create, :delete]
  plug :require_invitee when action in [:update, :edit]

  def require_invitee(conn, _args) do
    current_user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    if current_user.id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You do not own this.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def create(conn, %{"invite" => invite_params}) do
    event = conn.assigns[:event]
    invite_params = invite_params
    |> Map.put("event_id", event.id)

    case Invites.create_invite(invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite created successfully.")
        |> redirect(to: Routes.invite_path(conn, :show, invite))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(EventAppWeb.EventView)
        |> render(:show, event: event, invite_changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    render(conn, "show.html", invite: invite)
  end

  def edit(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    changeset = Invites.change_invite(invite)
    render(conn, "response.html", invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    invite = Invites.get_invite!(id)

    case Invites.update_invite(invite, invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> redirect(to: Routes.invite_path(conn, :show, invite))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invite: invite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: Routes.invite_path(conn, :index))
  end
end
