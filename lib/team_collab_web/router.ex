defmodule TeamCollabWeb.Router do
  use TeamCollabWeb, :router

  import TeamCollabWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TeamCollabWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TeamCollabWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", TeamCollabWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:team_collab, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TeamCollabWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  scope "/", TeamCollabWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TeamCollabWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      # Messages
      live "/messages", MessageLive.Index, :index
      live "/messages/new", MessageLive.Form, :new
      live "/messages/:id", MessageLive.Show, :show
      live "/messages/:id/edit", MessageLive.Form, :edit

      # Tasks
      live "/tasks", TaskLive.Index, :index
      live "/tasks/new", TaskLive.Form, :new
      live "/tasks/:id", TaskLive.Show, :show
      live "/tasks/:id/edit", TaskLive.Form, :edit

    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", TeamCollabWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{TeamCollabWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
