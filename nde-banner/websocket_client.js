var io   = require('socket.io-client')
  , http = require('http')
  , host = 'http://localhost:8080';

var get_subscriptions = function(data){
  console.log(data);
  http.get(host, function(res) {
      console.log("Got response: " + res.body);
      res.on('data', function (chunk) { console.log('BODY: ' + chunk); });
  }).on('error', function(e) {
      console.log("Got error: " + e.message);
  });
};

var socket = io.connect(host);

socket.on('connect', function () { 
  console.log("socket connected"); 
  socket.on('channels-updated', get_subscriptions);
});
