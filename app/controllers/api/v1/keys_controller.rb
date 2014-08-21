class Api::V1::KeysController < ApiController
  
  # TODO serializer
  def create
    @key.new(key_params)
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
    @key = Key.find_by(key: params[:key])
    
    if @key
      @key.destroy
      head :no_content
    else
      head :bad_request
    end
  end
  
  # TODO serializer
  def index
    @keys = current_user.keys.active
    
    render status: 200,
           json: @keys,
           meta: { success: true,
                   info: "Keys" }
  end
  
  # TODO figure out the success render + serializer
  def process
    @key = Key.find_by(key: params[:key])
    
    if @key && @key.active?
      @key.process(current_user)
      
      # Figure out what to render
      # render status: 200,
      #        json:
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
