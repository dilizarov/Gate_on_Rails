class Key < ActiveRecord::Base
  
  EXPIRATION_MARK = 3.days.ago
  
  scope :expired, -> { where('updated_at < ?', EXPIRATION_MARK) }
  scope :active,  -> { where('updated_at >= ?', EXPIRATION_MARK) }
  
  # This is not confusing at all. :)
  attr_encrypted :key,    key: ENV['KEY_KEY']
  attr_encrypted :gates,  key: ENV['GATES_KEY'], marshal: true

  before_create :swap_gate_external_ids_for_gate_ids!
  before_create :generate_key!

  validates :gatekeeper_id, presence: true
  
  belongs_to :gatekeeper,
             class_name: "User",
             foreign_key: :gatekeeper_id          
  
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
      break self.key = key unless Key.find_by_key(key)
    end
  end
  
  def swap_gate_external_ids_for_gate_ids!
    # Assume we're dealing with ids, not external_ids if the first element is an Integer
    return if Integer === self.gates.first
    
    gate_external_ids = self.gates
    gate_ids = Gate.where(external_id: gate_external_ids).to_a.map(&:id)
    self.gates = gate_ids
  end
  
  def process(current_user)
    
    # Filter out gates that current_user is already part of.
    gates_to_be_added = self.gates - current_user.gates.map(&:id)
    
    user_gates = gates_to_be_added.map do |gate_id| 
                      # Not a N + 1 query problem ;).
                      UserGate.new(user_id:       current_user.id,
                                   gate_id:       gate_id,
                                   gatekeeper_id: self.gatekeeper_id)
                    end
        
    # I don't imagine many, if any, keys that will have very large amounts of
    # gates. Hence, the array isn't very large. Because of this, we don't
    # need the efficiency (potentially 70x+ faster) of a raw INSERT INTO sql
    # query. If we find the need or want to do so, we could go forth and do
    # that. As it stands, I don't think we need it, and this import should
    # suffice.
    
    UserGate.import(user_gates)
    
    self.touch
    
    new_gates = Gate.where(id: gates_to_be_added).to_a
  end             
  
end
