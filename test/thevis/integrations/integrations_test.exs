defmodule Thevis.IntegrationsTest do
  use Thevis.DataCase

  alias Thevis.Integrations
  alias Thevis.Integrations.PlatformSetting

  describe "platform_settings" do
    import Thevis.Factory

    test "list_platform_settings/2 returns all platform settings for a project" do
      project = insert(:product_project)

      {:ok, _setting1} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      {:ok, _setting2} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "medium",
          settings: %{}
        })

      settings = Integrations.list_platform_settings(project.id)
      assert length(settings) == 2
    end

    test "get_platform_setting!/1 returns the platform setting with given id" do
      project = insert(:product_project)

      {:ok, setting} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      assert Integrations.get_platform_setting!(setting.id).id == setting.id
    end

    test "get_platform_setting_by_type/2 returns platform setting for project and type" do
      project = insert(:product_project)

      {:ok, setting} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      found = Integrations.get_platform_setting_by_type(project.id, "github")
      assert found.id == setting.id
    end

    test "create_platform_setting/1 with valid data creates a platform setting" do
      project = insert(:product_project)

      valid_attrs = %{
        project_id: project.id,
        platform_type: "github",
        settings: %{"repository" => "owner/repo"},
        is_active: true
      }

      assert {:ok, %PlatformSetting{} = setting} =
               Integrations.create_platform_setting(valid_attrs)

      assert setting.platform_type == "github"
      assert setting.settings["repository"] == "owner/repo"
    end

    test "create_platform_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_platform_setting(%{})
    end

    test "update_platform_setting/2 with valid data updates the platform setting" do
      project = insert(:product_project)

      {:ok, setting} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      update_attrs = %{settings: %{"repository" => "newowner/newrepo"}}

      assert {:ok, %PlatformSetting{} = updated_setting} =
               Integrations.update_platform_setting(setting, update_attrs)

      assert updated_setting.settings["repository"] == "newowner/newrepo"
    end

    test "update_platform_setting/2 with invalid data returns error changeset" do
      project = insert(:product_project)

      {:ok, setting} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      assert {:error, %Ecto.Changeset{}} =
               Integrations.update_platform_setting(setting, %{platform_type: nil})

      assert setting == Integrations.get_platform_setting!(setting.id)
    end

    test "delete_platform_setting/1 deletes the platform setting" do
      project = insert(:product_project)

      {:ok, setting} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      assert {:ok, %PlatformSetting{}} = Integrations.delete_platform_setting(setting)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_platform_setting!(setting.id) end
    end

    test "get_or_create_platform_setting/3 creates setting if it doesn't exist" do
      project = insert(:product_project)

      assert {:ok, %PlatformSetting{} = setting} =
               Integrations.get_or_create_platform_setting(project.id, "github", %{
                 "repository" => "owner/repo"
               })

      assert setting.platform_type == "github"
    end

    test "get_or_create_platform_setting/3 returns existing setting if it exists" do
      project = insert(:product_project)

      {:ok, existing} =
        Integrations.create_platform_setting(%{
          project_id: project.id,
          platform_type: "github",
          settings: %{}
        })

      assert {:ok, %PlatformSetting{} = setting} =
               Integrations.get_or_create_platform_setting(project.id, "github", %{})

      assert setting.id == existing.id
    end
  end
end
