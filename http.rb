#!/usr/bin/ruby 

class OmnitureServer < Sinatra::Base

    before do
        content_type 'application/json'
    end

    get '/test' do
        "{[]}"
    end

    get '/report/:id' do
        Report.new().getReport(params[:id])
    end

    get '/queue' do
        Report.new().getReportQueue()
    end

    get '/e37' do

        yesterday = (Date.today-1).strftime('%Y-%m-%d') 
        four_week_ago = (Date.today-29).strftime('%Y-%m-%d') 

        opts = {
             :from => four_week_ago,
             :to => yesterday,
             :segment => "",
             :metric => "event37",
             :element_id => "evar37",
             :evars => params[:datalink].split(",")
           }
        
         Report.new().queueTrended(opts)

    end

end
