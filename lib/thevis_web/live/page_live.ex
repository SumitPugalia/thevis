defmodule ThevisWeb.PageLive do
  @moduledoc """
  Landing page for thevis.ai - public-facing homepage.
  """

  use ThevisWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "thevis.ai - Making brands visible to AI")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <!-- Navigation -->
        <nav class="bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-50">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-16">
              <div class="flex items-center gap-2">
                <span class="text-2xl font-bold text-gray-900">thevis</span>
                <span class="text-sm text-gray-500">.ai</span>
              </div>
              <div class="flex items-center gap-4">
                <%= if assigns[:current_user] do %>
                  <.link
                    navigate={~p"/dashboard"}
                    class="text-sm text-gray-600 hover:text-gray-900"
                  >
                    Dashboard
                  </.link>
                  <.link
                    href={~p"/logout"}
                    method="delete"
                    class="text-sm text-gray-600 hover:text-gray-900"
                  >
                    Sign out
                  </.link>
                <% else %>
                  <.link
                    navigate={~p"/login"}
                    class="text-sm text-gray-600 hover:text-gray-900"
                  >
                    Sign in
                  </.link>
                  <.link
                    navigate={~p"/register"}
                    class="text-sm bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Sign up
                  </.link>
                <% end %>
              </div>
            </div>
          </div>
        </nav>
        
    <!-- Hero Section -->
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div class="text-center">
            <h1 class="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
              Making brands
              <span class="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                visible to AI
              </span>
            </h1>
            <p class="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
              Ensure AI systems correctly understand, describe, and recommend your products and services.
              Optimize your AI visibility with automated GEO (Generative Engine Optimization).
            </p>
            <div class="flex gap-4 justify-center">
              <%= if assigns[:current_user] do %>
                <.link
                  navigate={~p"/dashboard"}
                  class="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors text-lg"
                >
                  Go to Dashboard <.icon name="hero-arrow-right" class="w-5 h-5" />
                </.link>
              <% else %>
                <.link
                  navigate={~p"/register"}
                  class="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors text-lg"
                >
                  Get Started <.icon name="hero-arrow-right" class="w-5 h-5" />
                </.link>
                <.link
                  navigate={~p"/login"}
                  class="inline-flex items-center gap-2 px-6 py-3 bg-white text-gray-900 font-medium rounded-lg border-2 border-gray-300 hover:border-gray-400 transition-colors text-lg"
                >
                  Sign In
                </.link>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Features Section -->
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div class="text-center mb-16">
            <h2 class="text-3xl font-bold text-gray-900 mb-4">How thevis.ai Works</h2>
            <p class="text-lg text-gray-600 max-w-2xl mx-auto">
              We optimize your AI visibility through comprehensive measurement, analysis, and automated optimization.
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Feature 1 -->
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-8 hover:shadow-md transition-shadow">
              <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4">
                <.icon name="hero-chart-bar" class="w-6 h-6 text-blue-600" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 mb-2">GEO Score Measurement</h3>
              <p class="text-gray-600">
                Measure your current AI visibility with our comprehensive GEO Score. Track recall, authority, and consistency metrics.
              </p>
            </div>
            
    <!-- Feature 2 -->
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-8 hover:shadow-md transition-shadow">
              <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mb-4">
                <.icon name="hero-sparkles" class="w-6 h-6 text-purple-600" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 mb-2">Automated Optimization</h3>
              <p class="text-gray-600">
                AI-powered automation improves your presence through wiki pages, content creation, link building, and more.
              </p>
            </div>
            
    <!-- Feature 3 -->
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm p-8 hover:shadow-md transition-shadow">
              <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mb-4">
                <.icon name="hero-rocket-launch" class="w-6 h-6 text-green-600" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 mb-2">Product Launch Support</h3>
              <p class="text-gray-600">
                Specialized workflows for new product launches. Establish AI visibility quickly during your launch window.
              </p>
            </div>
          </div>
        </div>
        
    <!-- Use Cases Section -->
        <div class="bg-white py-20">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16">
              <h2 class="text-3xl font-bold text-gray-900 mb-4">Perfect For</h2>
              <p class="text-lg text-gray-600 max-w-2xl mx-auto">
                Whether you're launching a new product or optimizing existing services, we've got you covered.
              </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
              <!-- Product-Based Companies -->
              <div class="bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg border border-blue-200 p-8">
                <div class="flex items-center gap-3 mb-4">
                  <div class="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
                    <.icon name="hero-cube" class="w-6 h-6 text-white" />
                  </div>
                  <h3 class="text-2xl font-bold text-gray-900">Product-Based Companies</h3>
                </div>
                <ul class="space-y-3 text-gray-700">
                  <li class="flex items-start gap-2">
                    <.icon
                      name="hero-check-circle"
                      class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0"
                    />
                    <span>New product launches (cosmetics, edibles, D2C brands)</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <.icon
                      name="hero-check-circle"
                      class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0"
                    />
                    <span>Existing product optimization</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <.icon
                      name="hero-check-circle"
                      class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0"
                    />
                    <span>Category-level optimization</span>
                  </li>
                </ul>
              </div>
              
    <!-- Service-Based Companies -->
              <div class="bg-gradient-to-br from-purple-50 to-pink-50 rounded-lg border border-purple-200 p-8">
                <div class="flex items-center gap-3 mb-4">
                  <div class="w-10 h-10 bg-purple-600 rounded-lg flex items-center justify-center">
                    <.icon name="hero-building-office" class="w-6 h-6 text-white" />
                  </div>
                  <h3 class="text-2xl font-bold text-gray-900">Service-Based Companies</h3>
                </div>
                <ul class="space-y-3 text-gray-700">
                  <li class="flex items-start gap-2">
                    <.icon
                      name="hero-check-circle"
                      class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0"
                    />
                    <span>SaaS providers and software companies</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <.icon
                      name="hero-check-circle"
                      class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0"
                    />
                    <span>Consulting firms and agencies</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <.icon
                      name="hero-check-circle"
                      class="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0"
                    />
                    <span>Service businesses needing AI visibility</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
        
    <!-- CTA Section -->
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div class="bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl p-12 text-center">
            <h2 class="text-3xl font-bold text-white mb-4">Ready to improve your AI visibility?</h2>
            <p class="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
              Join companies optimizing their presence in AI systems. Get started with a free audit.
            </p>
            <%= if assigns[:current_user] do %>
              <.link
                navigate={~p"/dashboard"}
                class="inline-flex items-center gap-2 px-6 py-3 bg-white text-blue-600 font-medium rounded-lg hover:bg-gray-100 transition-colors text-lg"
              >
                Go to Dashboard <.icon name="hero-arrow-right" class="w-5 h-5" />
              </.link>
            <% else %>
              <.link
                navigate={~p"/register"}
                class="inline-flex items-center gap-2 px-6 py-3 bg-white text-blue-600 font-medium rounded-lg hover:bg-gray-100 transition-colors text-lg"
              >
                Get Started Free <.icon name="hero-arrow-right" class="w-5 h-5" />
              </.link>
            <% end %>
          </div>
        </div>
        
    <!-- Footer -->
        <footer class="bg-gray-900 text-gray-400 py-12">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <span class="text-xl font-bold text-white">thevis</span>
                <span class="text-sm">.ai</span>
              </div>
              <p class="text-sm">© 2024 thevis.ai. All rights reserved.</p>
            </div>
          </div>
        </footer>
      </div>
    </Layouts.app>
    """
  end
end
