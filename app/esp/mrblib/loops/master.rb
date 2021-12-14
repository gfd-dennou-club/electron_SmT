i2c = I2C.new(22, 21)

lcd = AQM0802A.new(i2c)
lcd.setup


BLE.init
sleep(3)
while true do
  lcd.cursor(0, 0)
  lcd.write_string(("RSSI").to_s)
  lcd.cursor(0, 1)
  lcd.write_string((BLE.get_rssi).to_s)
end

led13 = GPIO.new( 13, GPIO::OUT )
led12 = GPIO.new( 12, GPIO::OUT )
led14 = GPIO.new( 14, GPIO::OUT )
led27 = GPIO.new( 27, GPIO::OUT )
led26 = GPIO.new( 26, GPIO::OUT )
led25 = GPIO.new( 25, GPIO::OUT )
led33 = GPIO.new( 33, GPIO::OUT )
led32 = GPIO.new( 32, GPIO::OUT )
if BLE.get_rssi > -50
  led13.write(1)
  led12.write(1)
  led14.write(1)
  led27.write(1)
  led26.write(1)
  led25.write(1)
  led33.write(1)
  led32.write(1)
  lcd.cursor(0, 0)
  lcd.write_string((BLE.get_rssi).to_s)
  lcd.cursor(0, 1)
  lcd.write_string(("1m").to_s)
else
  if BLE.get_rssi > -75
    led13.write(1)
    led12.write(1)
    led14.write(1)
    led27.write(1)
    lcd.cursor(0, 0)
    lcd.write_string((BLE.get_rssi).to_s)
    lcd.cursor(0, 1)
    lcd.write_string(("5m").to_s)
  else
    if BLE.get_rssi > -90
      led13.write(1)
      lcd.cursor(0, 0)
      lcd.write_string((BLE.get_rssi).to_s)
      lcd.cursor(0, 1)
      lcd.write_string(("15m").to_s)
    else
      led32.write(1)
    end
  end
end
sleep(5)

lcd.cursor(0, 0)
lcd.write_string(("Hello").to_s)
