
require 'rubygems'
require 'digest/sha1'
require 'base64'
require 'json'
require 'etc'
require 'erb'
require 'httparty'
require 'date'
require 'time'

class Omniture
   
    attr_accessor :username, :password, :nonce, :nonce_base64, :created, :pd, :auth, :api
    
    def get_credentials
       if (ENV['OMNITURE_USER'])
            { "user" => ENV['OMNITURE_USER'].chomp, "secret" => ENV['OMNITURE_SECRET'].chomp } 
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

    def default_options 
        { :granularity => 'day' }
    end

    def generateResponse(template, opts)
        @opts = self.default_options().merge(opts)
        template = ERB.new File.new("templates/" + template).read, nil, "%"
        template.result(binding)
    end

    def queueQueueOvertime(opts)
        self.post('Report.QueueOvertime', generateResponse('metrics', opts))
    end

    def queueTrended(opts)
        self.post('Report.QueueTrended', generateResponse('trended', opts))
    end

    def getReportQueue
        self.get('Report.GetReportQueue')
    end

    def getReport(id)
        body = '{ "reportID" : "%s" }' % [id]
        self.post('Report.GetReport', body)
    end

    # attempts to serialise a report to something the ganglia agent can read
    def t_ganglia(id)
        
        report = JSON.parse(self.getReport(id))
        
        metrics = report['report']['metrics'].map{ |metric| {
                :id => metric['id'],
                :name => metric['name']
            }}
 
        kpis = report['report']['data'].map { |kpi|
           
            metrics.each_with_index.map { |metric, i|
                {
                    "group" => "frontend-omniture-kpis",
                    "name" => [metric[:id], kpi["name"].gsub(/ /, '_')].join("_"),
                    "type" => "counter",
                    "title" => kpi["name"],
                    "count" => kpi["counts"][i]
                } 
           } 
        }.flatten
 
        { "application" => "frontend", "time" => (Time.now.to_f * 1000.0).to_i, "metrics" => kpis }
        
    end

end




