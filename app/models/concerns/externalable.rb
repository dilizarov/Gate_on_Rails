module Externalable
  extend ActiveSupport::Concern
  
  included do
    before_save :generate_external_id!
  end
  
  def generate_external_id!
    loop do
      uuid = SecureRandom.uuid
      break self.external_id = uuid unless self.class.unscoped.where(external_id: uuid).first
    end
  end
end