class Api::V1::CommentsController < ApiController
  load_and_authorize_resource :post, find_by: :external_id, except: [:destroy, :up]
  load_resource :comment, :through => :post, only: [:create]
  
  load_resource find_by: :external_id, only: [:destroy, :up]
  
  authorize_resource except: [:index]
  
  def index
    @comments = @post.comments.includes(:user)
    
    user.mark_uped_comments!(@comments)
    
    render status: 200,
           json: @comments
  end
  
  def create
    if @comment.save
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
    params[:revert] ? @comment.unliked_by(current_user) : @comment.liked_by(current_user)
    
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