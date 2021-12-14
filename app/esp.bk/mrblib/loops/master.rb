gpio_init_input(34)
gpio_init_input(35)
gpio_init_input(18)
gpio_init_input(19)
gpio_init_output(13)
gpio_init_output(12)
gpio_init_output(14)
gpio_init_output(27)

while 1 do
  if gpio_get_level(34) == 1
    gpio_set_level(13,1)
  else
    gpio_set_level(13,0)
  end
  if gpio_get_level(35) == 1
    gpio_set_level(12,1)
  else
    gpio_set_level(12,0)
  end
  if gpio_get_level(18) == 1
    gpio_set_level(14,1)
  else
    gpio_set_level(14,0)
  end
  if gpio_get_level(19) == 1
    gpio_set_level(27,1)
  else
    gpio_set_level(27,0)
  end
end
