#ifndef HTTP_CLIENT_H
#define HTTP_CLIENT_H


#include <string.h>
#include <stdlib.h>

#include "esp_log.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_http_client.h"

#include "mrubyc.h"

void c_http_client_init(mrb_vm *vm, mrb_value *v, int argc);
void c_http_request(mrb_vm *vm, mrb_value *v, int argc);
void c_http_client_cleanup(mrb_vm *vm, mrb_value *v, int argc);


#endif // HTTP_CLIENT_H
