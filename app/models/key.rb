class Key < ActiveRecord::Base
  
  EXPIRATION_MARK = 3.days.ago
  
  scope :expired, -> { where('updated_at < ?', EXPIRATION_MARK) }
  scope :active,  -> { where('updated_at >= ?', EXPIRATION_MARK) }
  
  # This is not confusing at all. :)
  attr_encryptor :key,      key: ENV['KEY_KEY']
  attr_encryptor :networks, key: ENV['NETWORKS_KEY'], marshal: true

  before_save :generate_key!

  validates :gatekeeper_id, presence: true
  validates :networks,      presence: true
                              
  belongs_to :gatekeeper,
             class_name: "User",
             foreign_id: :gatekeeper_id          
  
  def expired?
    self.updated_at < EXPIRATION_MARK
  end
  
  def active?
    !expired?
  end
  
  def generate_key!
    # key is a random 16 digit number
    loop do
      key = rand(1_000_000_000_000_000...10_000_000_000_000_000)
      break self.key = key unless Key.find_by(key: key)
    end
  end
  
  def process(current_user)
    
    # Filter out networks that current_user is already part of.
    networks_to_be_added = self.networks - current_user.networks.map(&:id)
    
    user_networks = networks_to_be_added.map do |network_id| 
                      UserNetwork.new(user_id:       current_user.id,
                                      network_id:    network_id,
                                      gatekeeper_id: self.gatekeeper_id)
                    end
        
    # I don't imagine many, if any, keys that will have very large amounts of
    # networks. Hence, the array isn't very large. Because of this, we don't
    # need the efficiency (potentially 70x+ faster) of a raw INSERT INTO sql
    # query. If we find the need or want to do so, we could go forth and do
    # that. As it stands, I don't think we need it, and this import should
    # suffice. - David
    
    UserNetwork.import(user_networks)
    
    key.touch
    
    new_networks = Network.where(id: networks_to_be_added).to_a
    
    return new_networks
  end             
  
end
