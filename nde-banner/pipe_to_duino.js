#!/usr/bin/env node

var serialport = require("serialport");
var SerialPort = serialport.SerialPort;

var ttyPath = '/dev/ttyACM0';
var serialPort = new SerialPort(ttyPath, {
    baudrate: 9600
});

process.stdin.resume();
process.stdin.setEncoding('utf8');
process.stdin.on('data', function(data) {
  serialPort.write(data + "\r\n");
  process.stdout.write(data);
});

process.stdin.on("end", function() {
  serialPort.close();
  process.exit();
});
