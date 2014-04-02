var io   = require('socket.io-client')
  , http = require('http')
  , util = require('util')
  , host = 'http://localhost:8080';

var get_subscriptions = function (channels){
  channels.forEach(process_channel);
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
