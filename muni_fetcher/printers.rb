require 'redis'
require 'json'

module Printer
    def print_hash(predict_hash)
        predict_hash.keys.each do |key|
            first, second = predict_hash[key][0..1]
            print "R#{key} in #{first} and #{second}"
        end
    end

    def print_time(time_str)
        print time_str
    end
end

class StdoutPrinter
    include Printer
    def initialize

    end
    def print(msg)
        puts msg
    end
end

class RedisPrinter
    include Printer
    def initialize(options)
        @redis = Redis.new(options)
        @lset_name = options[:lset_name]
        @redis.del @lset_name
    end
    def print(msg)
        color = ['steel', 'darko', 'scorcho', 'fuzz', 'oxide', 'rust'].sample
        json_thing = {'info'=> msg, 'color' => color}
        @redis.lpush(@lset_name, JSON.dump(json_thing))
        @redis.publish('statuses', 'ok')
    end
end

class SocketPrinter
    include Printer
    def initialize(socketPath)
        begin
          self.socket = UNIXSocket.new(socketPath)
        rescue IOError => e
          puts "Could not open socket: #{e}"
        end
    end
    def print(msg)
        begin
          self.socket.send("#{msg}\r\n", 0)
        rescue IOError => e
          puts "Could not write to socket: #{e}"
        end
    end
end
