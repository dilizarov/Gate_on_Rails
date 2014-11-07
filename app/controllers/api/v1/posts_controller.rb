class Api::V1::PostsController < ApiController
  load_and_authorize_resource :network, find_by: :external_id, except: [:destroy]
  load_resource :post, :through => :network, only: [:create]
  
  load_resource find_by: :external_id, except: [:create]
  
  authorize_resource except: [:index]
  
  def index
    unless scrolling?
      @posts = @network.posts.page(params.has_key?(:page) ? params[:page] : 1).per(15)
    else
      @posts = @network.posts.where('created_at < ?', params[:infinite_scroll_time_buffer]).
                        page(params[:page]).per(15)
    end
    
    @posts = @posts.includes(:user)
    
    render status: 200,
           json: @posts
  end

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
  
  def scrolling?
    params.has_key?(:infinite_scroll_time_buffer)
  end
  
  def post_params
    params.
      require(:post).
      permit(:body).
      merge(user_id: current_user.id)
  end

end
