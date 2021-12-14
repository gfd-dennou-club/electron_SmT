#include "mrbc_gpio.h"


static int unreferenced;


void c_gpio_config_output(mrb_vm* vm, mrb_value* v, int argc) {
  gpio_config_t io_conf;
  int pin = GET_INT_ARG(1);

  //disable interrupt
  io_conf.intr_type = GPIO_PIN_INTR_DISABLE;
  //set as output mode
  io_conf.mode = GPIO_MODE_OUTPUT;
  //bit mask of the pins that you want to set,e.g.GPIO18/19
  io_conf.pin_bit_mask = (1ULL << pin);
  //disable pull-down mode
  io_conf.pull_down_en = 0;
  //disable pull-up mode
  io_conf.pull_up_en = 0;
  //configure GPIO with the given settings
  gpio_config(&io_conf);
}

void c_gpio_set_pullup(mrb_vm* vm, mrb_value* v, int argc) {
  int pin = GET_INT_ARG(1);
  gpio_set_pull_mode(pin, GPIO_PULLUP_ONLY);
}

void c_gpio_set_floating(mrb_vm* vm, mrb_value* v, int argc) {
  int pin = GET_INT_ARG(1);
  gpio_set_pull_mode(pin, GPIO_FLOATING);
}


void c_gpio_set_mode_input(mrb_vm* vm, mrb_value* v, int argc) {
  int pin = GET_INT_ARG(1);
  gpio_set_direction(pin, GPIO_MODE_INPUT);
}

void c_gpio_set_mode_output(mrb_vm* vm, mrb_value* v, int argc) {
  int pin = GET_INT_ARG(1);
  gpio_set_direction(pin, GPIO_MODE_OUTPUT);
}


void c_gpio_set_level(mrb_vm* vm, mrb_value* v, int argc) {
  int pin   = GET_INT_ARG(1);
  int level = GET_INT_ARG(2);
  gpio_set_level(pin, level);
}

void c_gpio_get_level(mrb_vm* vm, mrb_value* v, int argc) {
  int pin = GET_INT_ARG(1);
  SET_INT_RETURN(gpio_get_level(pin));
}


void c_gpio_nop(mrb_vm* vm, mrb_value* v, int argc) {
  // NO OPERATION
  int max = GET_INT_ARG(1);
  for ( int i = 0 ; i < max ; ++i ) {
    unreferenced += 1;
  }
}
