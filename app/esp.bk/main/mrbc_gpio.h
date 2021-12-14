#ifndef MRBC_GPIO_H
#define MRBC_GPIO_H

#include "mrubyc.h"
#include "driver/gpio.h"


void c_gpio_config_output(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_set_pullup(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_set_floating(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_set_mode_input(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_set_mode_output(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_set_level(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_get_level(mrb_vm* vm, mrb_value* v, int argc);
void c_gpio_nop(mrb_vm* vm, mrb_value* v, int argc);


#endif // MRBC_GPIO_H
