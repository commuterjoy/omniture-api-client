
require 'rubygems'
require 'digest/sha1'
require 'base64'
require 'json'
require 'etc'
require 'erb'

class Omniture
   
    attr_accessor :username, :password, :nonce, :nonce_base64, :created, :pd, :auth, :curl, :api
    
    def get_credentials
       JSON.parse(IO.read("#{Etc.getpwuid.dir}/.omniture"))
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
        @api           = '"https://api.omniture.com/admin/1.3/rest/?method=%s"'
    end

end

class Report < Omniture

    def queueTrended(to, from)
        @to = to
        @from = from 
        method = 'Report.QueueTrended'
        template = ERB.new File.new("templates/trended").read, nil, "%"
        t = template.result(binding)
        "curl -sH 'Content-Type: application/json' -H 'X-WSSE: %s' -d '%s' %s" % [@auth, t, (@api % [method])]
    end

    def getReportQueue
        method = 'Report.GetReportQueue'
        "curl -sH 'Content-Type: application/json' -H 'X-WSSE: %s' %s" % [@auth, (@api % [method])]
    end

    def getReport(id)
        method = 'Report.GetReport'
        "curl -sH 'Content-Type: application/json' -H 'X-WSSE: %s' -d '{\"reportID\":\"%s\"}' %s" % [@auth, id, (@api % [method])]
    end

end







