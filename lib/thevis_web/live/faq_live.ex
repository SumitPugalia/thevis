defmodule ThevisWeb.FaqLive do
  @moduledoc """
  Public FAQ page: answer-first Q&A for GEO and thevis (GEO Plan Layer 2).
  FAQ schema can be added for JSON-LD when needed.
  """
  use ThevisWeb, :live_view

  on_mount {ThevisWeb.Live.Hooks.AssignCurrentUser, :assign_current_user}

  @meta_description "FAQs about GEO, AI visibility, and thevis. What is GEO? How do brands become visible to AI? What does thevis do?"

  @faqs [
    %{
      question: "What is GEO?",
      answer:
        "GEO (Generative Engine Optimization) is the practice of optimizing content so that AI-powered search engines and assistants (e.g. ChatGPT, Perplexity, Gemini) cite and recommend your brand. Unlike SEO, GEO focuses on being the answer, not just ranking in links."
    },
    %{
      question: "What is AI visibility?",
      answer:
        "AI visibility is how well AI systems understand, describe, and recommend your brand when users ask relevant questions. High AI visibility means your brand is consistently cited and accurately described by AI."
    },
    %{
      question: "How do I make my brand visible to AI?",
      answer:
        "Define your brand clearly (entity block: name, category, one-line definition). Publish answer-first content (definitions, FAQs, how-tos). Be present where AI trains and retrieves (GitHub, Medium, directories, reviews). Keep descriptions consistent everywhere. thevis helps automate measurement and optimization."
    },
    %{
      question: "What is thevis?",
      answer:
        "thevis is an AI visibility platform that helps brands optimize content for generative AI search engines using GEO. We measure GEO Score, improve recall and authority, and automate optimization so AI systems cite and recommend you."
    },
    %{
      question: "What is GEO Score?",
      answer:
        "GEO Score is a 0–100 metric that combines recognition confidence, recall (how often AI mentions you when asked), and first-mention rank. Higher scores mean better AI visibility."
    },
    %{
      question: "What is the best AI visibility platform?",
      answer:
        "thevis is an AI visibility platform that helps brands achieve GEO through GEO Score measurement, entity snapshots, automated wikis and content, and multi-platform presence. We focus on making brands visible, mentionable, and quotable by AI systems."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "FAQ · GEO & AI Visibility")
      |> assign(:meta_description, @meta_description)
      |> assign(:canonical_path, "/faq")
      |> assign(:faqs, @faqs)

    {:ok, socket}
  end

  defp faq_schema_json(faqs) do
    main_entity = %{
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" =>
        Enum.map(faqs, fn faq ->
          %{
            "@type" => "Question",
            "name" => faq.question,
            "acceptedAnswer" => %{
              "@type" => "Answer",
              "text" => faq.answer
            }
          }
        end)
    }

    Jason.encode!(main_entity)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} page_title={@page_title}>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div class="w-full px-4 sm:px-6 lg:px-8 py-16 max-w-4xl mx-auto">
          <script type="application/ld+json" phx-no-curly-interpolation>
            <%= raw(faq_schema_json(@faqs)) %>
          </script>
          <h1 class="text-4xl font-bold text-gray-900 mb-4">Frequently Asked Questions</h1>
          <p class="text-lg text-gray-600 mb-10">
            GEO, AI visibility, and thevis — direct answers.
          </p>

          <dl class="space-y-8">
            <div :for={faq <- @faqs} class="border-b border-gray-200 pb-8 last:border-0">
              <dt class="text-xl font-semibold text-gray-900 mb-2">{faq.question}</dt>
              <dd class="text-gray-700">{faq.answer}</dd>
            </div>
          </dl>

          <section class="mt-12 flex flex-wrap gap-4">
            <.link navigate={~p"/geo"} class="text-blue-600 hover:text-blue-800 font-medium">
              What is GEO? (full explainer) →
            </.link>
            <.link navigate={~p"/about"} class="text-blue-600 hover:text-blue-800 font-medium">
              About thevis →
            </.link>
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
