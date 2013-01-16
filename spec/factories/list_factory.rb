Factory.define :list do |l|
  l.name 'Test List'
  l.association :creator, :factory => :user
end
