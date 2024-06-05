defmodule MensaplanWeb.Router do
  use MensaplanWeb, :router

  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router
  import MensaplanWeb.AccessControl

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
  # create or get user
  # create, delete position
  # create or get, delete group, add members
  # get pos for group
  scope "/api", MensaplanWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show]
    resources "/groups", GroupController, only: [:create, :show, :update, :delete]
    resources "/positions", PositionController, only: [:create]
    post "/positions/expire/", PositionController, :expire_for_user
    get "/positions/per_group/:group_id", PositionController, :list_positions
  end

  scope "/admin" do
    pipe_through [:browser, :require_login, :admin_only]

    live_dashboard "/dashboard", metrics: MensaplanWeb.Telemetry
    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end
end
