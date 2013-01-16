module Listable
  class DaemonHelper

    LOOP_INTERVAL = 0.25
    
    def initialize
      @start_mtime = restart_file_mtime
    end
    
    def restartable(&block)
      loop do
        exit unless @start_mtime == restart_file_mtime
      
        yield
      
        sleep LOOP_INTERVAL
      end
    end
    
    private

    # Expands absolute production path so that we catch a new file when symlink changes.  Is there
    # a better way to do this?
    def restart_file
      File.expand_path(File.join('/', %w[ var projects ListableApp production current tmp restart.txt]))
    end
    
    def restart_file_mtime
      File.exist?(restart_file) ? File.mtime(restart_file) : nil
    end
  end
end