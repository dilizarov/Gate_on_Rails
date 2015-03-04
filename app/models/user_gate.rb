class UserGate < ActiveRecord::Base
  
  validates :user_id, uniqueness: { scope: :gate_id }
  
  belongs_to :gate,    inverse_of: :user_gates
  belongs_to :user,    inverse_of: :user_gates
  
  before_destroy :destroy_keys_associated_with_user_and_gate!, :destroy_gate_if_last_user_and_not_generated!
  
  private
  
  def destroy_keys_associated_with_user_and_gate!
    UserGate.transaction do
      keys = Key.where(gatekeeper_id: self.user_id).to_a
      keys.select! { |key| key.gates.include?(self.gate_id) }
      Key.delete(keys)
    end
  end
  
  def destroy_gate_if_last_user_and_not_generated!
    gate = self.gate
    
    if !gate.generated && gate.users.count == 1
      self.gate.destroy
    end
  end
end
