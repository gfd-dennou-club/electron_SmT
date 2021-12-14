#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

#include "driver/adc.h"
#include "driver/ledc.h"
#include "esp_adc_cal.h"
#include "esp_system.h"
#include "esp_spi_flash.h"
#include "nvs_flash.h"

#include "mrubyc.h"
#include "wifi.h"
#include "http_client.h"
#include "mrbc_gpio.h"

#include "models/human_friendly_hrt.h"
#include "models/hrt.h"
#include "models/gpio_test.h"
#include "models/thermistor.h"
#include "models/led.h"
#include "loops/master.h"

// #include "models/[replace with your file].h"
// #include "loops/[replace with your file].h"

#define DEFAULT_VREF    1100
#define NO_OF_SAMPLES   64
#define MEMORY_SIZE (1024*40)
#define NETWORK_SECURITY_MODE 0 

static esp_adc_cal_characteristics_t *adc_chars;
static const adc_atten_t atten = ADC_ATTEN_DB_11;
static const adc_channel_t channel = ADC_CHANNEL_3;//GPIO4
static const adc_unit_t unit = ADC_UNIT_1;


static uint8_t memory_pool[MEMORY_SIZE];

static void get_time_us(mrb_vm *vm, mrb_value *v, int argc)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    SET_INT_RETURN(tv.tv_usec);
}

static void c_timer_get_time(mrb_vm *vm, mrb_value *v, int argc){
  uint64_t clock_millis = (int64_t) esp_timer_get_time();
  SET_INT_RETURN(clock_millis);
}

//================================================================
/*! DEBUG PRINT
*/
void chip_info() {
    /* Print chip information */
    esp_chip_info_t chip_info;
    esp_chip_info(&chip_info);
    printf("This is ESP32 chip with %d CPU cores, WiFi%s%s, ",
            chip_info.cores,
            (chip_info.features & CHIP_FEATURE_BT) ? "/BT" : "",
            (chip_info.features & CHIP_FEATURE_BLE) ? "/BLE" : "");

    printf("silicon revision %d, ", chip_info.revision);

    printf("%dMB %s flash\n", spi_flash_get_chip_size() / (1024 * 1024),
            (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "embedded" : "external");
}

static void c_debugprint(struct VM *vm, mrbc_value v[], int argc){
  for( int i = 0; i < 79; i++ ) { console_putchar('='); }
  console_putchar('\n');
  chip_info();
  int total, used, free, fragment;
  mrbc_alloc_statistics( &total, &used, &free, &fragment );
  console_printf("Memory total:%d, used:%d, free:%d, fragment:%d\n", total, used, free, fragment );
  unsigned char *key = GET_STRING_ARG(1);
  unsigned char *value = GET_STRING_ARG(2);
  console_printf("%s:%s\n", key, value );
  heap_caps_print_heap_info(MALLOC_CAP_8BIT);
  heap_caps_print_heap_info(MALLOC_CAP_32BIT);
  for( int i = 0; i < 79; i++ ) { console_putchar('='); }
  console_putchar('\n');
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

static void c_gpio_init_output(mrb_vm *vm, mrb_value *v, int argc) {
  int pin = GET_INT_ARG(1);
  console_printf("init pin %d\n", pin);
  gpio_pad_select_gpio(pin);
  gpio_set_direction(pin, GPIO_MODE_OUTPUT);
}

static void c_gpio_init_input(mrb_vm *vm, mrb_value *v, int argc) {
  int pin = GET_INT_ARG(1);
  console_printf("init pin %d\n", pin);
  gpio_set_direction(pin, GPIO_MODE_INPUT);
  gpio_pullup_en(pin);
}

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

void app_main(void) {
  nvs_flash_init();
  mrbc_init(memory_pool, MEMORY_SIZE);
  
  mrbc_define_method(0, mrbc_class_object, "initialize_wifi", c_initialize_wifi);
  mrbc_define_method(0, mrbc_class_object, "debugprint", c_debugprint);
  mrbc_define_method(0, mrbc_class_object, "timer_get_time", c_timer_get_time);
  mrbc_define_method(0, mrbc_class_object, "get_current_time", get_time_us);
  mrbc_define_method(0, mrbc_class_object, "http_client_init", c_http_client_init);
  mrbc_define_method(0, mrbc_class_object, "get_http_response", c_http_request);
  mrbc_define_method(0, mrbc_class_object, "http_client_set_header", c_http_client_set_header);
  mrbc_define_method(0, mrbc_class_object, "http_client_set_post_field", c_http_client_set_post_field);
  mrbc_define_method(0, mrbc_class_object, "http_client_cleanup", c_http_client_cleanup);
  mrbc_define_method(0, mrbc_class_object, "check_network_status", c_network_status);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_pullup", c_gpio_set_pullup);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_floating", c_gpio_set_floating);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_mode_input", c_gpio_set_mode_input);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_mode_output", c_gpio_set_mode_output);
  mrbc_define_method(0, mrbc_class_object, "gpio_set_level", c_gpio_set_level);
  mrbc_define_method(0, mrbc_class_object, "gpio_get_level", c_gpio_get_level);
  mrbc_define_method(0, mrbc_class_object, "gpio_nop", c_gpio_nop);
  mrbc_define_method(0, mrbc_class_object, "gpio_sound", c_sound);
  mrbc_define_method(0, mrbc_class_object, "gpio_init_output", c_gpio_init_output);
  mrbc_define_method(0, mrbc_class_object, "gpio_init_input", c_gpio_init_input);
  mrbc_define_method(0, mrbc_class_object, "init_adc", c_init_adc);
  mrbc_define_method(0, mrbc_class_object, "read_adc", c_read_adc);

  // mrbc_create_task( [replace with your task], 0 );
  mrbc_create_task(hrt, 0);
  mrbc_create_task(human_friendly_hrt, 0);
  mrbc_create_task(gpio_test, 0);
  mrbc_create_task(thermistor, 0);
  mrbc_create_task(led, 0);
  mrbc_create_task(master, 0);
  mrbc_run();
}