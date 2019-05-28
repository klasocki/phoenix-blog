defmodule PhoenixBlogWeb.Router do
  use PhoenixBlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixBlogWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/posts", PostController do
      post "/comment", PostController, :add_comment
    end
  end
end
