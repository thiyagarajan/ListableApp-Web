module Listable
  
  # Establishes a connection with the correct params to the Apple Push Notification
  # Service.
  class ApnConnection
    
    def initialize(conn_type)
      raise ArgumentError, "Type #{type} is invalid" unless [:feedback, :gateway].include?(conn_type)
      
      @host         = APN_CONFIG['host'][conn_type.to_s]
      @certificate  = File.join(RAILS_ROOT, 'config', APN_CONFIG['certificate'])
      @passphrase   = APN_CONFIG['passphrase']
      @port         = APN_CONFIG['port'][conn_type.to_s]
      
      puts "#{DateTime.now}: Opening #{type} to #{@host}:#{@port}"
    end
    
    def open(&block)
      cert      = File.read(@certificate)
      ctx       = OpenSSL::SSL::SSLContext.new
      ctx.key   = OpenSSL::PKey::RSA.new(cert, @passphrase)
      ctx.cert  = OpenSSL::X509::Certificate.new(cert)

      sock      = TCPSocket.new(@host, @port)
      ssl       = OpenSSL::SSL::SSLSocket.new(sock, ctx)
      ssl.sync  = true
      
      ssl.connect

      yield ssl, sock if block_given?

      ssl.close
      sock.close
    end      
    
  end
end