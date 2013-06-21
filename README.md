# Muni Arduino Notifier
Fetches bus stops from Nextbus and displays them in a lolshield.

## Usage:
1. Get an Arduino and hook it up to your computer.
2. Program your Arduino with the sketch in serialFontDisplay
3. Identify your serial port. And modify the value on socket_to_serial_proxy if necessary.
4. Delete /tmp/arduino.socket if necessary
5. chmod +s ./socket_to_serial_proxy.js
6. $ ./socket_to_serial_proxy.js&
7. Modify muni_fetcher to get the stop(s) you want to see
8. ruby muni_fetcher.rb
9. Enjoy!
