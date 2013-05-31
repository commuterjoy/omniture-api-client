
require 'rubygems'
require 'digest/sha1'
require 'base64'
require 'json'
require 'etc'
require 'erb'
require 'httparty'
require 'util/fixnum'

class Omniture
   
    attr_accessor :username, :password, :nonce, :nonce_base64, :created, :pd, :auth, :api
    
    def get_credentials
       if (ENV['OMNITURE_USER'])
            { "username" => ENV['OMNITURE_USER'], "secret" => ENV['OMNITURE_SECRET'] } 
       else
            JSON.parse(IO.read("#{Etc.getpwuid.dir}/.omniture"))
       end
    end
    
    def initialize()
        credentials = self.get_credentials 
        @username      = credentials['user']
        @password      = credentials['secret']
        @nonce         = Array.new(10){ rand(0x100000000) }.pack('I*')
        @nonce_base64  = [nonce].pack("m").chomp
        @created       = Time.now.utc.iso8601
        @pd            = [Digest::SHA1.digest(nonce + created + password)].pack("m").chomp
        @auth          = 'UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"' % [username, pd, nonce_base64, created]
        @api           = 'https://api.omniture.com/admin/1.3/rest/'
    end

    def get(method)
        response = HTTParty.get(@api, :query => { "method" => method }, :headers => {"Content-Type" => 'application/json', "X-WSSE" => @auth })
        response.body
    end
    
    def post(method, body)
        response = HTTParty.post(@api, :body => body, :query => { "method" => method }, :headers => {"Content-Type" => 'application/json', "X-WSSE" => @auth })
        response.body
    end
    
end

class Report < Omniture

    def queueQueueOvertime(opts)
        @opts = opts
        template = ERB.new File.new("templates/metrics").read, nil, "%"
        body = template.result(binding)
        self.post('Report.QueueOvertime', body)
    end

    def queueTrended(opts)
        @opts = opts
        template = ERB.new File.new("templates/trended").read, nil, "%"
        body = template.result(binding)
        self.post('Report.QueueTrended', body)
    end

    def getReportQueue
        self.get('Report.GetReportQueue')
    end

    def getReport(id)
        body = '{ "reportID" : "%s" }' % [id]
        self.post('Report.GetReport', body)
    end

end




