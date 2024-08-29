defmodule Ticket_BEWeb.Router do
  use Ticket_BEWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Ticket_BEWeb.GuardianPipeline
  end

  scope "/api", Ticket_BEWeb do
    pipe_through :api

    scope "/public" do
      get "/", LandingPage, :index
      get "/flight/airports", Flight, :get_airport
      get "/flight/class", Flight, :get_flight_class
      post "/flight/tickets", Flight, :get_ticket
      post "/auth/signup", Authentication, :sign_up
      post "/auth/signin", Authentication, :sign_in
    end

    scope "/private" do
      pipe_through [:auth]
      get "/users/profile", UserProfile, :get_profile
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:ticket_BE, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: Ticket_BEWeb.Telemetry
    end
  end

end
