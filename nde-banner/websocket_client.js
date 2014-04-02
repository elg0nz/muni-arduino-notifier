require('js-yaml');

var io   = require('socket.io-client')
  , http = require('http')
  , util = require('util');

var serialport = require("serialport")
  , SerialPort = serialport.SerialPort
  , TTYPATH    = '/dev/ttyACM0';

var serialPort = new SerialPort(TTYPATH, {
    baudrate: 9600
});

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

var get_subscriptions = function (update) {
  var channels = JSON.parse(update);
  var filtered_channels = channels.filter(channel_enabled);
  filtered_channels.forEach(process_channel);
};

var display_response = function (channel, chunk) {
  var data = JSON.parse(chunk);
  var msg = data["msg"];
  var source = data["source"];

  var output = util.format('%s: %s', source, msg);
  console.log(output);
  serialPort.write(output + "\r\n");
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

socket.on('disconnect', function () {
  console.log('server disconnected');
  serialPort.close();
  process.exit();
});
