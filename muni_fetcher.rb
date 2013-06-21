require 'muni'

MY_STOP = "hayes and shrader"
FILE_PATH = "./bustime.txt"
SOCKET_PATH = "/tmp/arduino.sock"

def append_stops_to_file(busTimes, filePath=FILE_PATH)
    begin
      file = File.open(filePath, "a")
      busTimes.each { |bst| file.write("#{bst}\n")}
    rescue IOError => e
      puts "Could not write to file: #{e}"
    ensure
      file.close unless file == nil
    end
end

def append_time_to_socket(hour, min, socketPath = SOCKET_PATH)
    begin
      socket = UNIXSocket.new(socketPath)
      socket.send("The time is: #{hour}:#{min}.\r\n", 0)
    rescue IOError => e
      puts "Could not write to socket: #{e}"
    end
end

def append_stops_to_socket(busTimes, socketPath = SOCKET_PATH)
    begin
      socket = UNIXSocket.new(socketPath)
      busTimes.each { |bst| socket.send("#{bst}\r\n", 0)}
    rescue IOError => e
      puts "Could not write to socket: #{e}"
    end
end

puts "Finding route."
r47 = Muni::Route.find(47)
puts "Route found, Ready."

while true
    next_stops = []
    r47.inbound.stop_at(MY_STOP).predictions.map(&:minutes).each do |min|
        next_stops << "R47 in: #{min} min "
    end
    t = Time.now
    append_time_to_socket(t.hour, t.min)
    append_stops_to_socket(next_stops)
    t = Time.now
    append_time_to_socket(t.hour, t.min)
    sleep(60)
end

