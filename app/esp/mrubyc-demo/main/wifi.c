#include "wifi.h"
// #include <stdlib.h>

// #define ENT_WIFI_SSID "H530W_pub" 
#define ENT_EAP_METHOD CONFIG_ENT_EAP_METHOD
#define ENT_EAP_ID CONFIG_ENT_EAP_ID

#define PSK_ESP_WIFI_SSID      CONFIG_PSK_WIFI_SSID
#define PSK_ESP_WIFI_PASS      CONFIG_PSK_WIFI_PASSWORD


const int CONNECTED_BIT = BIT0;

static char tag[] = "main";
int connection_status = 0;

extern uint8_t ca_pem_start[] asm("_binary_wpa2_ca_pem_start");
extern uint8_t ca_pem_end[]   asm("_binary_wpa2_ca_pem_end");
extern uint8_t client_crt_start[] asm("_binary_wpa2_client_crt_start");
extern uint8_t client_crt_end[]   asm("_binary_wpa2_client_crt_end");
extern uint8_t client_key_start[] asm("_binary_wpa2_client_key_start");
extern uint8_t client_key_end[]   asm("_binary_wpa2_client_key_end");

void c_network_status(mrb_vm *vm, mrb_value *v, int argc){
  if(connection_status == 1){
    SET_TRUE_RETURN();
  }else{
    SET_FALSE_RETURN();
  }
}

esp_err_t wifi_event_handler(void *ctx, system_event_t *event)
{
    if (event->event_id == SYSTEM_EVENT_STA_GOT_IP) {
        ESP_LOGI(tag, "Got an IP ... ready to go!");
        //connection status to be removed in next update
        connection_status = 1;
        //xTaskCreatePinnedToCore(&httpRequest, "httpRequest", 10000, NULL, 5, NULL, 0);
        tcpip_adapter_ip_info_t ip;
        memset(&ip, 0, sizeof(tcpip_adapter_ip_info_t));
        if (tcpip_adapter_get_ip_info(ESP_IF_WIFI_STA, &ip) == 0) {
            ESP_LOGI(tag, "~~~~~~~~~~~");
            ESP_LOGI(tag, "IP:"IPSTR, IP2STR(&ip.ip));
            ESP_LOGI(tag, "MASK:"IPSTR, IP2STR(&ip.netmask));
            ESP_LOGI(tag, "GW:"IPSTR, IP2STR(&ip.gw));
            ESP_LOGI(tag, "~~~~~~~~~~~");
        }
    }
    else if(event->event_id == SYSTEM_EVENT_STA_START){
       ESP_LOGI(tag, "Waiting for IP ..");
       connection_status = 0;
       esp_wifi_connect();
    }
    else if(event->event_id == SYSTEM_EVENT_STA_DISCONNECTED){
        ESP_LOGI(tag, "Retrying for IP ..");
        esp_wifi_connect();
        connection_status = 0;
        //xTaskCreatePinnedToCore(&httpRequest, "httpRequest", 10000, NULL, 5, NULL, 0);
    }
    else{
        ESP_LOGI(tag, "Trying to get IP ..");
        connection_status = 0;
        esp_wifi_connect();
    }
	return ESP_OK;
}

void initialize_wifi(WIFI_WPA_MODE mode, char *ssid, char *name, char *pass) {
  tcpip_adapter_init();
  ESP_ERROR_CHECK( esp_event_loop_init(wifi_event_handler, NULL) );
  wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
  ESP_ERROR_CHECK( esp_wifi_init(&cfg) );
  ESP_ERROR_CHECK( esp_wifi_set_storage(WIFI_STORAGE_RAM) );
  if(WPA_MODE_ENT == mode){
    esp_wpa2_config_t config = WPA2_CONFIG_INIT_DEFAULT();
    wifi_config_t wifi_config = {};
    memcpy(wifi_config.sta.ssid,(uint8_t *)ssid,sizeof(char) * 32);
    ESP_LOGI(tag, "Setting WPA2 Enterprise WiFi configuration SSID %s...", wifi_config.sta.ssid);
    ESP_ERROR_CHECK( esp_wifi_set_mode(WIFI_MODE_STA) );
    ESP_ERROR_CHECK( esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config) );
    ESP_ERROR_CHECK( esp_wifi_sta_wpa2_ent_set_identity((uint8_t *)ENT_EAP_ID, strlen(ENT_EAP_ID)) );
    if (ENT_EAP_METHOD == EAP_MODE_PEAP || ENT_EAP_METHOD == EAP_MODE_TTLS) {
        ESP_ERROR_CHECK( esp_wifi_sta_wpa2_ent_set_username((uint8_t *)name, strlen(name)) );
        ESP_ERROR_CHECK( esp_wifi_sta_wpa2_ent_set_password((uint8_t *)pass, strlen(pass)) );
    } 
    ESP_ERROR_CHECK( esp_wifi_sta_wpa2_ent_enable(&config) );
  }else{
    wifi_config_t wifi_config = {};
    memcpy(wifi_config.sta.ssid,(uint8_t *)ssid,sizeof(char) * 32);
    memcpy(wifi_config.sta.password,(uint8_t *)pass,sizeof(char) * 64);
    ESP_LOGI(tag, "Setting WPA2 Personal WiFi configuration SSID %s...", wifi_config.sta.ssid);
    ESP_ERROR_CHECK( esp_wifi_set_mode(WIFI_MODE_STA) );
    ESP_ERROR_CHECK( esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config) );
  }
  ESP_ERROR_CHECK( esp_wifi_start() );
  ESP_LOGI(tag, "Wifi initialization finished.");
}

void c_initialize_wifi(mrb_vm* vm, mrb_value* v, int argc){
  WIFI_WPA_MODE mode = GET_INT_ARG(1);
  char *ssid = (char *)GET_STRING_ARG(2);
  char *name = (char *)GET_STRING_ARG(3);
  char *pass = (char *)GET_STRING_ARG(4);
  initialize_wifi(mode,ssid,name,pass);
}
