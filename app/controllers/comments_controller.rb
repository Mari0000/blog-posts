class CommentsController < ApplicationController
  before_action :set_post, only: [:index, :create]
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /comments
  def index
    @comments = @post.comments

    render json: @comments
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST /comments
  def create
    @comment = Comment.new(comment_params)
    @comment.post = @post
    @comment.commenter = current_user
    if @comment.save
      render json: @comment, status: :created, location: post_comments_path(@comment)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_post 
      @post = Post.find(params[:post_id])
    end 

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:text, :commenter_id, :post_id)
    end
end
