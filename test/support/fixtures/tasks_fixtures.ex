defmodule TeamCollab.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeamCollab.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        due_to: ~D[2025-07-22],
        status: :on_time,
        title: "some title"
      })

    {:ok, task} = TeamCollab.Tasks.create_task(scope, attrs)
    task
  end
end
