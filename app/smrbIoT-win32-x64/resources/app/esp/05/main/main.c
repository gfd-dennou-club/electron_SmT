
/* main/main.c */

#include <stdio.h>
#include <time.h>
#include <sys/time.h>

#include "driver/gpio.h"
#include "driver/adc.h"
#include "driver/ledc.h"
#include "esp_adc_cal.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_spi_flash.h"
#include "nvs_flash.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"

#include "mrubyc.h"

#include "models/thermistor.h"
#include "models/led.h"
#include "loops/master.h"
#include "models/gpio_test.h"
#include "mrbc_gpio.h"

#define DEFAULT_VREF    1100
#define NO_OF_SAMPLES   64
#define MEMORY_SIZE (1024*40)

#define c 261
#define d 294
#define e 329
#define f 349
#define g 391
#define gS 415
#define a 440
#define aS 455
#define b 466
#define cH 523
#define cSH 554
#define dH 587
#define dSH 622
#define eH 659
#define fH 698
#define fSH 740
#define gH 784
#define gSH 830
#define aH 880

static esp_adc_cal_characteristics_t *adc_chars;
static const adc_atten_t atten = ADC_ATTEN_DB_11;
static const adc_channel_t channel = ADC_CHANNEL_3;//GPIO4
static const adc_unit_t unit = ADC_UNIT_1;

static uint8_t memory_pool[MEMORY_SIZE];

static void c_gpio_init_output(mrb_vm *vm, mrb_value *v, int argc) {
  int pin = GET_INT_ARG(1);
  console_printf("init pin %d\n", pin);
  gpio_set_direction(pin, GPIO_MODE_OUTPUT);
}

static void c_gpio_init_input(mrb_vm *vm, mrb_value *v, int argc) {
  int pin = GET_INT_ARG(1);
  console_printf("init pin %d\n", pin);
  gpio_set_direction(pin, GPIO_MODE_INPUT);
  gpio_pullup_en(pin);
}

// static void c_gpio_set_level(mrb_vm *vm, mrb_value *v, int argc){
//   int pin = GET_INT_ARG(1);
//   int level = GET_INT_ARG(2);
//   gpio_set_level(pin, level);
// }

//adc (Analog Degital Conv erter)
static void c_init_adc(mrb_vm *vm, mrb_value *v, int argc){
  adc1_config_width(ADC_WIDTH_BIT_12);
  adc1_config_channel_atten((adc_channel_t)channel,atten);
  // adc2_config_channel_atten((adc1_channel_t)channel, atten);
  adc_chars = calloc(1, sizeof(esp_adc_cal_characteristics_t));
  esp_adc_cal_characterize(unit, atten, ADC_WIDTH_BIT_12, DEFAULT_VREF, adc_chars);
}

static void c_read_adc(mrb_vm *vm, mrb_value *v, int argc){
  uint32_t adc_reading = 0;
  for (int i = 0; i < NO_OF_SAMPLES; i++) {
    int raw = adc1_get_raw((adc_channel_t)channel);
    // adc2_get_raw((adc1_channel_t)channel, ADC_WIDTH_BIT_12, &raw);
    adc_reading += raw;
  }
  adc_reading /= NO_OF_SAMPLES;
  uint32_t millivolts = esp_adc_cal_raw_to_voltage(adc_reading, adc_chars);
  SET_INT_RETURN(millivolts);
}

static void c_sound(mrb_vm *vm, mrb_value *v, int argc) {
  int gpio_num = GET_INT_ARG(1);
  uint32_t freq = GET_INT_ARG(2);
  uint32_t duration = GET_INT_ARG(3);
	ledc_timer_config_t timer_conf;
	timer_conf.speed_mode = LEDC_HIGH_SPEED_MODE;
	timer_conf.bit_num    = LEDC_TIMER_10_BIT;
	timer_conf.timer_num  = LEDC_TIMER_0;
	timer_conf.freq_hz    = freq;
	ledc_timer_config(&timer_conf);

	ledc_channel_config_t ledc_conf;
	ledc_conf.gpio_num   = gpio_num;
	ledc_conf.speed_mode = LEDC_HIGH_SPEED_MODE;
	ledc_conf.channel    = LEDC_CHANNEL_0;
	ledc_conf.intr_type  = LEDC_INTR_DISABLE;
	ledc_conf.timer_sel  = LEDC_TIMER_0;
	ledc_conf.duty       = 0x0; // 50%=0x3FFF, 100%=0x7FFF for 15 Bit
	                            // 50%=0x01FF, 100%=0x03FF for 10 Bit
	ledc_channel_config(&ledc_conf);

	// start
    ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_CHANNEL_0, 0x01FF); // 12% duty - play here for your speaker or buzzer
    ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_CHANNEL_0);
	  vTaskDelay(duration/portTICK_PERIOD_MS);
	// stop
    ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_CHANNEL_0, 0);
    ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_CHANNEL_0);

}

void app_main(void) {
  nvs_flash_init();
  mrbc_init(memory_pool, MEMORY_SIZE);
  mrbc_define_method(0, mrbc_class_object, "gpio_init_output", c_gpio_init_output);
  mrbc_define_method(0, mrbc_class_object, "gpio_init_input", c_gpio_init_input);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_level", c_gpio_set_level);
  mrbc_define_method(0, mrbc_class_object, "init_adc", c_init_adc);
  mrbc_define_method(0, mrbc_class_object, "read_adc", c_read_adc);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_pullup", c_gpio_set_pullup);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_floating", c_gpio_set_floating);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_mode_input", c_gpio_set_mode_input);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_mode_output", c_gpio_set_mode_output);
  mrbc_define_method(0, mrbc_class_object, "gpio_get_level", c_gpio_get_level);
  mrbc_define_method(0, mrbc_class_object, "gpio_nop", c_gpio_nop);
  mrbc_define_method(0, mrbc_class_object, "gpio_sound", c_sound);
  mrbc_create_task(gpio_test, 0);
  mrbc_create_task( thermistor, 0 );
  mrbc_create_task( led, 0 );
  mrbc_create_task( master, 0 );
  mrbc_run();
}
