#!/usr/bin/ruby
# 
# emeter8870-read.rb - sample secript for USB e-Meter 8870
#
# USB e-Meter 8870
#   http://akizukidenshi.com/catalog/g/gM-07017/
#   http://www.aviosys.com/8870.html
#   http://www.aviosys.com/downloads/manuals/others/USB%20e-Meter8870Manual_EN.pdf
#
# How to use
#  $ mkdir -p ~/work/  
#  $ cd ~/work/
#  $ git clone https://github.com/yoggy/emeter8870-read
#  $ cd emeter8870
#  $ sudo apt-get install redis ruby ruby-dev
#  $ sudo gem install serialport redis mqtt
#  $ ./emeter8870-read.rb
#
# License
#   Copyright (c) 2017 yoggy <yoggy0@gmail.com>
#   Released under the MIT license
#   http://opensource.org/licenses/mit-license.php;//
#
require 'serialport'
require 'redis'
require 'mqtt'


# configuration
dev        = '/dev/ttyACM0'
mqtt_host  = 'mqtt.iotgw'
mqtt_port  = 1883
mqtt_topic = 'emeter8870/1'
redis_key  = 'oled:3'

$stdout.sync = true
$log = Logger.new(STDOUT)
$log.level = Logger::DEBUG

sp = SerialPort.new(dev, 19200, 8, 1, 0) 
redis = Redis.new

$log.info "start emeter8870-read.rb..."

$val = "0"

Thread.abort_on_exception = true
Thread.start do
  # mqtt publish
  begin
    MQTT::Client.connect(mqtt_host, mqtt_port) do |c|
      c.publish(mqtt_topic, $val)
    end
  rescue Exception => e
    $log.error(e)
  end
  
  sleep 1
end

loop do 
  # read current value from e-Meter 8870
  sp.write("@")
  sp.flush
  $val = sp.gets.chomp

  $log.debug($val)

  # for redis-oled-display
  redis.set(redis_key, $val)

  sleep 1
end

