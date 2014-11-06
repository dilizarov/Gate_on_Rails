class Api::V1::NetworksController < ApiController
  load_and_authorize_resource find_by: :external_id, except: [:index]
  
  def index
    @networks = current_user.networks_with_user_count
    
    render status: 200,
           json: @networks,
           each_serializer: SimpleNetworkSerializer,
           meta: { success: true,
                   info: "Networks",
                   total: @networks.length }
  end
  
  def create
    if @network.save
      render status: 200,
             json: @network,
             serializer: SimpleNetworkSerializer,
             meta: { success: true, 
                     info: "Network made" }
    else
      render status: :unprocessable_entity,
             json: { errors: @network.errors.full_messages }
    end 
  end
  
  def show
    unless scrolling?
      @posts = @network.posts.page(params.has_key?(:page) ? params[:page] : 1).per(15)
    else
      @posts = @network.posts.where('created_at < ?', params[:infinite_scroll_buffer]).
                        page(params[:page]).per(15)
    end
    
    
    render status: 200,
           json: @posts,
           serializer: PostSerializer
  end
  
  def leave
    UserNetwork.find_by(user_id: current_user.id, network_id: @network.id).destroy
    head :no_content
  end

  private
  
  def scrolling?
    params.has_key?(:infinite_scroll_time_buffer)
  end
  
  def network_params
    params.
      require(:network).
      permit(:name).
      merge(creator_id: current_user.id)
  end

end
