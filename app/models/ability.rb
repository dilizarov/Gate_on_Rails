class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :leave, :unlock], Gate do |gate|
      user.in_gate?(gate) || gate.id == AROUND_YOU_GATE_ID
    end
      
    can [:read, :create, :up], Post do |post|
      user.in_gate?(post.gate_id) || post.gate_id == AROUND_YOU_GATE_ID
    end
    
    can :destroy, Post do |post|
      user.owns_post? post
    end
    
    can [:create, :up], Comment do |comment|
      gate_id = comment.post.gate_id
      
      user.in_gate?(gate_id) || gate_id == AROUND_YOU_GATE_ID 
    end
    
    can :destroy, Comment do |comment|
      user.owns_comment? comment
    end
    
    can :create, Key do |key|
      gates = Gate.where(external_id: key.gates)
      user.in_gates? gates
    end
    
    can :destroy, Key do |key|
      user.owns_key? key
    end   
  end
end
