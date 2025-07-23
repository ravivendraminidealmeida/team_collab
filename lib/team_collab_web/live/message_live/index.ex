defmodule TeamCollabWeb.MessageLive.Index do
  use TeamCollabWeb, :live_view

  alias TeamCollab.Messaging

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Messages
        <:actions>
          <.button variant="primary" navigate={~p"/messages/new"}>
            <.icon name="hero-plus" /> New Message
          </.button>
        </:actions>
      </.header>

      <.table
        id="messages"
        rows={@streams.messages}
        row_click={fn {_id, message} -> JS.navigate(~p"/messages/#{message}") end}
      >
        <:col :let={{_id, message}} label="Content">{message.content}</:col>
        <:action :let={{_id, message}}>
          <div class="sr-only">
            <.link navigate={~p"/messages/#{message}"}>Show</.link>
          </div>
          <.link navigate={~p"/messages/#{message}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, message}}>
          <.link
            phx-click={JS.push("delete", value: %{id: message.id}) |> hide("##{id}")}
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
      Messaging.subscribe_messages(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Messages")
     |> stream(:messages, Messaging.list_messages(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message = Messaging.get_message!(socket.assigns.current_scope, id)
    {:ok, _} = Messaging.delete_message(socket.assigns.current_scope, message)

    {:noreply, stream_delete(socket, :messages, message)}
  end

  @impl true
  def handle_info({type, %TeamCollab.Messaging.Message{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :messages, Messaging.list_messages(socket.assigns.current_scope), reset: true)}
  end


end
