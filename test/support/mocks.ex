defmodule Thevis.Mocks do
  @moduledoc """
  Mox mocks for testing.
  """

  Mox.defmock(Thevis.AI.MockAdapter, for: Thevis.AI.Adapter)
end
