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
    routes.each do |route, direction|
        hash_title = "#{route.title}-#{direction}"
        predict_hash[hash_title] = get_predictions(route, stop, direction)
    end
    return predict_hash
end

def get_predictions(route, stop, direction)
    if direction == 'inbound'
        predictions = route.inbound.stop_at(stop).predictions.map(&:minutes)
    else
        predictions = route.outbound.stop_at(stop).predictions.map(&:minutes)
    end
    return predictions
end

def display_info(predict_hash, printer)
    t = Time.now
    time_str = t.strftime("The time is: %H:%M")
    printer.print_time(time_str)
    printer.print_hash(predict_hash)
end

def find_routes(routes_array)
    routes = routes_array.reduce([]) do |r_array, route_hash|
        route = Muni::Route.find(route_hash['route'])
        direction = route_hash['direction']
        r_array << [route, direction]
    end
    return routes
end

EventMachine.run do
    prediction_data = {}
    routes = find_routes conf['routes']
    redis_conf = conf['redis']
    printer = RedisPrinter.new(:host => redis_conf['host'], :port => redis_conf['port'], :password => redis_conf['password'])
    # First run
    prediction_data = fetch_data(routes, conf['my_stop'])
    display_info(prediction_data, printer)

    # Set timers
    EventMachine.add_periodic_timer(conf['display_refresh_rate'], Proc.new { display_info(prediction_data, printer) })
    EventMachine.add_periodic_timer(conf['fetch_rate'], Proc.new { prediction_data = fetch_data(routes, conf['my_stop']) })
end
