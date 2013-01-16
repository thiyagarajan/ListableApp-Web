Factory.define :user_list_link do |ull|
  ull.association :user
  ull.watching true
  ull.association :list
end
