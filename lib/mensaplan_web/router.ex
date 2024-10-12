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

  pipeline :translate do
    plug(SetLocale, gettext: MensaplanWeb.Gettext, default_locale: "en", cookie_key: "locale")
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :require_api_token
  end

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

  scope "/auth", MensaplanWeb do
    pipe_through :browser

    get "/logout", AuthController, :delete
    delete "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/admin" do
    pipe_through [:browser, :require_login, :admin_only]

    resources "/dishes", MensaplanWeb.Admin.DishController
    resources "/groups", MensaplanWeb.Admin.GroupController
    resources "/users", MensaplanWeb.Admin.UserController
    live_dashboard "/dashboard", metrics: MensaplanWeb.Telemetry

    if Application.compile_env!(:mensaplan, :environment) == :dev,
      do: forward("/mailbox", Plug.Swoosh.MailboxPreview)
  end

  scope "/:locale", MensaplanWeb do
    pipe_through [:browser, :translate]

    live "/", PositionLive
    live "/dishes/", DishLive
    get "/dishes/:id", DishController, :show
    get "/about", PageController, :about
  end

  scope "/:locale", MensaplanWeb do
    pipe_through [:browser, :translate, :require_login]

    live "/groups/new/", PositionLive, :group_new
    live "/groups/:id", PositionLive, :group_edit
    live "/groups/:id/invite/", PositionLive, :group_invite
    get "/settings", PageController, :settings
    post "/settings", PageController, :update_settings
    get "/join/:invite", PageController, :join
    post "/join/", PageController, :join_confirm
  end

  scope "/", MensaplanWeb do
    pipe_through [:browser, :translate]

    # this is not called, but still required
    get "/", PageController, :dummy
  end
end
