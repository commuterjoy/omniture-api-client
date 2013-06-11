require 'socket'


class Graphite
    
    attr_accessor :key

    def initialize(opts)
        @api_key = opts[:api_key] 
        @host = opts[:host]
        @port = opts[:port] || 2003
    end
        
    def log(opts)
        time = Time.now.to_i
        conn = TCPSocket.new @host, @port
        conn.puts "#{@api_key}.#{opts[:path]} #{opts[:value]}\n"
        conn.close

        puts "#{@host} #{@port} #{@api_key}.#{opts[:path]} #{opts[:value]}\n"

    end


end



