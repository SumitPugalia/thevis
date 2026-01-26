defmodule Thevis.Geo.EntityProbeTest do
  use Thevis.DataCase
  import Mox

  alias Thevis.AI.MockAdapter
  alias Thevis.Geo.EntityProbe

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "probe_entity/2" do
    setup do
      # Configure the app to use the mock adapter
      Application.put_env(:thevis, Thevis.AI, adapter: MockAdapter)
      :ok
    end

    test "probes a product entity" do
      product = insert(:product, name: "Test Product")

      # Mock the AI adapter response
      expect(MockAdapter, :chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "Test Product is a premium skincare product designed for daily use."
               }
             }
           ],
           "model" => "gpt-4o-mini"
         }}
      end)

      assert {:ok, snapshot_data} = EntityProbe.probe_entity(product)

      assert snapshot_data.optimizable_type == :product
      assert snapshot_data.optimizable_id == product.id
      assert is_binary(snapshot_data.ai_description)
      assert is_float(snapshot_data.confidence_score)
      assert snapshot_data.confidence_score >= 0.0
      assert snapshot_data.confidence_score <= 1.0
    end

    test "probes a company entity" do
      company = insert(:company, name: "Test Company")

      expect(MockAdapter, :chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "Test Company provides professional consulting services."
               }
             }
           ],
           "model" => "gpt-4o-mini"
         }}
      end)

      assert {:ok, snapshot_data} = EntityProbe.probe_entity(company)

      assert snapshot_data.optimizable_type == :service
      assert snapshot_data.optimizable_id == company.id
      assert is_binary(snapshot_data.ai_description)
      assert is_float(snapshot_data.confidence_score)
    end
  end

  describe "probe_with_prompt/3" do
    test "probes with product_probe template" do
      product = insert(:product, name: "Glow Serum")

      expect(MockAdapter, :chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "Glow Serum is a premium skincare product."
               }
             }
           ],
           "model" => "gpt-4o-mini"
         }}
      end)

      assert {:ok, snapshot_data} = EntityProbe.probe_with_prompt(product, :product_probe)

      assert snapshot_data.optimizable_type == :product
      assert snapshot_data.prompt_template == "product_probe"
    end

    test "probes with service_probe template" do
      company = insert(:company, name: "Test Services Inc")

      expect(MockAdapter, :chat_completion, fn _messages, _opts ->
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "content" => "Test Services Inc provides professional services."
               }
             }
           ],
           "model" => "gpt-4o-mini"
         }}
      end)

      assert {:ok, snapshot_data} = EntityProbe.probe_with_prompt(company, :service_probe)

      assert snapshot_data.optimizable_type == :service
      assert snapshot_data.prompt_template == "service_probe"
    end
  end

  describe "analyze_response/2" do
    test "analyzes response for a product" do
      product = insert(:product, name: "Test Product")

      response = %{
        "choices" => [
          %{
            "message" => %{
              "content" => "Test Product is a premium skincare product designed for daily use."
            }
          }
        ],
        "model" => "gpt-4o-mini"
      }

      snapshot_data = EntityProbe.analyze_response(response, product)

      assert snapshot_data.optimizable_type == :product
      assert snapshot_data.optimizable_id == product.id

      assert snapshot_data.ai_description ==
               "Test Product is a premium skincare product designed for daily use."

      assert snapshot_data.confidence_score > 0.0
      assert snapshot_data.source_llm == "gpt-4o-mini"
    end

    test "analyzes response for a company" do
      company = insert(:company, name: "Test Company")

      response = %{
        "choices" => [
          %{
            "message" => %{
              "content" => "Test Company provides professional consulting services."
            }
          }
        ],
        "model" => "gpt-4o-mini"
      }

      snapshot_data = EntityProbe.analyze_response(response, company)

      assert snapshot_data.optimizable_type == :service
      assert snapshot_data.optimizable_id == company.id

      assert snapshot_data.ai_description ==
               "Test Company provides professional consulting services."
    end
  end
end
