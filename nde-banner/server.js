var handler = function (req, res) {
   var channel = url.parse(req.url).path;
   var msg = "BUS in 3 and 8";
   var doc = {"channel": channel, "msg": msg,"last_updated":"sometime"}
   var msg = JSON.stringify(doc);
   res.writeHead(200);
   res.end(msg);
};

var url  = require('url')
  , app  = require('http').createServer(handler)
  , io   = require('socket.io').listen(app);

app.listen(8080);

io.sockets.on('connection', function (socket) {
   setInterval(function() {
     socket.emit('channels-updated', ['45-INBOUND-20TH&POTRERO', '33-INBOUND-20TH&BRYANT']);
   }, 1500);
});
