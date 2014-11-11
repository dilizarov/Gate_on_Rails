class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :leave], Network do |network|
      user.in_network? network
    end
      
    can [:read, :create], Post do |post|
      user.in_network? post.network_id
    end
    
    can :destroy, Post do |post|
      user.owns_post? post
    end
    
    can :create, Comment do |comment|
      user.in_network? comment.post.network_id
    end
    
    can :destroy, Comment do |comment|
      user.owns_comment? comment
    end
    
    can :create, Key do |key|
      user.in_networks? key.networks
    end
    
    can :destroy, Key do |key|
      user.owns_key? key
    end   
  end
end
