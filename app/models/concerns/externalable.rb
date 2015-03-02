module Externalable
  extend ActiveSupport::Concern
  
  included do
    before_create :generate_external_id!
  end
  
  # IMPORTANT: Test for nil does not mean you explicitly create an external_id. It is for interfacing with outside APIS and using their ID as an internal ID if provided. Example: Using #place_id of a location From GooglePlaces in place of our external_id.
  def generate_external_id!
    if self.external_id.nil?
      loop do
        uuid = SecureRandom.uuid
        break self.external_id = uuid unless self.class.unscoped.where(external_id: uuid).first
      end
    end
  end

end