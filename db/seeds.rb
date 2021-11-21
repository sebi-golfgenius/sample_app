# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create a main sample user
User.create!(name: "Example User",
            email: "example@railstutorial.org",
            password: "111111",
            password_confirmation: '111111',
            admin: true,
            activated: true,
            activated_at: Time.zone.now)

User.create!(name: "Sebi",
            email: "s@t.c",
            password: "111111",
            password_confirmation: '111111',
            admin: true,
            activated: true,
            activated_at: Time.zone.now)

# Generate a bunch of users
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "111111"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              activated: true,
              activated_at: Time.zone.now)
end

# Generate microposts for a subset of users
users = User.order(:created_at).take(6)
50.times do
  content = Faker::ChuckNorris.fact
  if content.length > 140
    content = content[0..139]
  users.each { |user| user.microposts.create!(content: content) }
end
