defmodule ThevisWeb.GeoLive do
  @moduledoc """
  Public GEO explainer page: answer-first content for AI retrieval (GEO Plan Layer 2).
  """
  use ThevisWeb, :live_view

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @meta_description "What is GEO? Generative Engine Optimization is the practice of optimizing content so AI search engines cite and recommend your brand. thevis helps brands achieve GEO."

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "What is GEO? · Generative Engine Optimization")
      |> assign(:meta_description, @meta_description)
      |> assign(:canonical_path, "/geo")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} page_title={@page_title}>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div class="w-full px-4 sm:px-6 lg:px-8 py-16 max-w-4xl mx-auto">
          <h1 class="text-4xl font-bold text-gray-900 mb-8">
            What is Generative Engine Optimization (GEO)?
          </h1>

          <section class="prose prose-lg max-w-none mb-10">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">Definition of GEO</h2>
            <p class="text-gray-700 mb-4">
              GEO (Generative Engine Optimization) is the practice of optimizing content so that AI-powered search engines and assistants (e.g. ChatGPT, Perplexity, Gemini, Copilot) cite and recommend your brand.
            </p>
            <p class="text-gray-700">
              Unlike SEO, which optimizes for ranking in traditional search results, GEO optimizes for being the <strong>answer</strong>—visible, mentionable, and quotable by AI systems.
            </p>
          </section>

          <section class="prose prose-lg max-w-none mb-10">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">How GEO improves AI visibility</h2>
            <p class="text-gray-700 mb-4">
              AI systems work on <strong>entities</strong>
              and <strong>direct answers</strong>. When your brand is clearly defined, consistently described, and present in authoritative sources, models are more likely to retrieve and cite you when users ask relevant questions.
            </p>
            <ul class="list-disc pl-6 space-y-2 text-gray-700">
              <li>Clear entity signals (brand, category, one-line definition)</li>
              <li>Answer-first content (definitions, FAQs, how-tos)</li>
              <li>Citation-ready structure (authority, references, consistency)</li>
              <li>Presence where AI trains and retrieves (GitHub, Medium, directories, reviews)</li>
            </ul>
          </section>

          <section class="prose prose-lg max-w-none mb-10">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">GEO vs SEO</h2>
            <p class="text-gray-700 mb-4">
              <strong>SEO</strong>
              optimizes for clicks and link ranking. <strong>GEO</strong>
              optimizes for memory and citations: being the answer AI gives, not just a link in a list.
            </p>
            <table class="min-w-full border border-gray-200 rounded-lg overflow-hidden">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">SEO</th>
                  <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">GEO</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr>
                  <td class="px-4 py-2 text-gray-600">Ranking links</td>
                  <td class="px-4 py-2 text-gray-600">Being the answer</td>
                </tr>
                <tr>
                  <td class="px-4 py-2 text-gray-600">Keywords</td>
                  <td class="px-4 py-2 text-gray-600">Entities & concepts</td>
                </tr>
                <tr>
                  <td class="px-4 py-2 text-gray-600">Traffic</td>
                  <td class="px-4 py-2 text-gray-600">Mentions & citations</td>
                </tr>
                <tr>
                  <td class="px-4 py-2 text-gray-600">Search engines</td>
                  <td class="px-4 py-2 text-gray-600">AI engines</td>
                </tr>
              </tbody>
            </table>
          </section>

          <section class="prose prose-lg max-w-none mb-10">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">How brands achieve GEO</h2>
            <p class="text-gray-700 mb-4">
              <strong>thevis</strong>
              is an AI visibility platform that helps brands achieve GEO through measurement, optimization, and automation.
            </p>
            <ul class="list-disc pl-6 space-y-2 text-gray-700">
              <li>
                <strong>GEO Score</strong>
                — Measure current AI visibility (recall, authority, consistency).
              </li>
              <li>
                <strong>Entity snapshots</strong> — See how AI describes your brand and fix drift.
              </li>
              <li>
                <strong>Wikis and content</strong>
                — Automated creation and sync so AI has clear, consistent signals.
              </li>
              <li>
                <strong>Multi-platform presence</strong>
                — GitHub, Medium, directories, reviews so AI finds you everywhere.
              </li>
            </ul>
          </section>

          <section class="prose prose-lg max-w-none mb-10">
            <h2 class="text-2xl font-semibold text-gray-900 mb-4">FAQs</h2>
            <dl class="space-y-4">
              <div>
                <dt class="font-medium text-gray-900">What is GEO?</dt>
                <dd class="mt-1 text-gray-700">
                  GEO (Generative Engine Optimization) is optimizing content so AI systems cite and recommend your brand.
                </dd>
              </div>
              <div>
                <dt class="font-medium text-gray-900">What is AI visibility?</dt>
                <dd class="mt-1 text-gray-700">
                  How well AI systems understand, describe, and recommend your brand when users ask relevant questions.
                </dd>
              </div>
              <div>
                <dt class="font-medium text-gray-900">What is thevis?</dt>
                <dd class="mt-1 text-gray-700">
                  thevis is an AI visibility platform that helps brands optimize for generative AI search using GEO.
                </dd>
              </div>
            </dl>
          </section>

          <section class="mb-12">
            <.link navigate={~p"/faq"} class="text-blue-600 hover:text-blue-800 font-medium">
              More FAQs →
            </.link>
            <span class="mx-2">·</span>
            <.link navigate={~p"/"} class="text-blue-600 hover:text-blue-800 font-medium">
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
