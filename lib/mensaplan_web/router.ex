defmodule MensaplanWeb.Router do
  use MensaplanWeb, :router

  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router
  import MensaplanWeb.AccessControl
  import MensaplanWeb.AuthController, only: [fetch_user_from_cookie: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MensaplanWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_user_from_cookie
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :require_api_token
  end

  scope "/", MensaplanWeb do
    pipe_through :browser

    live "/", PositionLive
    get "/about", PageController, :about
  end

  scope "/", MensaplanWeb do
    pipe_through [:browser, :require_login]

    live "/groups/new/", PositionLive, :group_new
    live "/groups/:id", PositionLive, :group_edit
    live "/groups/:id/invite/", PositionLive, :group_invite
    get "/settings", PageController, :settings
    post "/settings", PageController, :update_settings
    get "/join/:invite", PageController, :join
    post "/join/", PageController, :join_confirm
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
  scope "/api", MensaplanWeb do
    pipe_through :api

    post "/users/auth/:auth_id", UserController, :get_or_create
    post "/groups/server/:server_id", GroupController, :get_or_create
    put "/groups/:id", GroupController, :update
    delete "/groups/:id", GroupController, :delete
    post "/groups/join", GroupController, :join_group
    post "/positions/", PositionController, :create_for_user
    delete "/positions/user/:auth_id", PositionController, :expire_for_user
    get "/positions/server/:server_id", PositionController, :positions_for_server
  end

  scope "/admin" do
    pipe_through [:browser, :require_login, :admin_only]

    live_dashboard "/dashboard", metrics: MensaplanWeb.Telemetry
    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end
end
