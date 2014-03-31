var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app);

app.listen(8080);

io.sockets.on('connection', function (socket) {
    socket.emit('channels-updated', ['45-INBOUND-20TH&POTRERO', '33-INBOUND-20TH&BRYANT']);
});

function handler (req, res) {
   var msg = '{ "msg": "45 in 3 and 8", "last_updated": "sometime" }';
   res.writeHead(200);
   res.end(msg);
};
