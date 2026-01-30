defmodule Thevis.Automation.AutomationResult do
  @moduledoc """
  AutomationResult schema representing results of automation actions.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Thevis.Accounts.User
  alias Thevis.Automation.Campaign

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "automation_results" do
    field :action_type, Ecto.Enum,
      values: [:content_created, :content_published, :authority_built, :consistency_fixed]

    field :action_details, :map, default: %{}
    field :status, Ecto.Enum, values: [:pending, :approved, :executed, :failed]
    field :approved_at, :utc_datetime_usec
    field :executed_at, :utc_datetime_usec
    field :performance_metrics, :map, default: %{}

    belongs_to :campaign, Campaign
    belongs_to :approved_by, User

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: binary(),
          action_type:
            :content_created | :content_published | :authority_built | :consistency_fixed,
          action_details: map(),
          status: :pending | :approved | :executed | :failed,
          approved_at: DateTime.t() | nil,
          executed_at: DateTime.t() | nil,
          performance_metrics: map(),
          campaign_id: binary(),
          campaign: Campaign.t() | Ecto.Association.NotLoaded.t(),
          approved_by_id: binary() | nil,
          approved_by: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(automation_result, attrs) do
    automation_result
    |> cast(attrs, [
      :action_type,
      :action_details,
      :status,
      :approved_at,
      :executed_at,
      :performance_metrics,
      :campaign_id,
      :approved_by_id
    ])
    |> validate_required([:action_type, :status, :campaign_id])
    |> foreign_key_constraint(:campaign_id)
    |> foreign_key_constraint(:approved_by_id)
  end
end
