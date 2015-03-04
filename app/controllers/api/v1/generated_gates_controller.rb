class Api::V1::GeneratedGatesController < ApiController

  def prokess
    @gates = Gate.process_coords_for_gates!(params[:lat], params[:long])
    
    auth_token = current_user.authentication_tokens.where(token: params[:auth_token]).first
    
    new_generated_gates = current_user.process_generated_gates!(@gates, auth_token)
    
    Notifications.perform_async(GENERATED_GATES_NOTIFICATION,
                                current_user.id,
                                current_user.name,
                                new_generated_gates.map(&:name))
    
    @gates = current_user.gates_with_users_count(includes: :creator)
   
    Gate.check_sessions!(@gates, auth_token)
   
    render status: 200,
           json: @gates,
           each_serializer: GateSerializer,
           root: "gates",
           meta: { success: true,
                   info: "Gates",
                   total: @gates.length }
  end
  
  def leave
    auth_token = current_user.authentication_tokens.where(token: params[:auth_token]).first
    current_user.leave_generated_gates(auth_token)
    
    head :no_content
  end

end
