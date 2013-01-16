namespace :reporting do
  
  desc "Update num of new users, lists, items"
  task :run => :environment do
    user_count = User.count(:conditions => [ "created_at > ?", 1.day.ago ])
    Item.find(1243).update_attributes(:name => "Users in last 24 HR: #{user_count}")
    
    list_count = List.count(:conditions => [ "created_at > ?", 1.day.ago ])
    Item.find(1244).update_attributes(:name => "Lists in last 24 HR: #{list_count}")
    
    item_count = Item.count(:conditions => [ "created_at > ?", 1.day.ago ])
    Item.find(1245).update_attributes(:name => "Items in last 24 HR: #{item_count}")
    
    Item.find(1457).update_attributes(:name => "Total users: #{User.count}")
    Item.find(1458).update_attributes(:name => "Total lists: #{List.count}")
    Item.find(1459).update_attributes(:name => "Total items: #{Item.count}")
  end
  
end