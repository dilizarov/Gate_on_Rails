class Api::V1::GeneratedGatesController < ApiController

  def manage
    @gates = Gate.process_coords_for_gates!(params[:lat], params[:long])
    
    new_generated_gates = current_user.process_generated_gates!(@gates)
    
    Notifications.perform_async(GENERATED_GATES_NOTIFICATION,
                                current_user.id,
                                current_user.name,
                                new_generated_gates.map(&:name))
    
    @gates = current_user.gates_with_users_count(includes: :creator)
   
    render status: 200,
           json: @gates,
           each_serializer: GateSerializer,
           root: "Gates",
           meta: { success: true,
                   info: "Gates",
                   total: @gates.length }
  end

end
