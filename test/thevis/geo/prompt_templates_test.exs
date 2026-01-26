defmodule Thevis.Geo.PromptTemplatesTest do
  use ExUnit.Case, async: true

  alias Thevis.Geo.PromptTemplates

  describe "get_template/1" do
    test "returns product_probe template" do
      template = PromptTemplates.get_template(:product_probe)
      assert is_binary(template)
      assert String.contains?(template, "product")
    end

    test "returns service_probe template" do
      template = PromptTemplates.get_template(:service_probe)
      assert is_binary(template)
      assert String.contains?(template, "company")
    end

    test "returns general_probe template for unknown type" do
      template = PromptTemplates.get_template(:unknown)
      assert is_binary(template)
    end
  end

  describe "render_template/2" do
    test "renders template with variables" do
      template = PromptTemplates.render_template(:product_probe, name: "Glow Serum")
      assert String.contains?(template, "Glow Serum")
      refute String.contains?(template, "{name}")
    end

    test "renders service template with variables" do
      template = PromptTemplates.render_template(:service_probe, name: "Acme Corp")
      assert String.contains?(template, "Acme Corp")
      refute String.contains?(template, "{name}")
    end
  end

  describe "list_templates/0" do
    test "returns list of available template types" do
      templates = PromptTemplates.list_templates()
      assert :product_probe in templates
      assert :service_probe in templates
      assert :general_probe in templates
    end
  end
end
