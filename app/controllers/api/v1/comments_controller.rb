class Api::V1::CommentsController < ApiController
  load_and_authorize_resource :post, find_by: :external_id, except: [:destroy, :up]
  load_resource :comment, :through => :post, only: [:create]
  
  load_resource find_by: :external_id, only: [:destroy, :up]
  
  authorize_resource except: [:index]
  
  def index
    @comments = @post.comments.includes(:user).to_a
    
    current_user.mark_uped_comments!(@comments)
    
    if params[:include_post]
      current_user.mark_uped_posts!([@post])
      
      render status: 200,
             json: @comments,
             meta: JSON(PostSerializer.new(@post).to_json).parse
    else
      render status: 200,
             json: @comments
    end
  end
  
  def create
    if @comment.save
      Notifications.perform_async(COMMENT_CREATED_NOTIFICATION,
                                  current_user.id,
                                  current_user.name,
                                  @comment.post_id,
                                  @comment.body)
      
      render status: 200,
             json: @comment
    else
      render status: :unprocessable_entity,
             json: { errors: @comment.errors.full_messages }
    end
  end
  
  def destroy
    @comment.destroy
    head :no_content
  end
  
  def up
    if params[:revert]
      @comment.unliked_by(current_user)
    else
      @comment.liked_by(current_user)
    
      Notifications.perform_async(COMMENT_LIKED_NOTIFICATION,
                                  current_user.id,
                                  current_user.name,
                                  @comment.body,
                                  @comment.user_id,
                                  @comment.post_id)
    end
    
    head :no_content
  end
  
  
  private
  
  def comment_params
    params.
      require(:comment).
      permit(:body).
      merge(user_id: current_user.id)
  end
  
end