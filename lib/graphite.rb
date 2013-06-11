require 'socket'

class Graphite
    
    attr_accessor :key

    def initialize(opts)
        @host = opts[:host]
        @port = opts[:port] || 2003
        @verbose = opts[:verbose] || false
    end
        
    def log(opts)
        
        conn = TCPSocket.new @host, @port
        conn.puts "#{@api_key}.#{opts[:path]} #{opts[:value]}\n"
        conn.close

        puts "#{@host} #{@port} - #{opts[:path]} #{opts[:value]}\n" if @verbose

    end


end



