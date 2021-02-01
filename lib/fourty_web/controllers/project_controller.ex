defmodule FourtyWeb.ProjectController do
  use FourtyWeb, :controller

  alias Fourty.Clients
  alias Fourty.Clients.Project

  def index(conn, _params) do
    projects = Clients.list_projects()
    render(conn, "index.html", projects: projects)
  end

  def index_client(conn, %{"client_id" => client_id}) do
    projects = Clients.list_projects(client_id)
    render(conn, "index.html", projects: projects)
  end

  def new(conn, params) do
    clients = Clients.get_clients()
    project = %Project{}
    changeset = Clients.change_project(project, params)
    render(conn, "new.html", changeset: changeset, project: project, clients: clients)
  end

  def create(conn, %{ "project" => project_params}) do
    case Clients.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        clients = Clients.get_clients()
        render(conn, "new.html", changeset: changeset, clients: clients)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    clients = Clients.get_clients()
    changeset = Clients.change_project(project)
    render(conn, "edit.html", changeset: changeset, project: project, clients: clients)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Clients.get_project!(id)
    case Clients.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        clients = Clients.get_clients()
        render(conn, "edit.html", changeset: changeset, clients: clients)
    end
  end

  def delete(conn, %{"client_id" => client_id, "id" => id}) do
    project = Clients.get_project!(id)
    {:ok, _project} = Clients.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :index, client_id ))
  end
end
