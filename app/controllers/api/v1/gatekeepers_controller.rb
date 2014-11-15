class Api::V1::GatekeepersController < ApiController
  
  def grant_access
     @networks = Network.where(external_id: params[:network_ids])
     gatekeeper = User.find_by(external_id: params[:gatekeeper_id])
     throw ActiveRecord::RecordNotFound if networks.length != params[:network_ids].length || gatekeeper.nil?
     throw CanCan::AccessDenied unless gatekeeper.in_networks? networks
     
     gatekeeper.grant_access(networks, current_user)
     
     @networks = current_user.networks_with_users_count(includes: :creator).select { |network| @networks.include? network }
     
     render status: 200,
            json: @networks,
            each_serializer: NetworkSerializer
  end
end
