require 'rubygems' # or use Bundler.setup
require 'eventmachine'
require 'muni'
require 'psych'
require_relative 'muni_fetcher/printers'

begin
    conf = Psych.load_file('muni_fetcher.yml')
rescue Errno::ENOENT
    puts 'yml configuration not found'
end

def fetch_data(routes, stop)
    predict_hash = {}
    routes.each do |route|
        predict_hash[route.title] = route.inbound.stop_at(stop).predictions.map(&:minutes)
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
    routes = routes_array.reduce([]) do |r_array, route|
        r_array << Muni::Route.find(route)
    end
    return routes
end

EventMachine.run do
    prediction_data = {}
    routes = find_routes [47, 45]
    np = ENV['rdebug']? StdoutPrinter.new : SocketPrinter.new(conf['socket_path'])
    # First run
    prediction_data = fetch_data(routes, conf['my_stop'])
    display_info(prediction_data, np)

    # Set timers
    EventMachine.add_periodic_timer(conf['display_refresh_rate'], Proc.new { display_info(prediction_data, np) })
    EventMachine.add_periodic_timer(conf['fetch_rate'], Proc.new { prediction_data = fetch_data(routes, conf['my_stop']) })
end
