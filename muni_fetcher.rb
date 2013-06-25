require 'rubygems' # or use Bundler.setup
require 'eventmachine'
require 'muni'
require_relative 'printers'

MY_STOP = "hayes and shrader"
FILE_PATH = "./bustime.txt"
SOCKET_PATH = "/tmp/arduino.sock"
MINUTES = 60
DISPLAY_REFRESH_RATE = MINUTES / 2
FETCH_RATE = 1 * MINUTES

def fetch_data(routes, stop)
    predict_hash = {}
    routes.each do |route|
        predict_hash[route.title] = route.inbound.stop_at(MY_STOP).predictions.map(&:minutes)
    end
    return predict_hash
end

def display_info(predict_hash, printer)
    t = Time.now
    time_str = t.strftime("The time is: %H:%M")
    printer.print_time(time_str)
    printer.print_hash(predict_hash)
end

def find_routes(routes_array)
    routes = []
    routes_array.each { |route| routes << Muni::Route.find(route)}
    return routes
end

EventMachine.run do
    prediction_data = {}
    routes = find_routes [47, 45]
    np = ENV['rdebug']? StdoutPrinter.new : SocketPrinter.new(SOCKET_PATH)
    # First run
    prediction_data = fetch_data(routes, MY_STOP)
    display_info(prediction_data, np)

    # Set timers
    EventMachine.add_periodic_timer(DISPLAY_REFRESH_RATE, Proc.new { display_info(prediction_data, np) })
    EventMachine.add_periodic_timer(FETCH_RATE, Proc.new { prediction_data = fetch_data(routes, MY_STOP) })
end
