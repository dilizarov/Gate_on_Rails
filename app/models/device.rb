class Device < ActiveRecord::Base
  belongs_to :user
  
  validates :token, presence: true
  # Don't yet have an ios app. :'(
  validates :platform, presence: true, inclusion: { in: %w(ios android), case_sensitive: false }
  
  scope :platform_is, -> (device_platform) { where(platform: device_platform.to_s.downcase) }
  
  before_validation :format_attributes_for_persist!
  
  def platform_is?(device_platform)
    device_platform.to_s.downcase == platform.downcase
  end
  
  def format_attributes_for_persist!
    platform.downcase! if attribute_present?("platform")
  end
end
