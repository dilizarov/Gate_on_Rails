class Key < ActiveRecord::Base
  include Externalable

  # This is not confusing at all. :)
  attr_encryptor :key,      key: ENV['KEY_KEY']
  attr_encryptor :networks, key: ENV['NETWORKS_KEY'], marshal: true

  validates :gatekeeper_id, presence: true
  validates :networks,      presence: true
  validates :key,           presence: true,
                            uniqueness: true
                            
  def generate_key!
    # key is a random 16 digit number
    loop do
      key = rand(1_000_000_000_000_000...10_000_000_000_000_000)
      break self.key = key unless Key.find_by(key: key)
    end
  end
  
end
