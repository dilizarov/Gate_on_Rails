10.times do |i|
  user = User.create(email: Faker::Internet.email, name: Faker::Name.name, password: 'thepassword')
end

20.times do |i|
  gate = Gate.create(name: Faker::App.name, creator_id: rand(1...15))
  10.times do |j|
    post = Post.create(body: Faker::Hacker.say_something_smart, user_id: rand(1...15), gate_id: gate.id)
    10.times do |k|
      comment = Comment.create(body: Faker::Hacker.say_something_smart, user_id: rand(1...15), post_id: post.id)
    end
  end
end
