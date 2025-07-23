defmodule TeamCollabWeb.MessageLive.Show do
  use TeamCollabWeb, :live_view

  alias TeamCollab.Messaging

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Message {@message.id}
        <:subtitle>This is a message record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/messages"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/messages/#{@message}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit message
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Content">{@message.content}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Messaging.subscribe_messages(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Message")
     |> assign(:message, Messaging.get_message!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %TeamCollab.Messaging.Message{id: id} = message},
        %{assigns: %{message: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :message, message)}
  end

  def handle_info(
        {:deleted, %TeamCollab.Messaging.Message{id: id}},
        %{assigns: %{message: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current message was deleted.")
     |> push_navigate(to: ~p"/messages")}
  end

  def handle_info({type, %TeamCollab.Messaging.Message{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
