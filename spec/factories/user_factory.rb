Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.sequence :login do |n|
  "person#{n}"
end

Factory.define :user do |u|
  u.email { Factory.next(:email) }
  u.login { Factory.next(:login) }
  u.password 'testtesttest'
  u.password_confirmation 'testtesttest'
  u.confirmed true
end
