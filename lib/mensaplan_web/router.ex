defmodule MensaplanWeb.Router do
  use MensaplanWeb, :router
  import Phoenix.LiveView.Router
  import MensaplanWeb.ApiToken

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MensaplanWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :require_api_token
  end

  pipeline :admin do
  end

  scope "/", MensaplanWeb do
    pipe_through :browser

    live "/", PositionLive
    get "/settings", PageController, :settings
    post "/settings", PageController, :update_settings
    get "/about", PageController, :about
    live "/groups/new/", PositionLive, :group_new
    live "/groups/:id", PositionLive, :group_edit
    live "/groups/:id/invite/", PositionLive, :group_invite
    get "/groups/join/:invite", PageController, :join
    post "/groups/join/", PageController, :join_confirm
  end

  scope "/auth", MensaplanWeb do
    pipe_through :browser

    get "/logout", AuthController, :delete
    delete "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  # Discord Bot API
  # create user
  # create position
  # delete pos
  # create group
  # get pos for group
  scope "/api", MensaplanWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]
    resources "/groups", GroupController, only: [:create, :update]
    resources "/positions", PositionController, only: [:create]
    post "/positions/expire/", PositionController, :expire_for_user
    get "/positions/per_group/:group_id", PositionController, :list_positions
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mensaplan, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:browser, :admin]

      live_dashboard "/dashboard", metrics: MensaplanWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
