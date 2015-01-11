class UserGate < ActiveRecord::Base
  belongs_to :gate,    inverse_of: :user_gates
  belongs_to :user,    inverse_of: :user_gates
  
  before_destroy :destroy_keys_associated_with_user_and_gate!
    
  private
  
  def destroy_keys_associated_with_user_and_gate!
    UserGate.transaction do
      keys = Key.where(gatekeeper_id: self.user_id).to_a
      keys.select! { |key| key.gates.include?(self.gate_id) }
      Key.delete(keys)
    end
  end
end
