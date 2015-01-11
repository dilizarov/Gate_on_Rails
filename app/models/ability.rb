class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :leave], Gate do |gate|
      user.in_gate? gate
    end
      
    can [:read, :create, :up], Post do |post|
      user.in_gate? post.gate_id
    end
    
    can :destroy, Post do |post|
      user.owns_post? post
    end
    
    can [:create, :up], Comment do |comment|
      user.in_gate? comment.post.gate_id
    end
    
    can :destroy, Comment do |comment|
      user.owns_comment? comment
    end
    
    can :create, Key do |key|
      user.in_gates? key.gates
    end
    
    can :destroy, Key do |key|
      user.owns_key? key
    end   
  end
end
