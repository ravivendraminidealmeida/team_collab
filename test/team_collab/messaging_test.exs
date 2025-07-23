defmodule TeamCollab.MessagingTest do
  use TeamCollab.DataCase

  alias TeamCollab.Messaging

  describe "messages" do
    alias TeamCollab.Messaging.Message

    import TeamCollab.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeamCollab.MessagingFixtures

    @invalid_attrs %{content: nil}

    test "list_messages/1 returns all scoped messages" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      message = message_fixture(scope)
      other_message = message_fixture(other_scope)
      assert Messaging.list_messages(scope) == [message]
      assert Messaging.list_messages(other_scope) == [other_message]
    end

    test "get_message!/2 returns the message with given id" do
      scope = user_scope_fixture()
      message = message_fixture(scope)
      other_scope = user_scope_fixture()
      assert Messaging.get_message!(scope, message.id) == message
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(other_scope, message.id) end
    end

    test "create_message/2 with valid data creates a message" do
      valid_attrs = %{content: "some content"}
      scope = user_scope_fixture()

      assert {:ok, %Message{} = message} = Messaging.create_message(scope, valid_attrs)
      assert message.content == "some content"
      assert message.user_id == scope.user.id
    end

    test "create_message/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.create_message(scope, @invalid_attrs)
    end

    test "update_message/3 with valid data updates the message" do
      scope = user_scope_fixture()
      message = message_fixture(scope)
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Message{} = message} = Messaging.update_message(scope, message, update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      message = message_fixture(scope)

      assert_raise MatchError, fn ->
        Messaging.update_message(other_scope, message, %{})
      end
    end

    test "update_message/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      message = message_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Messaging.update_message(scope, message, @invalid_attrs)
      assert message == Messaging.get_message!(scope, message.id)
    end

    test "delete_message/2 deletes the message" do
      scope = user_scope_fixture()
      message = message_fixture(scope)
      assert {:ok, %Message{}} = Messaging.delete_message(scope, message)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(scope, message.id) end
    end

    test "delete_message/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      message = message_fixture(scope)
      assert_raise MatchError, fn -> Messaging.delete_message(other_scope, message) end
    end

    test "change_message/2 returns a message changeset" do
      scope = user_scope_fixture()
      message = message_fixture(scope)
      assert %Ecto.Changeset{} = Messaging.change_message(scope, message)
    end
  end
end
