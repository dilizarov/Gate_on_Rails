class Api::V1::CommentsController < ApiController
  load_resource :post, find_by: :external_id, only: [:create]
  load_resource :comment, :through => :post, only: [:create]
  
  load_resource find_by: :external_id, except: [:create]
  
  authorize_resource
  
  def index
    
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
  
  private
  
  def comment_params
    params.
      require(:comment).
      permit(:body).
      merge(user_id: current_user.id)
  end
  
end