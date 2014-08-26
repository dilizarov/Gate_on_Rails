class Api::V1::PostsController < ApiController
  load_resource find_by: :external_id
  authorize_resource

  def create
    @network = Network.find_by(external_id: params[:network_external_id])
    
    if @network && current_user.in_network?(@network)
      
      @post = @network.posts.build(post_params)
      @post.user_id = current_user.id
      
      if @post.save        
        render status: 200,
               json: @post
      else
        render status: :unprocessable_entity,
               json: { errors: @post.errors.full_messages }
      end
    else
      head :bad_request
    end
  end
  
  # Should be ok
  def destroy
    # post = Post.find_by(external_id: params[:id])
#
#     if @post && current_user.owns_post?(@post)
      @post.destroy
      head :no_content
    # else
#       head :bad_request
#     end
  end
  
  private
  
  def post_params
    params.require(:post).permit(:body)
  end

end
