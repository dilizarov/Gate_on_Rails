class Api::V1::GatekeeperHqsController < ApiController
  
  def grant_access
     networks = Network.where(external_id: params[:network_ids])
     other_user = User.find_by(external_id: params[:other_user_id])
     throw ActiveRecord::RecordNotFound if networks.length != params[:network_ids].length || other_user.nil?
     throw CanCan::AccessDenied unless current_user.in_networks? networks
     
     current_user.grant_access(networks, other_user)
     
     head :no_content 
  end
end
