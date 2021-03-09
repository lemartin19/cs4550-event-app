defmodule EventAppWeb.EventController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventApp.Events.Event

  alias EventAppWeb.Plugs
  plug Plugs.RequireUser
  plug Plugs.FetchEvent when action in [
    :show, :edit, :update, :delete]
  plug Plugs.RequireOwner when action in [
    :edit, :update, :delete]

  defp date_string(date) do
    am_or_pm = if date.hour < 12 do "AM" else "PM" end
    hour = if date.hour >= 12 do date.hour - 12 else date.hour end
    |> (fn hh -> if hh == 0 do 12 else hh end end).()
    minutes = String.pad_leading("#{date.minute}", 2, "0")
    "#{date.month}/#{date.day}/#{date.year} at #{hour}:#{minutes} #{am_or_pm}"
  end

  def index(conn, _params) do
    events = Events.list_events()
    |> Enum.map(fn all -> Map.update!(all, :date, &(date_string(&1))) end)
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

  def show(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    |> Map.update!(:date, &(date_string(&1)))
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
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

  def delete(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
