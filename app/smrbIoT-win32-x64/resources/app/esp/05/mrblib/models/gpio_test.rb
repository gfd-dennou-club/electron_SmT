class GpioTest

  ACK  = 0
  NACK = 1

  def initialize(gpio_sck, gpio_data)
    @gpio_sck  = gpio_sck
    @gpio_data = gpio_data
  end

  def output1
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    while true
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 1)
      sleep(1)
      gpio_set_level(@gpio_sck, 0)
      gpio_set_level(@gpio_data, 0)
      sleep(1)
    end
  end

  def output2
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    while true
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 1)

      gpio_set_level(@gpio_sck, 0)
      gpio_set_level(@gpio_data, 0)
    end
  end

  def output3
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    while true
      s_connectionreset()
      sleep(1)
    end
  end

  def input
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_mode_input(@gpio_sck)

    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 1)
    gpio_set_mode_input(@gpio_data)

    prv_sck  = nil
    prv_data = nil
    while true
      sck  = gpio_get_level(@gpio_sck)
      data = gpio_get_level(@gpio_data)

      if prv_sck != sck
        puts "sck is changed, now is ", sck, "\n"
      end

      if prv_data != data
        puts "data is changed, now is ", data, "\n"
      end

      prv_sck  = sck
      prv_data = data
    end
  end

  def simulate1a
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    while true
      s_connectionreset()
      get_temperature
      puts ""
      sleep(10)
    end
  end

  def simulate2a
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    while true
      s_connectionreset()
      get_humidity(2500)
      puts ""
      sleep(10)
    end
  end

  def simulate3a
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    while true
      s_connectionreset()
      get_config
      puts ""
      sleep(10)
    end
  end

  def simulate4a
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    while true
      s_connectionreset()
      get_config
      sleep(2)
      t = get_temperature
      sleep(2)
      s_connectionreset()
      get_humidity(t)
      puts ""
      sleep(6)
    end
  end

  def simulate1b
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    s_prepare_connectionreset()
    while true
      s_transstart()
      get_temperature
      puts ""
      sleep(10)
    end
  end

  def simulate2b
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    s_prepare_connectionreset()
    while true
      s_transstart()
      get_humidity(2500)
      puts ""
      sleep(10)
    end
  end

  def simulate3b
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    s_prepare_connectionreset()
    while true
      s_transstart()
      get_config
      puts ""
      sleep(10)
    end
  end

  def simulate4b
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    s_prepare_connectionreset()
    while true
      s_transstart()
      get_config
      sleep(2)
      s_transstart()
      t = get_temperature
      sleep(2)
      s_transstart()
      get_humidity(t)
      puts ""
      sleep(6)
    end
  end

  def sht_init
    gpio_set_pullup(@gpio_sck)
    gpio_set_mode_output(@gpio_sck)
    gpio_set_pullup(@gpio_data)
    gpio_set_mode_output(@gpio_data)

    s_connectionreset()
  end

  def sht_get_temp
    s_transstart()
    return get_temperature
  end

  def sht_get_humi(t)
    s_transstart()
    return get_humidity(t)
  end

  def simulate_rtc_1_1
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)

    while true
      gpio_set_level(@gpio_data, 0)
      gpio_set_level(@gpio_sck, 0)

      set_time([])  # without data, means setting address to 0

      # invoke RESTART condition
      gpio_set_level(@gpio_data, 1)
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 0)
      gpio_set_level(@gpio_sck, 0)

      get_time_1

      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 1)
      sleep(10)
    end
  end

  def simulate_rtc_1_2
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)

    while true
      gpio_set_level(@gpio_data, 0)
      gpio_set_level(@gpio_sck, 0)

      get_time_2

      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 1)
      sleep(10)
    end
  end

  def simulate_rtc_1_3
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)

    while true
      gpio_set_level(@gpio_data, 0)
      gpio_set_level(@gpio_sck, 0)

      get_time_3

      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 1)
      sleep(10)
    end
  end

  def simulate_rtc_2_1
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 0)

    set_time([ 0x19, 0x09, 0x09, 1, 0x80 | 0x20, 0x00, 0x00 ])

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)

    sleep(1)
  end

  def simulate_rtc_2_2
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 0)

    set_time([ 0x19, 0x09, 0x09, 1, 0x20 | 0x08, 0x00, 0x00 ])

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)

    sleep(1)
  end

  def rtc_get_time
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 0)
    h = get_time_3
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)

    return h
  end

  def simulate_lcd_1
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)

    lcd_init
    lcd_write(0x40, "Hello")

    while true
      sleep(10)
    end
  end

  def get_config
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_input(@gpio_data)
    ack = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    sleep(1)

    v = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)
    gpio_set_mode_input(@gpio_data)

    c = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    printf("status register: %08x\n", v)
    printf("ack : %d, crc : %08x\n", ack, c)
  end

  def get_temperature
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_input(@gpio_data)
    ack = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    sleep(1)

    v = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)
    gpio_set_mode_input(@gpio_data)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)
    gpio_set_mode_input(@gpio_data)

    c = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    t = v - 3970
    printf("temperature row: %d, calc: %d.%02d\n", v, t / 100, t % 100)
    printf("ack : %d, crc : %08x\n", ack, c)

    return t
  end

  def get_humidity(t)
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_input(@gpio_data)
    ack = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    sleep(1)

    v = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)
    gpio_set_mode_input(@gpio_data)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    v = (v << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 0)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)
    gpio_set_mode_input(@gpio_data)

    c = gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    c = (c << 1) | gpio_get_level(@gpio_data)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    gpio_set_mode_output(@gpio_data)
    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_sck, 0)

    hi = 0.0367 * v - 0.0000015955 * (v * v) - 2.0468
    ht = hi + ((t - 2500) / 100.0) * (0.01 + 0.00008 * v)
    printf("humidity row: %d, calc: %f\n", v, ht)
    printf("ack : %d, crc : %08x\n", ack, c)

    return ht
  end

  def set_time(val)
    ack = []

    cmd = [ (0x32 << 1) | 0, 0 ]

    x = 0
    while x < cmd.length
      v = cmd[x]
      mask = 0x80
      while 0 < mask
        gpio_set_level(@gpio_data, (v & mask != 0 ? 1 : 0))
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
        mask = mask >> 1
      end

      gpio_set_mode_input(@gpio_data)
      ack.push(gpio_get_level(@gpio_data))
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_sck, 0)
      gpio_set_mode_output(@gpio_data)

      x += 1
    end

    x = 0
    while x < val.length
      v = val[val.length - 1 - x]
      mask = 0x80
      while 0 < mask
        gpio_set_level(@gpio_data, (v & mask != 0 ? 1 : 0))
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
        mask = mask >> 1
      end

      gpio_set_mode_input(@gpio_data)
      ack.push(gpio_get_level(@gpio_data))
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_sck, 0)
      gpio_set_mode_output(@gpio_data)

      x += 1
    end

    printf("ack : %s\n", ack.to_s)
  end

  def get_time_1
    get_time_core([ (0x32 << 1) | 1 ], 7, 0)
  end

  def get_time_2
    get_time_core([ (0x32 << 1) | 0, (0 << 4) | 4 ], 7, 0)
  end

  def get_time_3
    get_time_core([ (0x32 << 1) | 1 ], 8, 0x0f)
  end

  def get_time_core(cmd, length, offset)
    ack = []

    x = 0
    while x < cmd.length
      v = cmd[x]
      mask = 0x80
      while 0 < mask
        gpio_set_level(@gpio_data, (v & mask != 0 ? 1 : 0))
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
        mask = mask >> 1
      end

      gpio_set_mode_input(@gpio_data)
      ack.push(gpio_get_level(@gpio_data))
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_sck, 0)
      gpio_set_mode_output(@gpio_data)  if x < cmd.length - 1

      x += 1
    end

    h = {}
    x = 0
    while x < length
      v = 0
      y = 0
      while y < 8
        v = (v << 1) | gpio_get_level(@gpio_data)
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
        y += 1
      end
      h[(offset + x) & 0x0f] = v

      if x < length - 1
        gpio_set_mode_output(@gpio_data)
        gpio_set_level(@gpio_data, ACK)
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
        gpio_set_mode_input(@gpio_data)
      else
        gpio_set_mode_output(@gpio_data)
        gpio_set_level(@gpio_data, NACK)
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
      end
      x += 1
    end

    mode24 = ((h[2] & 0x80) != 0)
    printf("clock mode : %s\n", mode24 ? "24" : "12")
    if ( mode24 )
      printf("%02x-%02x-%02x %02x:%02x:%02x\n", h[6], h[5], h[4], h[2] & 0x3f, h[1], h[0])
    else
      pm = ((h[2] & 0x20) != 0)
      printf("%02x-%02x-%02x %s %02x:%02x:%02x\n", h[6], h[5], h[4], pm ? "PM" : "AM", h[2] & 0x1f, h[1], h[0])
    end
    printf("Ctrl2 : %02x\n", h[0x0f])  unless h[0x0f].nil?
    printf("ack : %s\n", ack.to_s)

    return h
  end

  def lcd_init
    lcd_write(0x00, [ 0x38, 0x39, 0x14, 0x70, 0x56, 0x6c ])
    sleep(1)
    lcd_write(0x00, [ 0x38, 0x0c, 0x01 ])
  end

  def lcd_write(opcode, seq)
    x = 0
    while x < seq.length
      if seq.kind_of?(String)
        v = seq[x].ord
      else
        v = seq[x]
      end
      gpio_set_level(@gpio_data, 0)
      gpio_set_level(@gpio_data, 0)
      gpio_set_level(@gpio_sck, 0)
      ack = i2c_write([ (0x3e << 1), opcode, v])
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_data, 1)

      printf("data: 0x%02x, ack: %s\n", v, ack.to_s)

      x += 1  unless ack[0] == NACK
    end
  end

  def i2c_init
    gpio_set_mode_output(@gpio_sck)
    gpio_set_mode_output(@gpio_data)

    gpio_set_level(@gpio_sck, 1)
    gpio_set_level(@gpio_data, 1)
    sleep(1)
  end

  def i2c_write(cmd)
    ack = []

    x = 0
    while x < cmd.length
      v = cmd[x]
      mask = 0x80
      while 0 < mask
        gpio_set_level(@gpio_data, (v & mask != 0 ? 1 : 0))
        gpio_set_level(@gpio_sck, 1)
        gpio_set_level(@gpio_sck, 0)
        mask = mask >> 1
      end

      gpio_set_mode_input(@gpio_data)
      ack.push(gpio_get_level(@gpio_data))
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_sck, 0)
      gpio_set_mode_output(@gpio_data)

      break  if ack.last == NACK
      x += 1
    end

    return ack
  end

  def s_connectionreset
=begin
    specific waveform is below:

    SCK  _#_#_#_#_#_#_#_#_#_ _##___##_

    DATA ################### ##_____##
=end

    s_prepare_connectionreset()
    s_transstart()
  end

  def s_prepare_connectionreset
=begin
    specific waveform is below:

    SCK  _#_#_#_#_#_#_#_#_#_

    DATA ###################
=end

    # initial state
    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 0)

    # 9 pulses
    i = 0
    while i < 9
      i = i + 1
      gpio_set_level(@gpio_sck, 1)
      gpio_set_level(@gpio_sck, 0)
    end
  end

  def s_transstart
=begin
    specific waveform is below:

    SCK  _##___##_

    DATA ##_____##
=end

    # initial state
    gpio_set_level(@gpio_data, 1)
    gpio_set_level(@gpio_sck, 0)

    # assert clock
    gpio_set_level(@gpio_sck, 1)

    # negate dala during clock is assert
    gpio_set_level(@gpio_data, 0)

    # negate clock
    gpio_set_level(@gpio_sck, 0)

    # assert clock
    gpio_set_level(@gpio_sck, 1)

    # assert dala during clock is assert
    gpio_set_level(@gpio_data, 1)

    # negate clock
    gpio_set_level(@gpio_sck, 0)
  end
end
