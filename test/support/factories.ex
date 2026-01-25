defmodule Thevis.Factory do
  @moduledoc """
  ExMachina factories for test data generation.
  """

  use ExMachina.Ecto, repo: Thevis.Repo

  alias Thevis.Accounts.{User, Company, Role}

  def user_factory do
    %User{
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence(:name, &"User #{&1}"),
      hashed_password: Bcrypt.hash_pwd_salt("password1234"),
      role: :client
    }
  end

  def consultant_user_factory do
    %User{
      email: sequence(:email, &"consultant#{&1}@example.com"),
      name: sequence(:name, &"Consultant #{&1}"),
      hashed_password: Bcrypt.hash_pwd_salt("password1234"),
      role: :consultant
    }
  end

  def company_factory do
    %Company{
      name: sequence(:name, &"Company #{&1}"),
      domain: sequence(:domain, &"company#{&1}.com"),
      industry: "Technology",
      description: "A test company",
      website_url: sequence(:url, &"https://company#{&1}.com"),
      company_type: :product_based
    }
  end

  def service_based_company_factory do
    %Company{
      name: sequence(:name, &"Service Company #{&1}"),
      domain: sequence(:domain, &"service#{&1}.com"),
      industry: "Services",
      description: "A service-based company",
      website_url: sequence(:url, &"https://service#{&1}.com"),
      company_type: :service_based
    }
  end

  def role_factory do
    %Role{
      user: build(:user),
      company: build(:company),
      role_type: :client
    }
  end

  def consultant_role_factory do
    %Role{
      user: build(:consultant_user),
      company: build(:company),
      role_type: :consultant
    }
  end
end
