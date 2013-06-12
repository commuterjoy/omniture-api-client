
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
        puts @opts.inspect
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

    # extracts the 'latest' measurements from Omniture, as defined by the _n_ hours argument
    def to_ganglia(id, hours)
        
        report = JSON.parse(self.getReport(id))
        
        metrics = report['report']['metrics'].map{ |metric| {
                :id => metric['id'],
                :name => metric['name']
            }}
 
        kpis = report['report']['data'].map { |kpi|

                # overtime metrics
                if kpi['breakdown']

                    {
                        :title => kpi["name"],
                        :breakdown => kpi["breakdown"].map { |d|
                            {
                                :value => d['counts'].first,  # FIXME doesn't work with multiple metrics
                                :time => Time.utc(d['year'], d['month'], d['day'], d['hour']) 
                            }
                        }.select { |d|
                            (Time.now - (60 * 60 * hours) > d[:time])
                        }.last
                    }

                # kpis
                else
                   
                   metrics.each_with_index.map { |metric, i|
                        {
                            :title => metric[:name],
                            :breakdown => {
                                :value => kpi['counts'][i],
                                :time => Time.utc(kpi['year'], kpi['month'], kpi['day'], kpi['hour'])
                            }
                        }
                   }.select { |d|
                        (Time.now - (60 * 60 * hours) > d[:breakdown][:time])
                   }

                end
        }.flatten

        { "metrics" => kpis }
        
    end

end




