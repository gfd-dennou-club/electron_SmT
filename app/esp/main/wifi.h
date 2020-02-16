#ifndef WIFI_H
#define WIFI_H


#include <string.h>
#include <stdlib.h>

#include "esp_wifi.h"
#include "esp_wpa2.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "esp_system.h"
#include "esp_event.h"

#include "mrubyc.h"


typedef enum {
  WPA_MODE_ENT = 0,
  WPA_MODE_PSK
} WIFI_WPA_MODE;

typedef enum {
  EAP_MODE_PEAP = 1,
  EAP_MODE_TTLS
} WIFI_EAP_MODE;


void c_network_status(mrb_vm *vm, mrb_value *v, int argc);
void initialize_wifi(WIFI_WPA_MODE mode, char *ssid, char *name, char *pass);
void c_initialize_wifi(mrb_vm *vm, mrb_value *v, int argc);

#endif // WIFI_H
