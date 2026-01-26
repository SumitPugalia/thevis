defmodule Thevis.Geo.PromptTemplates do
  @moduledoc """
  Prompt template management for entity probing.

  This module provides templates for different types of entity probing queries.
  """

  @doc """
  Gets a prompt template by type.

  ## Types
  - `:product_probe` - Probe for product recognition
  - `:service_probe` - Probe for service/company recognition
  - `:general_probe` - General entity recognition

  ## Examples

      iex> get_template(:product_probe)
      "What is {name}? Describe this product..."

  """
  def get_template(:product_probe) do
    """
    What is {name}? Describe this product in detail.
    Include information about what it does, who it's for, and its key features.
    If you don't know about this product, please say so explicitly.
    """
  end

  def get_template(:service_probe) do
    """
    What is {name}? Describe this company or service in detail.
    Include information about what services they provide, their industry, and their key offerings.
    If you don't know about this company, please say so explicitly.
    """
  end

  def get_template(:general_probe) do
    """
    Tell me about {name}. What do you know about this entity?
    Provide a detailed description if you have information, or explicitly state if you don't know about it.
    """
  end

  def get_template(_type) do
    get_template(:general_probe)
  end

  @doc """
  Renders a template with the given variables.

  ## Examples

      iex> render_template(:product_probe, name: "Glow Serum")
      "What is Glow Serum? Describe this product..."

  """
  def render_template(template_type, vars) do
    template = get_template(template_type)

    Enum.reduce(vars, template, fn {key, value}, acc ->
      String.replace(acc, "{#{key}}", to_string(value))
    end)
  end

  @doc """
  Lists all available template types.

  ## Examples

      iex> list_templates()
      [:product_probe, :service_probe, :general_probe]

  """
  def list_templates do
    [:product_probe, :service_probe, :general_probe]
  end
end
