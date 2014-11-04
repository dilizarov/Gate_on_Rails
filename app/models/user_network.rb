class UserNetwork < ActiveRecord::Base
  belongs_to :network
  belongs_to :user
  
  before_destroy :destroy_keys_associated_with_user_and_network
    
  private
  
  def destroy_keys_associated_with_user_and_network
    UserNetwork.transaction do
      keys = Key.where(gatekeeper_id: self.user_id).to_a
      keys.select! { |key| key.networks.include?(self.network_id) }
      Key.delete(keys)
    end
  end
end
