defmodule TeamCollabWeb.TaskLive.Index do
  use TeamCollabWeb, :live_view

  alias TeamCollab.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Tasks
        <:actions>
          <.button variant="primary" navigate={~p"/tasks/new"}>
            <.icon name="hero-plus" /> New Task
          </.button>
        </:actions>
      </.header>

      <.table
        id="tasks"
        rows={@streams.tasks}
        row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}
      >
        <:col :let={{_id, task}} label="Title">{task.title}</:col>
        <:col :let={{_id, task}} label="Description">{task.description}</:col>
        <:col :let={{_id, task}} label="Due to">{task.due_to}</:col>
        <:col :let={{_id, task}} label="Status">{task.status}</:col>
        <:action :let={{_id, task}}>
          <div class="sr-only">
            <.link navigate={~p"/tasks/#{task}"}>Show</.link>
          </div>
          <.link navigate={~p"/tasks/#{task}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, task}}>
          <.link
            phx-click={JS.push("delete", value: %{id: task.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Tasks.subscribe_tasks(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Tasks")
     |> stream(:tasks, Tasks.list_tasks(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(socket.assigns.current_scope, id)
    {:ok, _} = Tasks.delete_task(socket.assigns.current_scope, task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_info({type, %TeamCollab.Tasks.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :tasks, Tasks.list_tasks(socket.assigns.current_scope), reset: true)}
  end
end
