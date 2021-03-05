defmodule EventAppWeb.EventController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventApp.Events.Event

  defp date_string(%{date: date}) do
    am_or_pm = if date.hour < 12 do "AM" else "PM" end
    hour = if date.hour >= 12 do date.hour - 12 else date.hour end
    |> (fn hh -> if hh == 0 do 12 else hh end end).()
    minutes = String.pad_leading("#{date.minute}", 2, "0")
    "#{date.month}/#{date.day}/#{date.year} at #{hour}:#{minutes} #{am_or_pm}"
  end

  def index(conn, _params) do
    events = Events.list_events()
    |> Enum.map(fn event ->
        Map.put(event, :date_string, date_string(event))
      end)
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    id = if conn.assigns[:current_user] do
      conn.assigns[:current_user].id 
    else
      nil
    end

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
    event = Events.get_event!(id)
    |> (fn event -> Map.put(event, :date_string, date_string(event)) end).()
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

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
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
