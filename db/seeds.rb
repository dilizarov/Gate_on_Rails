10.times do |i|
  user = User.create(email: Faker::Internet.email, name: Faker::Name.name, password: 'thepassword')
end

20.times do |i|
  network = Network.create(name: Faker::App.name, creator_id: rand(1...15))
  10.times do |j|
    post = Post.create(body: Faker::Hacker.say_something_smart, user_id: rand(1...15), network_id: network.id)
    10.times do |k|
      comment = Comment.create(body: Faker::Hacker.say_something_smart, user_id: rand(1...15), post_id: post.id)
    end
  end
end
