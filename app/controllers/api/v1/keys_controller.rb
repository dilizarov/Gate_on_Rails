class Api::V1::KeysController < ApiController
  
  def create
    # TODO: Check if I could just do 
    # @key.new(key_params, gatekeeper_id: current_user.id)
    # For some reason, I don't think I am able to.
    
    @key = Key.new(key_params)
    @key.gatekeeper_id = current_user.id
    
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
    @key = Key.find_by_key(params[:key])
    
    if @key
      @key.destroy
      head :no_content
    else
      head :bad_request
    end
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
    @key = Key.find_by_key(params[:key])
    
    if @key && @key.active?
      @new_networks = @key.process(current_user)
      
      render status: 200,
             json: @new_networks, serializer: SimpleNetworkSerializer,
             meta: { success: true,
                     info: "Key processed." }
    else
      # Convenient 423 status
      render status: :locked,
             json: { success: false,
                     info: "This key doesn't unlock the gate" }
    end
  end
  
  private
  
  def key_params
    params.require(:key).permit(networks: [])
  end
  
end
