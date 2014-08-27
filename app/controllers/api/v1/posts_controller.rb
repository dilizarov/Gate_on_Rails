class Api::V1::PostsController < ApiController
  load_resource :network, find_by: :external_id, only: [:create]
  load_resource :post, :through => :network, only: [:create]
  
  load_resource find_by: :external_id, except: [:create]
  
  authorize_resource

  def create
    if @post.save        
      render status: 200,
             json: @post
    else
      render status: :unprocessable_entity,
             json: { errors: @post.errors.full_messages }
    end
  end
  
  def destroy
    @post.destroy
    head :no_content
  end
  
  private
  
  def post_params
    params.
      require(:post).
      permit(:body).
      merge(user_id: current_user.id)
  end

end
