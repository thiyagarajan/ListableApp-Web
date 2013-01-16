namespace :blips do
  
  desc "Starts daemon blip expansion process in production"
  task :start_expander do
    sh "daemon -d3 -r -n blip_expander -F /tmp/blip_expander.pid -o /mnt/logs/blip_expansion.log -- rake -f /var/projects/ListableApp/production/current/Rakefile blips:expand --trace"
  end
    
  desc "Expand any new blips in the queue"
  task :expand => :environment do
    Listable::DaemonHelper.new.restartable do
      # Just bail and we'll be restarted if there has been a deploy by daemon(1)
      # on servers.  Keeps us in line with passenger.
      
      if elt = QUEUE.get(NEW_BLIP_QUEUE)
        b = Blip.find(elt)
        b.expand_to_concerned_users
        puts "#{DateTime.now}: Expanded blip id #{b.id}"
      end
      
    end
  end
end