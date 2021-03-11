defmodule EventAppWeb.EventController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventApp.Invites
  alias EventApp.Events.Event

  alias EventAppWeb.Helpers
  alias EventAppWeb.Plugs
  plug Plugs.RequireUser
  plug Plugs.FetchEvent when action in [
    :show, :edit, :update, :delete]
  plug Plugs.RequireOwner when action in [
    :edit, :update, :delete]
  plug :require_invitee_or_owner when action in [:show]

  def require_invitee_or_owner(conn, _args) do
    if Helpers.is_user_invited_or_owns?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "User does not have an invite to this event.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def require_owner(conn, _args) do
    if Helpers.current_user_is_owner?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You do not own this.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  defp date_string(date) do
    am_or_pm = if date.hour < 12 do "AM" else "PM" end
    hour = if date.hour >= 12 do date.hour - 12 else date.hour end
    |> (fn hh -> if hh == 0 do 12 else hh end end).()
    minutes = String.pad_leading("#{date.minute}", 2, "0")
    "#{date.month}/#{date.day}/#{date.year} at #{hour}:#{minutes} #{am_or_pm}"
  end

  def index(conn, _params) do
    events = Events.list_events()
    |> Enum.map(fn event -> Map.update!(event, :date, &(date_string(&1))) end)
    |> Enum.filter(&(Helpers.is_user_invited_or_owns?(conn, &1)))
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    id = conn.assigns[:current_user].id 

    event_params = event_params
    |> Map.put("user_id", id)
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    event = conn.assigns[:event]
    |> Map.update!(:date, &(date_string(&1)))
    invites = Invites.list_invites(event.id)
    render(conn, "show.html", event: event, invites: invites)
  end

  def edit(conn, _params) do
    event = conn.assigns[:event]
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"event" => event_params}) do
    event = conn.assigns[:event]

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    event = conn.assigns[:event]
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
