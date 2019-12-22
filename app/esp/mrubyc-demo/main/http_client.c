#include "http_client.h"
#include "mrubyc.h"

#define MAX_HTTP_RECV_BUFFER 512

static char tag[] = "main";
esp_http_client_handle_t client;

extern const char howsmyssl_com_root_cert_pem_start[] asm("_binary_howsmyssl_com_root_cert_pem_start");
extern const char howsmyssl_com_root_cert_pem_end[]   asm("_binary_howsmyssl_com_root_cert_pem_end");

esp_err_t _http_event_handler(esp_http_client_event_t *evt)
{
    switch(evt->event_id) {
        case HTTP_EVENT_ERROR:
            ESP_LOGD(tag, "HTTP_EVENT_ERROR");
            break;
        case HTTP_EVENT_ON_CONNECTED:
            ESP_LOGD(tag, "HTTP_EVENT_ON_CONNECTED");
            break;
        case HTTP_EVENT_HEADER_SENT:
            ESP_LOGD(tag, "HTTP_EVENT_HEADER_SENT");
            break;
        case HTTP_EVENT_ON_HEADER:
            ESP_LOGD(tag, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key, evt->header_value);
            break;
        case HTTP_EVENT_ON_DATA:
            ESP_LOGD(tag, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
            if (!esp_http_client_is_chunked_response(evt->client)) {
                // Write out data
                printf("%.*s", evt->data_len, (char*)evt->data);
            }

            break;
        case HTTP_EVENT_ON_FINISH:
            ESP_LOGD(tag, "HTTP_EVENT_ON_FINISH");
            break;
        case HTTP_EVENT_DISCONNECTED:
            ESP_LOGD(tag, "HTTP_EVENT_DISCONNECTED");
            break;
    }
    return ESP_OK;
}

void c_http_client_init(mrb_vm *vm, mrb_value *v, int argc) {
    unsigned char *input_url = GET_STRING_ARG(1);
    esp_http_client_config_t config = {
        .url = (char *)input_url,
        .event_handler = _http_event_handler,
    };
    client = esp_http_client_init(&config);
}
void c_http_request(mrb_vm *vm, mrb_value *v, int argc) {
    esp_err_t err = esp_http_client_perform(client);
    if (err != ESP_OK) {
        printf("\n");
        ESP_LOGE(tag, "HTTP GET request failed: %s", esp_err_to_name(err));
    }else{
        printf("\n");
    }
} // End of httpRequest

void c_http_client_cleanup(mrb_vm *vm, mrb_value *v, int argc){
    esp_http_client_cleanup(client);
}
