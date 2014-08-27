class Ability
  include CanCan::Ability

  def initialize(user)
    # Must be in network to create post
    # Must be in network to create comment
    # Must be in network to retrieve feed
    # Must be in networks to create key for those networks
    # Must own post to delete post
    # Must own comment to delete comment
    
    #SCHEME; TODO: Test. Ideally, they would look like this.
    
    #should be fine when made.
    can :show, Network do |network|
      user.in_network? network
    end
    
    can :create, Post do |post|
      user.in_network? post.network_id
    end
    
    #woot!
    can :destroy, Post do |post|
      user.owns_post? post
    end
    
    can :create, Comment do |comment|
      user.in_network? comment.post.network_id
    end
    
    #woot!
    can :destroy, Comment do |comment|
      user.owns_comment? comment
    end
    
    #woot!
    can :create, Key do |key|
      user.in_networks? key.networks
    end
    
    #woot!
    can :destroy, Key do |key|
      user.owns_key? key
    end   
  end
end
