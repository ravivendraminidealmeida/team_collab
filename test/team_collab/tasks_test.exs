defmodule TeamCollab.TasksTest do
  use TeamCollab.DataCase

  alias TeamCollab.Tasks

  describe "tasks" do
    alias TeamCollab.Tasks.Task

    import TeamCollab.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeamCollab.TasksFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, due_to: nil}

    test "list_tasks/1 returns all scoped tasks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      other_task = task_fixture(other_scope)
      assert Tasks.list_tasks(scope) == [task]
      assert Tasks.list_tasks(other_scope) == [other_task]
    end

    test "get_task!/2 returns the task with given id" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tasks.get_task!(scope, task.id) == task
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(other_scope, task.id) end
    end

    test "create_task/2 with valid data creates a task" do
      valid_attrs = %{status: :on_time, description: "some description", title: "some title", due_to: ~D[2025-07-22]}
      scope = user_scope_fixture()

      assert {:ok, %Task{} = task} = Tasks.create_task(scope, valid_attrs)
      assert task.status == :on_time
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.due_to == ~D[2025-07-22]
      assert task.user_id == scope.user.id
    end

    test "create_task/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(scope, @invalid_attrs)
    end

    test "update_task/3 with valid data updates the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      update_attrs = %{status: :delayed, description: "some updated description", title: "some updated title", due_to: ~D[2025-07-23]}

      assert {:ok, %Task{} = task} = Tasks.update_task(scope, task, update_attrs)
      assert task.status == :delayed
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.due_to == ~D[2025-07-23]
    end

    test "update_task/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)

      assert_raise MatchError, fn ->
        Tasks.update_task(other_scope, task, %{})
      end
    end

    test "update_task/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(scope, task, @invalid_attrs)
      assert task == Tasks.get_task!(scope, task.id)
    end

    test "delete_task/2 deletes the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert {:ok, %Task{}} = Tasks.delete_task(scope, task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(scope, task.id) end
    end

    test "delete_task/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      assert_raise MatchError, fn -> Tasks.delete_task(other_scope, task) end
    end

    test "change_task/2 returns a task changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert %Ecto.Changeset{} = Tasks.change_task(scope, task)
    end
  end
end
