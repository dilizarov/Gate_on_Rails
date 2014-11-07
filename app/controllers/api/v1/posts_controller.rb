class Api::V1::PostsController < ApiController
  load_and_authorize_resource :network, find_by: :external_id, except: [:destroy, :aggregate]
  load_resource :post, :through => :network, only: [:create]
  
  load_resource find_by: :external_id, except: [:create, :aggregate]
  
  authorize_resource except: [:index, :aggregate]
  
  def index
      @posts = @network.posts.
                        includes(:user).
                        created_before(time_buffer).
                        page(page).
                        per(15)
                            
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
  
  def aggregate
    @posts = current_user.feed_posts.
                         reorder(created_at: :desc).
                         created_before(time_buffer).
                         includes([:user, :network]).
                         page(page).
                         per(15)
    
    render status: 200,
           json: @posts
  end
  
  private
  
  def time_buffer
    params[:infinite_scroll_time_buffer] and Time.parse(params[:infinite_scroll_time_buffer])
  end
      
  def page
    params.has_key?(:page) ? params[:page] : 1
  end
  
  def post_params
    params.
      require(:post).
      permit(:body).
      merge(user_id: current_user.id)
  end

end
