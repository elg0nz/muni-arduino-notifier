var serialport = require("serialport");
var ttyPath = '/dev/ttyACM0';
var SerialPort = serialport.SerialPort;
var moment = require("moment");

var serialPort = new SerialPort(ttyPath, {
    baudrate: 9600
    , parser: serialport.parsers.readline("\n")
});

console.log("READY");
function printMessage(){
  var message = moment().format("HH:mm") + "\r\n";
  serialPort.write(message);
};

var seconds = 6;
setInterval(printMessage, seconds *1000);
