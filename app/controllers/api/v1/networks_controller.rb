class Api::V1::NetworksController < ApiController
  load_and_authorize_resource find_by: :external_id, except: [:index]
  
  def index
    @networks = current_user.networks
    
    render status: 200,
           json: @networks,
           serializer: SimpleNetworkSerializer,
           meta: { success: true,
                   info: "Networks",
                   total: @networks.length }
  end
  
  def create
    if @network.save
      UserNetwork.create(user_id: current_user.id, network_id: @network.id)
      
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
    
  end

  private
  
  def network_params
    params.
      require(:network).
      permit(:name).
      merge(creator_id: current_user.id)
  end

end
