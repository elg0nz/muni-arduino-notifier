#! /usr/bin/env node
var serialport = require("serialport");
var SerialPort = serialport.SerialPort;

var TTYPATH = '/dev/ttyACM0';
var UNIX_SOCKET = '/tmp/arduino.sock';
var serialPort = new SerialPort(TTYPATH, {
    baudrate: 9600
});

var net = require('net');
var server = net.createServer(function(req, res) { //'connection' listener
    console.log('server connected');
    req.on('end', function() {
        console.log('server disconnected');
        serialPort.close();
        process.exit();
    });
    req.write('hello\r\n');

    req.on('data', function(data) {
        serialPort.write(data + "\r\n");
    });
});

server.listen(UNIX_SOCKET, function() { //'listening' listener
    console.log('server bound');
});
