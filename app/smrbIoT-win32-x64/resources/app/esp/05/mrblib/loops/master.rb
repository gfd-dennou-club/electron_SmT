gpio_init_output(15)
i2c = GpioTest.new(22, 21)

# i2c.simulate_rtc_2_1
i2c.i2c_init
i2c.lcd_init

def self.LED_ON
  gpio_set_level(32,1)
  gpio_set_level(33,1)
  gpio_set_level(25,1)
  gpio_set_level(26,1)
  gpio_set_level(27,1)
  gpio_set_level(14,1)
  gpio_set_level(12,1)
  gpio_set_level(13,1)
  
end

def self.LED_OFF
  gpio_set_level(32,0)
  gpio_set_level(33,0)
  gpio_set_level(25,0)
  gpio_set_level(26,0)
  gpio_set_level(27,0)
  gpio_set_level(14,0)
  gpio_set_level(12,0)
  gpio_set_level(13,0)
  
end

def self.LED_Initialize
  gpio_init_output(32)
  gpio_init_output(33)
  gpio_init_output(25)
  gpio_init_output(26)
  gpio_init_output(27)
  gpio_init_output(14)
  gpio_init_output(12)
  gpio_init_output(13)
  self.LED_OFF
end

def self.Thermistor_Initialize
  gpio_init_output(0)
  gpio_set_level(0,1)
  init_adc
end

self.LED_Initialize
self.Thermistor_Initialize
gpio_init_input(35)
gpio_init_input(34)
gpio_init_input(19)
gpio_init_input(18)
while true do
  $sw = gpio_get_level(35) + gpio_get_level(34) + gpio_get_level(19) + gpio_get_level(18)
  $vref = read_adc
  $temp = 1.to_f / ( 1.to_f / 3435 * Math.log(((3300 - $vref).to_f / ($vref.to_f/ 10_000)) / 10_000) + 1.to_f / (25 + 273) ) - 273
  puts $temp
  puts $sw
  if $temp > 30
    self.LED_ON
    i2c.lcd_write(0x00, [ 0x01, 0x80 ] )
    i2c.lcd_write(0x40, sprintf("turned"))
    i2c.lcd_write(0x00, [ 0x80 + 0x40 ] )
    i2c.lcd_write(0x40, sprintf("on  %dc",$temp))
    gpio_sound(15,660,1000)
  else
    self.LED_OFF
    i2c.lcd_write(0x00, [ 0x01, 0x80 ] )
    i2c.lcd_write(0x40, sprintf("turned"))
    i2c.lcd_write(0x00, [ 0x80 + 0x40 ] )
    i2c.lcd_write(0x40, sprintf("off %dc",$temp))
    sleep(1)
  end
end