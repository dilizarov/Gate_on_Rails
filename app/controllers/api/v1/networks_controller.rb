class Api::V1::NetworksController < ApiController

  def index
    @networks = current_user.networks
    
    render status: 200,
           json: @networks,
           meta: { success: true,
                   info: "Networks",
                   total: @networks.length }
  end
  
  def create
    @network = Network.new(network_params)
    @network.creator_id = current_user.id
    @network.generate_external_id!
    
    if @network.save
      UserNetwork.create(user_id: current_user.id, network_id: @network.id)
      render status: 200,
             json: @network,
             meta: { success: true, 
                     info: "Network made" }
    else
      render status: :unprocessable_entity,
             json: { errors: @network.errors.full_messages }
    end 
  end

  private
  
  def network_params
    params.require(:network).permit(:name)
  end

end
