class Comment < ActiveRecord::Base
  include Externalable
  
  acts_as_votable
  
  attr_accessor :uped

  validates :user_id,     presence: true
  validates :post_id,     presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  # after_create  :add_to_feed
#   after_destroy :remove_from_feed
  
  belongs_to :user
  belongs_to :post, counter_cache: true
  
  #Commented out for same reasons as listed in gate.rb
  
  # def add_to_feed
#     parsed_post = get_parsed_post
#     return if parsed_post.nil?
#
#     parsed_post["post"]["comments"].push(serialized_comment)
#     REDIS.hset(feed_gate_key, self.post_id, parsed_post.to_json)
#   end
#
#   def remove_from_feed
#     parsed_post = get_parsed_post
#     return if parsed_post.nil?
#
#     comments = parsed_post["post"]["comments"]
#     parsed_post["post"]["comments"] = comments.delete_if do |comment|
#       comment["comment"]["external_id"] == self.external_id
#     end
#
#     REDIS.hset(feed_gate_key, self.post_id, parsed_post.to_json)
#   end
#
#   def serialized_comment(options = {})
#     serialization = CommentSerializer.new(self)
#     options[:jsonified] ? serialization.to_json : serialization
#   end
#
#   def get_parsed_post
#     feed_post = REDIS.hget(feed_gate_key, self.post_id)
#
#     feed_post.present? ? JSON.parse(feed_post) : nil
#   end
#
#   def feed_gate_key
#     post.feed_gate_key
#   end
end