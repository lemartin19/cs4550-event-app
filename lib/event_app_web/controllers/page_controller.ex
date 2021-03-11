defmodule EventAppWeb.PageController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventAppWeb.Helpers

  def index(conn, _params) do
    events = Events.list_events()
    |> Enum.filter(fn event -> 
      Helpers.is_user_invited_or_owns?(conn, event)
    end)
    render(conn, "index.html", events: events)
  end
end
