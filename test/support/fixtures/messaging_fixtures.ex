defmodule TeamCollab.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeamCollab.Messaging` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content"
      })

    {:ok, message} = TeamCollab.Messaging.create_message(scope, attrs)
    message
  end
end
