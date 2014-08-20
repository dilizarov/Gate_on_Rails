class Api::V1::KeysController < ApiController
  
  def create
    @key.new(key_params)
    @key.gatekeeper_id = current_user.id
    @key.generate_key!
    @key.generate_external_id!
    
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
  
  def index
    @keys = current_user.keys.active
    
    render status: 200,
           json: @keys,
           meta: { success: true,
                   info: "Keys" }
  end
  
  def process
    @key = Key.find_by(key: params[:key])
    
    if @key && @key.active?
      @key.process(current_user)
      
      # Figure out what to render
      # render status: 200,
#              json:
    else
      # Convenient 423 status
      render status: :locked,
             json: { success: false,
                     info: "This key doesn't unlock the gate" }
    end
  end
  
  private
  
  def key_params
    params.require(:key).permit(:networks)
  end
  
end
