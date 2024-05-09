defmodule MensaplanWeb.Navbar do
  use Phoenix.Component

  use MensaplanWeb, :verified_routes
  import MensaplanWeb.CoreComponents

  def navbar(assigns) do
    ~H"""
    <div id="navbar-menu" class="relative z-50 hidden">
      <div id="navbar-backdrop" class="fixed inset-0 bg-gray-800 opacity-75"></div>
      <nav class="fixed top-0 left-0 bottom-0 flex flex-col w-5/6 max-w-sm py-6 px-6 bg-white border-r overflow-y-auto">
        <div class="flex justify-between mb-8">
          <a href="/">
            <img class="h-12" src={~p"/images/logo.svg"} alt="Logo" />
          </a>
          <button id="navbar-close"><.icon name="hero-x-mark-solid" /></button>
        </div>
        <.nav_links user={@user} />
      </nav>
    </div>

    <div class="flex justify-between items-center sm:hidden">
      <a class="px-3" href="/">
        <img class="h-8" src={~p"/images/logo.svg"} alt="Logo" />
      </a>
      <span class="font-semibold text-gray-500"> Mensaplan </span>
      <button id="navbar-burger" class="flex items-center text-blue-600 p-3">
        <.icon name="hero-bars-3" />
      </button>
    </div>

    <nav class="hidden sm:flex flex-col sm:flex-row justify-between items-center px-4 py-2 whitespace-nowrap">
      <a href="/">
        <img class="h-8" src={~p"/images/logo.svg"} alt="Logo" />
      </a>
      <.nav_links user={@user} />
    </nav>

    <script>
      // https://tailwindcomponents.com/component/navbar-hamburger-menu/
      // Burger menu
      document.addEventListener('DOMContentLoaded', function() {
          const burger = document.querySelector('#navbar-burger');
          const menu = document.querySelector('#navbar-menu');
          const close = document.querySelector('#navbar-close');
          const backdrop = document.querySelector('#navbar-backdrop');

          if (!burger || !menu || !close || !backdrop) {
              alert('Missing burger, menu, close or backdrop');
              return;
          }

          burger.addEventListener('click', function() {
              menu.classList.toggle('hidden');
          });

          close.addEventListener('click', function() {
              menu.classList.toggle('hidden');
          });

          backdrop.addEventListener('click', function() {
              menu.classList.toggle('hidden');
          });
      });
    </script>
    """
  end

  def nav_links(assigns) do
    ~H"""
    <div class="flex flex-col sm:flex-row font-semibold ml-4 justify-evenly">
      <a class="p-4 sm:py-2 text-gray-500 hover:bg-blue-50 hover:text-blue-600 rounded" href="/">
        Home
      </a>
      <a
        class="p-4 sm:py-2 text-gray-500 hover:bg-blue-50 hover:text-blue-600 rounded"
        href="https://tum-dev.github.io/eat-api/#!/en/mensa-garching"
      >
        Menu <.icon name="hero-arrow-top-right-on-square" class="h-4" />
      </a>
      <a class="p-4 sm:py-2 text-gray-500 hover:bg-blue-50 hover:text-blue-600 rounded" href="/docs">
        API Docs
      </a>
      <a class="p-4 sm:py-2 text-gray-500 hover:bg-blue-50 hover:text-blue-600 rounded" href="/about">
        About
      </a>
    </div>

    <%= if @user do %>
      <a href="/settings" class="inline-block m-3 sm:ml-auto mt-auto sm:mb-auto" title="Settings">
        <img src={@user.avatar} class="rounded-full max-h-9" alt="User Avatar" />
      </a>
      <a
        href="/auth/logout"
        class="inline-block m-2 py-2 px-6 text-sm font-bold rounded-xl transition duration-200 bg-red-500 hover:bg-red-600 text-white"
      >
        Log out
      </a>
    <% else %>
      <a
        class="inline-block m-2 mt-auto sm:m-3 sm:ml-auto py-3 sm:py-2 px-6 text-sm font-bold rounded-xl transition duration-200 bg-gray-200/75 hover:bg-gray-300/80 text-gray-900"
        href="/auth/auth0"
      >
        Sign In
      </a>
      <a
        class="inline-block m-2 py-3 sm:py-2 px-6 text-sm font-bold rounded-xl transition duration-200 bg-blue-500 hover:bg-blue-600 text-white focus:outline-offset-2"
        href="/auth/auth0?screen_hint=signup"
      >
        Sign up
      </a>
    <% end %>
    """
  end
end
