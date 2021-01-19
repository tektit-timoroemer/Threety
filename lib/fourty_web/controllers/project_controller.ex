defmodule FourtyWeb.ProjectController do
  use FourtyWeb, :controller

  alias Fourty.Clients

  def index(conn, %{"client_id" => client_id}) do
    projects = Clients.list_projects_for_client(client_id)
    render(conn, "index.html", projects: projects)
  end

  def index_all(conn, _params) do
    projects = Clients.list_all_projects()
    render(conn, "index.html", projects: projects)
  end

  def new(conn, %{"client_id" => client_id}) do
    project = Clients.prepare_new_project(client_id)
    changeset = Clients.change_project(project)
    render(conn, "new.html", changeset: changeset, project: project)
  end

  def create(conn, %{ "client_id" => client_id, "project" => project_params}) do
    project = Clients.prepare_new_project(client_id)
    case Clients.create_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.client_project_path(conn, :show, project.client, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, project: project) #project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    changeset = Clients.change_project(project)
    render(conn, "edit.html", changeset: changeset, project: project)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Clients.get_project!(id)
    case Clients.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.client_project_path(conn, :show, project.client, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, project: project)
    end
  end

  def delete(conn, %{"client_id" => client_id, "id" => id}) do
    project = Clients.get_project!(id)
    {:ok, _project} = Clients.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.client_project_path(conn, :index, client_id ))
  end
end
