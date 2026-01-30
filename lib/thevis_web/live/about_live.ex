defmodule ThevisWeb.AboutLive do
  @moduledoc """
  Public About page: entity block and platform overview for GEO.
  """
  use ThevisWeb, :live_view

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @meta_description "thevis is an AI visibility platform that helps brands optimize content for generative AI search (GEO). Learn about our mission and how we help brands get cited by AI."

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "About thevis · AI Visibility Platform")
      |> assign(:meta_description, @meta_description)
      |> assign(:canonical_path, "/about")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} page_title={@page_title}>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div class="w-full px-4 sm:px-6 lg:px-8 py-16 max-w-4xl mx-auto">
          <h1 class="text-4xl font-bold text-gray-900 mb-8">About thevis</h1>

          <section class="prose prose-lg max-w-none mb-12">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Who we are</h2>
            <p class="text-gray-700 mb-4">
              <strong>thevis</strong>
              (product: thevis.ai) is an <strong>AI Visibility Platform</strong>.
            </p>
            <p class="text-gray-700 mb-4">
              thevis helps brands optimize content for generative AI search engines using GEO (Generative Engine Optimization).
            </p>
            <p class="text-gray-700 mb-4">
              Brands are invisible in AI-generated answers; AI systems don’t consistently understand, describe, or recommend them. We fix that through measurement, optimization, and automation.
            </p>
            <p class="text-gray-600">
              <strong>Key concepts we work with:</strong>
              GEO, AI visibility, generative search, LLM retrieval, GEO Score, AI visibility audit.
            </p>
          </section>

          <section class="prose prose-lg max-w-none mb-12">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">What we do</h2>
            <ul class="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                <strong>GEO Score measurement</strong>
                — Track how well AI systems recognize and describe your brand.
              </li>
              <li>
                <strong>Recall and authority</strong>
                — See whether AI cites you when users ask relevant questions.
              </li>
              <li>
                <strong>Automated optimization</strong>
                — Wikis, content, citations, and consistency across platforms.
              </li>
              <li>
                <strong>Product and launch support</strong>
                — Establish AI visibility during launches and ongoing.
              </li>
            </ul>
          </section>

          <section class="mb-12">
            <.link
              navigate={~p"/"}
              class="text-blue-600 hover:text-blue-800 font-medium"
            >
              ← Back to home
            </.link>
          </section>
        </div>

        <Layouts.public_footer />
      </div>
    </Layouts.app>
    """
  end
end
