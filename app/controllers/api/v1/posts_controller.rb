class Api::V1::PostsController < ApiController
  load_and_authorize_resource :gate, find_by: :external_id, except: [:destroy, :aggregate, :up, :show]
  load_resource :post, :through => :gate, only: [:create]
  
  load_resource find_by: :external_id, except: [:create, :aggregate]
  
  authorize_resource except: [:index, :aggregate]
  
  def index
    @posts = @gate.posts.
                      includes(:user).
                      created_before(time_buffer).
                      page(page).
                      per(15).
                      to_a
                      
    current_user.mark_uped_posts!(@posts)                                  
                            
    render status: 200,
           json: @posts
  end

  def show
    current_user.mark_uped_posts!([@post])
    
    render status: 200,
           json: @post
  end

  def create
    if @post.save
      
      Notifications.perform_async(POST_CREATED_NOTIFICATION,
                                  current_user.id,
                                  current_user.name,
                                  @post.gate_id,
                                  @post.body)
                    
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
                         includes(:user, :gate).
                         page(page).
                         per(15).
                         to_a
                         
    current_user.mark_uped_posts!(@posts)
    
    render status: 200,
           json: @posts
  end
  
  def up
    if params[:revert]
      @post.unliked_by(current_user)
    else
      @post.liked_by(current_user)
      
      Notifications.perform_async(POST_LIKED_NOTIFICATION,
                                  current_user.id,
                                  current_user.name,
                                  @post.user_id,
                                  @post.id)
    end
    
    head :no_content
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
