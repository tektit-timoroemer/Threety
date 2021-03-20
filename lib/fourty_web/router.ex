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

  pipeline :admin_only do
    plug Fourty.Users.AdminOnly
  end

  pipeline :auth_opt do
    plug Fourty.Users.Pipeline
  end

  pipeline :auth_req do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FourtyWeb do
    pipe_through [:browser]
    get "/", SessionController, :index
  end

  scope "/auth", FourtyWeb do
    pipe_through [:browser, :auth_opt]

    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :callback
    post "/:provider/callback", SessionController, :callback
    delete "/logout", SessionController, :logout
  end

  scope "/", FourtyWeb, assigns: %{adm_only: true} do
    pipe_through [:browser, :auth_opt, :auth_req, :admin_only]

    resources "/users", UserController
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
    get "/wdrws/wrktm/:wrktm_id/new", WithdrwlController, :new
    get "/wdrws/account/:account_id", WithdrwlController, :index_account
    #
    resources "/wrktms/user/:user_id", WorkItemController,
      except: [:index, :new], as: :work_item_user
    get "/wrktms/user/:user_id/new/:date_as_of", WorkItemController, :new,
      as: :work_item_user
    get "/wrktms/user/:user_id/date/:date_as_of", WorkItemController, :index_date,
      as: :work_item_user
  end

  scope "/", FourtyWeb, assigns: %{adm_only: false} do
    pipe_through [:browser, :auth_opt, :auth_req]

    get "/user/edit", UserController, :edit_pw
    patch "/user/update", UserController, :update_pw
    put "/user/update", UserController, :update_pw

    resources "/wrktms", WorkItemController, except: [:index, :new]
    get "/wrktms/new/:date_as_of", WorkItemController, :new
    get "/wrktms/account/:account_id", WorkItemController, :index_account
    get "/wrktms/date/:date_as_of", WorkItemController, :index_date
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
