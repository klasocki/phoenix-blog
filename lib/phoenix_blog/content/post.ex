defmodule PhoenixBlog.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "posts" do
    field :body, :string
    field :title, :string
    has_many :comments, PhoenixBlog.Content.Comment, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end

  def count_comments(query) do
    from p in query,
         group_by: p.id,
         left_join: c in assoc(p, :comments),
         select: {p, count(c.id)}
  end
end
