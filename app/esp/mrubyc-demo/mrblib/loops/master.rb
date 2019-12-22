# mrblib/loops/master.rb
=begin
hfhrt = HumanFriendlyHrt.new
now = get_current_time()
puts "current time is .." + now.to_s
hfhrt.adjust(now.to_i)
http_client_init("http://10.176.0.150/~hogehoge/helloworld.htm")
while true
  connected = check_network_status()
  if connected
    get_http_response()
    timestamp = hfhrt.now
    puts "the timer value is .." + (timestamp/1000).to_s
    sleep 10
  end
end
http_client_cleanup()
=end



i2c = GpioTest.new(22, 21)
sht = GpioTest.new(2,4)

i2c.simulate_rtc_2_1
i2c.i2c_init
i2c.lcd_init

sht.sht_init

host = "zasa"
initialize_wifi(0,"H550W_pub","j1501","Sumika!9mm0806");

while true
  #データ取得
  temp = sht.sht_get_temp / 100.0
  humi = sht.sht_get_humi(temp)
  h = i2c.rtc_get_time

  url = "http://10.176.0.150/~hogehoge/php/monitoring.php?hostname=#{host}"
  url = url << "\&time=#{sprintf("%02x/%02x/%02xT%02x:%02x:%02x", h[6], h[5], h[4], h[2] & 0x3f, h[1], h[0])}"
  url = url << "\&temp=#{temp}"
  url = url << "\&humi=#{humi}"
  
  #データ転送
  connected = check_network_status()
  if connected
    http_client_init(url)
    get_http_response()
    http_client_cleanup()
  end

  #画面表示
  i2c.lcd_write(0x00, [ 0x01, 0x80 ] )
  i2c.lcd_write(0x40, sprintf("%02x-%02x-%02x", h[6], h[5], h[4]))
  i2c.lcd_write(0x00, [ 0x80 + 0x40 ] )
  i2c.lcd_write(0x40, sprintf("%02x:%02x:%02x", h[2] & 0x3f, h[1], h[0]))
  sleep(1)
  i2c.lcd_write(0x00, [ 0x01, 0x80 ] )
  i2c.lcd_write(0x40, sprintf("t: %2d.%02d", temp / 100, temp % 100))
  i2c.lcd_write(0x00, [ 0x80 + 0x40 ] )
  i2c.lcd_write(0x40, sprintf("h: %4.2f", humi))

end


