class Api::V1::PostsController < ApplicationController

  def create
    @network = Network.find_by(external_id: params[:external_id])
    
    if current_user.in_network?(@network)
      
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
      render status: :unauthorized,
             json: { success: false,
                     info: "Unauthorized to post in this network" }
    end
  end
  
  private
  
  def post_params
    params.require(:post).permit(:body)
  end

end
