class Api::V1::GatesController < ApiController
  load_resource find_by: :external_id, except: [:index]
  authorize_resource only: [:leave]
  
  def index
    @gates = current_user.gates_with_users_count(includes: :creator)
  
    Gate.check_sessions!(@gates, params[:auth_token])
    Gate.check_unlocked_status!(@gates, current_user)
    
    render status: 200,
           json: @gates,
           meta: { success: true,
                   info: "Gates",
                   total: @gates.length }
  end
  
  def create
    if @gate.save
      render status: 200,
             json: @gate,
             meta: { success: true, 
                     info: "Gate made" }
    else
      render status: :unprocessable_entity,
             json: { errors: @gate.errors.full_messages }
    end 
  end
  
  def show
  end
  
  def leave
    UserGate.find_by(user_id: current_user.id, gate_id: @gate.id).destroy
    head :no_content
  end

  private
  
  def gate_params
    params.
      require(:gate).
      permit(:name).
      merge(creator_id: current_user.id)
  end

end
