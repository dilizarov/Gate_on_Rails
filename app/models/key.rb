class Key < ActiveRecord::Base
  
  EXPIRATION_MARK = 3.days.ago
  
  scope :expired, -> { where('updated_at < ?', EXPIRATION_MARK) }
  scope :active,  -> { where('updated_at >= ?', EXPIRATION_MARK) }
  
  # This is not confusing at all. :)
  attr_encryptor :key,      key: ENV['KEY_KEY']
  attr_encryptor :networks, key: ENV['NETWORKS_KEY'], marshal: true

  validates :gatekeeper_id, presence: true
  validates :networks,      presence: true
  validates :key,           presence: true,
                            uniqueness: true
                            
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
  
  #TODO: Figure out what to return to show current_user.
  def process(current_user)
    
    user_networks = self.networks.map do |network_id| 
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

  end             
  
end
