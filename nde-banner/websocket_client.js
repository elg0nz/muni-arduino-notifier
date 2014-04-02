require('js-yaml');

var io   = require('socket.io-client')
  , http = require('http')
  , util = require('util');

try {
  var config           = require('./config.yml')
    , host             = config['host']
    , enabled_channels = config['enabled_channels'];
} catch(e) {
  console.log('Problem loading yml:' + e);
}

var channel_enabled = function (channel) {
  var index = enabled_channels.indexOf(channel);
  if(index > -1) {
    return true;
  } else {
    return false;
  }
};

var get_subscriptions = function (channels) {
  var filtered_channels = channels.filter(channel_enabled);
  filtered_channels.forEach(process_channel);
};

var display_response = function (channel, chunk) {
  var data = JSON.parse(chunk);
  var msg = data["msg"];
  var channel = data["channel"];

  var output = util.format('%s: %s', channel, msg);
  console.log(output);
};

var process_channel = function (channel) {
  var channel_path = util.format('%s/%s', host, channel);
  http.get(channel_path, function (res) {
    res.on('data', function (chunk) {
        display_response(channel, chunk);
    });
  }).on('error', function (e) {
    console.log("Got error: " + e.message);
  });
};

var socket = io.connect(host);
socket.on('connect', function () {
  console.log("socket connected");
  socket.on('channels-updated', get_subscriptions);
});
