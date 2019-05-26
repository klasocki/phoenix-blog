defmodule PhoenixBlogWeb.PostController do
  use PhoenixBlogWeb, :controller

  alias PhoenixBlog.Repo
  alias PhoenixBlog.Content
  alias PhoenixBlog.Content.Post
  alias PhoenixBlog.Content.Comment

  plug :scrub_params, "comment" when action in [:add_comment]

  def add_comment(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    post = Post
           |> Repo.get!(post_id)
           |> Repo.preload([:comments])
    comment = Ecto.build_assoc(post, :comments, content: comment_params["content"], name: comment_params["name"])
    Repo.insert!(comment)

    conn
    |> put_flash(:info, "Comment added.")
    |> redirect(to: Routes.post_path(conn, :show, post))
  end

  def index(conn, _params) do
    posts = Post |> Post.count_comments |> Repo.all
#      Content.list_posts() |> Enum.map(Post.count_comments())
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Content.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Content.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Content.get_post!(id)
           |> Repo.preload([:comments])
    changeset = Comment.changeset(%Comment{}, %{"name" => "Nazwa użytkownika", "content" => "Treść komentarza"})
    render(conn, "show.html", post: post, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Content.get_post!(id)
    changeset = Content.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Content.get_post!(id)

    case Content.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Content.get_post!(id) |> Repo.preload([:comments])
    {:ok, _post} = Content.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end
end
