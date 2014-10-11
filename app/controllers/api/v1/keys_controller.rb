class Api::V1::KeysController < ApiController
  before_action :load_already_existing_key, only: [:destroy]
  
  load_resource except: [:index]
  authorize_resource
  
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
    if @key.active?
      @new_networks = @key.process(current_user)
      
      render status: 200,
             json: @new_networks, 
             each_serializer: SimpleNetworkSerializer,
             meta: { success: true,
                     info: "Key processed." }
    else
      render status: :locked,
             json: { success: false,
                     info: "This key doesn't unlock the gate" }
    end
  end
  
  private
  
  def key_params
    params.
      require(:key).
      permit(networks: []).
      merge(gatekeeper_id: current_user.id)
  end
  
  # CanCanCan doesn't mesh well with attr_encrypted
  def load_already_existing_key
    @key = Key.find_by_key(params[:id])
  end
end
