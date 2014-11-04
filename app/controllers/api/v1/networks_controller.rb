class Api::V1::NetworksController < ApiController
  load_and_authorize_resource find_by: :external_id, except: [:index]
  
  def index
    @networks = current_user.networks
    
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
    #We consolidate, but we don't show any info about the network itself.
    @network = @network.consolidate_feed_and_users
    render status: 200,
           json: @network
  end
  
  def leave
    UserNetwork.find_by(user_id: current_user.id, network_id: @network.id).destroy
    head :no_content
  end

  private
  
  def network_params
    params.
      require(:network).
      permit(:name).
      merge(creator_id: current_user.id)
  end

end
