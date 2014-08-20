class Key < ActiveRecord::Base

  # This is not confusing at all. :)
  attr_encryptor :key,      key: ENV['KEY_KEY']
  attr_encryptor :networks, key: ENV['NETWORKS_KEY'], marshal: true

  validates :gatekeeper_id, presence: true
  validates :networks,      presence: true
  validates :key,           presence: true
                            uniqueness: true
  
end
