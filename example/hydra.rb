require 'typhoeus'
require 'net/http'
require 'open-uri'
require "benchmark"

@hydra = Typhoeus::Hydra.new(max_concurrency: 3) 

# require_relative 'localhost_server.rb'
# require_relative 'server.rb'
# URL = "http://localhost:300"
# LocalhostServer.new(TESTSERVER.new, 3000)
# LocalhostServer.new(TESTSERVER.new, 3001)
# LocalhostServer.new(TESTSERVER.new, 3002)

# hydra = Typhoeus::Hydra.new(max_concurrency: 3)

patents = %w[5551212 6661212 7771212 7123456 8012345 7136291] # !> assigned but unused variable - patents
PTO_SEARCH_URL = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

def url_for(index)
  patent = 7123456 + index % 5
  pnum = patent.to_s
  url = PTO_SEARCH_URL + pnum + ".PN.&OS=PN/" + pnum + "&RS=PN/" + pnum # !> assigned but unused variable - url
end

@results = []
@retry = []

class Client
  def perfom(count) # !> instance variable @on_body not initialized
      @results = []
      @retry   = []

      count.times {
        |i|
        req = Typhoeus::Request.new( url_for(patent) )
        req.on_complete {
          |res|
          #puts 'URL:     ' + res.effective_url
          # puts 'Time:    ' + res.time.to_s
          # puts 'Connect time: ' + res.connect_time.to_s
          # puts 'App connect time:    ' + res.app_connect_time.to_s
          # puts 'Start transfer time: ' + res.start_transfer_time.to_s
          # puts 'Pre transfer time:   ' + res.pretransfer_time.to_s
          # puts '-------------'
          # parse out the Abstract
          if res.success?
              @results << res.body[/<font size=\"\+1\">(.*?)<\/font>/mi]
          elsif res.timed_out?
              @retry << patent
          elsif res.code == 0
              #something is fucked up
          else
              puts 'HTTP Request failed: ' + res.code.to_s
          end
        } 

        hydra.queue( req )
        puts 'Queued: ' + req.url
      }
  end
  def run
    puts
    puts 'Harvesting responses...'
    puts

    hydra.run

    puts
    puts 'Done.'
    puts

    @results.each_with_index{|x,i| p "#{i}) => #{x}" }

    puts "Need to retry: #{@retry.size} patents"
    @retry.each_with_index{|x,i| p "#{i}) => #{x}" }
  end
end

def benchmark
  Benchmark.bm do |bm|
    
    [15].each do |calls|
      puts "[ #{calls} requests ]"


      bm.report("open            ") do
        calls.times do |i|
          open(url_for(i))
        end
      end

      bm.report("request         ") do
        calls.times do |i|
          Typhoeus::Request.get(url_for(i))
        end
      end

      bm.report("hydra           ") do
        calls.times do |i|
          @hydra.queue(Typhoeus::Request.new(url_for(i)))
        end
        @hydra.run
      end

      bm.report("hydra memoize   ") do
        Typhoeus::Config.memoize = true
        calls.times do |i|
          @hydra.queue(Typhoeus::Request.new(url_for(i)))
        end
        @hydra.run
        Typhoeus::Config.memoize = false
      end
    end
  end
end
 
 benchmark
# >>        user     system      total        real
# >> [ 15 requests ]
# >> open              0.030000   0.030000   0.060000 ( 11.249879)
# >> request           0.010000   0.030000   0.040000 ( 11.251260)
# >> hydra             0.030000   0.020000   0.050000 (  4.673612)
# >> hydra memoize     0.010000   0.010000   0.020000 (  2.406661)