class Api::V1::NetworksController < ApiController
  load_resource find_by: :external_id, except: [:index]
  authorize_resource only: [:leave]
  def index
    @networks = current_user.networks_with_users_count(includes: :creator)
    
    render status: 200,
           json: @networks,
           meta: { success: true,
                   info: "Networks",
                   total: @networks.length }
  end
  
  def create
    if @network.save
      render status: 200,
             json: @network,
             meta: { success: true, 
                     info: "Network made" }
    else
      render status: :unprocessable_entity,
             json: { errors: @network.errors.full_messages }
    end 
  end
  
  def show
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
