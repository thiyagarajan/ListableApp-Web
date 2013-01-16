namespace :notifications do

  desc "Starts daemon notifier process in production"
  task :start_notifier do
    sh "daemon -d3 -r -n notifier -F /tmp/notifier.pid -o /mnt/logs/notifier.log -- rake -f /var/projects/ListableApp/production/current/Rakefile notifications:send --trace"
  end
  
  desc "Expand any new notifications in the queue"
  task :send => :environment do
    
    Listable::DaemonHelper.new.restartable do      
      Listable::Apn.send_notifications
    end
  end
  
  desc "Remove dead devices"
  task :process_feedback => :environment do
    puts "#{DateTime.now}: Checking for dead devices"
    Listable::ApnFeedback.process_devices
  end
end