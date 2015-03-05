class Api::V1::GatekeepersController < ApiController
  
  def grant_access
     @gates = Gate.where(external_id: params[:gate_ids])
     gatekeeper = User.find_by(external_id: params[:gatekeeper_id])
     throw ActiveRecord::RecordNotFound if @gates.length != params[:gate_ids].length || gatekeeper.nil?
     throw CanCan::AccessDenied unless gatekeeper.in_gates? @gates
     
     @gates = gatekeeper.grant_access(@gates, current_user)
     @gates = current_user.gates_with_users_count(includes: :creator).select { |gate| @gates.include? gate }
     Gate.check_sessions!(@gates, params[:auth_token])
     Gate.check_unlocked_status!(@gates, current_user)
     
     render status: 200,
            json: @gates,
            each_serializer: GateSerializer,
            root: "gates"
  end  
end
