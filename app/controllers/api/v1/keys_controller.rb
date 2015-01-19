class Api::V1::KeysController < ApiController
  before_action :load_already_existing_key, only: [:destroy]
  
  load_resource except: [:index, :prokess]
  authorize_resource except: [:prokess]
  
  def create
    if @key.save
      render status: 200,
             json: @key,
             meta: { success: true, 
                     info: "Key created" }          
    else
      render status: :unprocessable_entity,
             json: { errors: @key.errors.full_messages }
    end
  end
  
  def destroy
    @key.destroy
    head :no_content
  end
  
  def index
    @keys = current_user.keys.active
    
    render status: 200,
           json: @keys,
           meta: { success: true,
                   info: "Keys" }
  end
  
  # ActionController::Base has a method named process.
  def prokess
    @key = Key.find_by_key(params[:id])
    
    if @key && @key.active?
      throw CanCan::AccessDenied if @key.gatekeeper_id == current_user.id
      
      @new_gates = @key.process(current_user)
      @new_gates = current_user.gates_with_users_count(includes: :creator).select do |gate|
        @new_gates.include? gate
      end
      
      render status: 200,
             json: @new_gates, 
             each_serializer: GateSerializer,
             root: "gates",
             meta: { success: true,
                     info: "Key processed",
                     data: { gatekeeper: @key.gatekeeper.name } }
    else
      render status: :locked,
             json: { errors: [ "This key doesn't unlock any gates" ] }
    end
  end
  
  private
  
  def key_params
    params.
      require(:key).
      permit(gates: []).
      merge(gatekeeper_id: current_user.id)
  end
  
  # CanCanCan doesn't mesh well with attr_encrypted
  def load_already_existing_key
    @key = Key.find_by_key(params[:id])
  end
end
