defmodule FourtyWeb.ProjectController do
  use FourtyWeb, :controller

  alias Fourty.Clients

  def index(conn, _params) do
    projects = Clients.list_projects()
    heading = Gettext.dgettext(FourtyWeb.Gettext, "projects", "index")
    render(conn, "index.html", projects: projects, heading: heading)
  end

  def index_client(conn, %{"client_id" => client_id}) do
    projects = Clients.list_projects(client_id)
    heading = Gettext.dgettext(FourtyWeb.Gettext, "projects", "index_client",
      name: List.first(projects).name)
    render(conn, "index.html", projects: projects, heading: heading)
  end

  def new(conn, %{"client_id" => client_id}) do
    client = Clients.get_client!(client_id)
    project = Ecto.build_assoc(client, :projects)
    changeset = Clients.change_project(project)
    render(conn, "new.html", changeset: changeset, client: client)
  end

  def create(conn, %{"project" => project_params}) do
    case Clients.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        client_id = Ecto.Changeset.get_field(changeset, :client_id)
        client = Clients.get_client!(client_id)
        render(conn, "new.html", changeset: changeset, client: client)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    |> Fourty.Repo.preload(:client)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    |> Fourty.Repo.preload(:client)
    changeset = Clients.change_project(project)
    render(conn, "edit.html", changeset: changeset, client: project.client)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Clients.get_project!(id)
    case Clients.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        client_id = Ecto.Changeset.get_field(changeset, :client_id)
        client = Clients.get_client!(client_id)
        render(conn, "edit.html", changeset: changeset, client: client)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Clients.get_project!(id)
    {:ok, _project} = Clients.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :index))
  end
end
