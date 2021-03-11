defmodule EventAppWeb.InviteController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventApp.Invites

  alias EventAppWeb.Helpers
  alias EventAppWeb.Plugs
  plug Plugs.RequireUser
  plug :fetch_event when action in [
    :create, :delete, :update]
  plug Plugs.RequireOwner when action in [:create, :delete]
  plug :require_invitee when action in [:update]

  def fetch_event(conn, _args) do
    event = conn.params["event_id"]
    |> Events.get_event!()
    assign(conn, :event, event)
  end

  def require_invitee(conn, _args) do
    if Helpers.is_user_invited?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "User does not have an invite to this event.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def create(conn, %{"invite" => invite_params}) do
    event = conn.assigns[:event]
    invite_params = invite_params
    |> Map.put("event_id", event.id)

    case Invites.create_invite(invite_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Invite created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        invites = Invites.list_invites(event.id)
        conn
        |> put_view(EventAppWeb.EventView)
        |> render(:show, event: event, invites: invites, invite_changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    render(conn, "show.html", invite: invite)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    invite = Invites.get_invite!(id)
    event = conn.assigns[:event]

    case Invites.update_invite(invite, invite_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        invites = Invites.list_invites(event.id)
        conn
        |> put_view(EventAppWeb.EventView)
        |> render(:show, event: event, invites: invites, invite_changeset: changeset)
    end
  end

  def update(conn, %{"id" => id}) do
    update(conn, %{"id" => id, "invite" => %{"response" => nil}})
  end

  def delete(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    event = conn.assigns[:event]
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event))
  end
end
