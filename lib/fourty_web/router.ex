defmodule FourtyWeb.Router do
  use FourtyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FourtyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FourtyWeb do
    pipe_through :browser

    live "/", PageLive, :index
    resources "/clients", ClientController
    resources "/projects", ProjectController, except: [:new]
    get "/projects/client/:client_id/new", ProjectController, :new
    get "/projects/client/:client_id", ProjectController, :index_client
    resources "/orders", OrderController, except: [:new]
    get "/orders/project/:project_id/new", OrderController, :new
    get "/orders/project/:project_id", OrderController, :index_project
    get "/orders/client/:client_id", OrderController, :index_client
    get "/orders/account/:account_id", OrderController, :index_account
    resources "/accounts", AccountController, except: [:new]
    get "/accounts/project/:project_id/new", AccountController, :new
    get "/accounts/project/:project_id", AccountController, :index_project
    get "/accounts/client/:client_id", AccountController, :index_client
    resources "/dpsts", DepositController, except: [:new, :index]
    get "/dpsts/order/:order_id/new", DepositController, :new
    get "/dpsts/account/:account_id", DepositController, :index_account
    get "/dpsts/order/:order_id", DepositController, :index_order
    resources "/wdrws", WithdrwlController, except: [:new, :index]
  # get "/wdrws/task/:task_id/new", WithdrwlController, :new
    get "/wdrws/account/:account_id", WithdrwlController, :index_account
  # get "/wdrws/task/task_id", WithdrwlController, :index_task
  end

  # Other scopes may use custom stacks.
  # scope "/api", FourtyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FourtyWeb.Telemetry
    end
  end
end
