class PostsController < ApplicationController
  before_action :authorize # ← Replaces authenticate_user!
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  # GET /posts
  def index
    @posts = Post.includes(:user, :tags, :comments).all
    render json: @posts
  end

  # GET /posts/:id
  def show
    render json: @post
  end

  # POST /posts
  def create
    @post = current_user.posts.build(post_params)

    if @post.tags.empty?
      return render json: { error: "At least one tag is required" }, status: :unprocessable_entity
    end

    if @post.save
      # Schedule deletion after 24 hours
      PostDeletionJob.set(wait: 24.hours).perform_later(@post.id)
      render json: @post, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    return head :forbidden unless @post.user == current_user
  end

  def post_params
    params.require(:post).permit(:title, :body, tag_ids: [])
  end
end
