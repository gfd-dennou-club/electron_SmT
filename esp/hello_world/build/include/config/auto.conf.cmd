deps_config := \
	/home/zasa/esp/esp-idf/components/app_trace/Kconfig \
	/home/zasa/esp/esp-idf/components/aws_iot/Kconfig \
	/home/zasa/esp/esp-idf/components/bt/Kconfig \
	/home/zasa/esp/esp-idf/components/driver/Kconfig \
	/home/zasa/esp/esp-idf/components/efuse/Kconfig \
	/home/zasa/esp/esp-idf/components/esp32/Kconfig \
	/home/zasa/esp/esp-idf/components/esp_adc_cal/Kconfig \
	/home/zasa/esp/esp-idf/components/esp_event/Kconfig \
	/home/zasa/esp/esp-idf/components/esp_http_client/Kconfig \
	/home/zasa/esp/esp-idf/components/esp_http_server/Kconfig \
	/home/zasa/esp/esp-idf/components/esp_https_ota/Kconfig \
	/home/zasa/esp/esp-idf/components/espcoredump/Kconfig \
	/home/zasa/esp/esp-idf/components/ethernet/Kconfig \
	/home/zasa/esp/esp-idf/components/fatfs/Kconfig \
	/home/zasa/esp/esp-idf/components/freemodbus/Kconfig \
	/home/zasa/esp/esp-idf/components/freertos/Kconfig \
	/home/zasa/esp/esp-idf/components/heap/Kconfig \
	/home/zasa/esp/esp-idf/components/libsodium/Kconfig \
	/home/zasa/esp/esp-idf/components/log/Kconfig \
	/home/zasa/esp/esp-idf/components/lwip/Kconfig \
	/home/zasa/esp/esp-idf/components/mbedtls/Kconfig \
	/home/zasa/esp/esp-idf/components/mdns/Kconfig \
	/home/zasa/esp/esp-idf/components/mqtt/Kconfig \
	/home/zasa/esp/esp-idf/components/nvs_flash/Kconfig \
	/home/zasa/esp/esp-idf/components/openssl/Kconfig \
	/home/zasa/esp/esp-idf/components/pthread/Kconfig \
	/home/zasa/esp/esp-idf/components/spi_flash/Kconfig \
	/home/zasa/esp/esp-idf/components/spiffs/Kconfig \
	/home/zasa/esp/esp-idf/components/tcpip_adapter/Kconfig \
	/home/zasa/esp/esp-idf/components/unity/Kconfig \
	/home/zasa/esp/esp-idf/components/vfs/Kconfig \
	/home/zasa/esp/esp-idf/components/wear_levelling/Kconfig \
	/home/zasa/esp/esp-idf/components/app_update/Kconfig.projbuild \
	/home/zasa/esp/esp-idf/components/bootloader/Kconfig.projbuild \
	/home/zasa/esp/esp-idf/components/esptool_py/Kconfig.projbuild \
	/home/zasa/esp/esp-idf/components/partition_table/Kconfig.projbuild \
	/home/zasa/esp/esp-idf/Kconfig

include/config/auto.conf: \
	$(deps_config)

ifneq "$(IDF_TARGET)" "esp32"
include/config/auto.conf: FORCE
endif
ifneq "$(IDF_CMAKE)" "n"
include/config/auto.conf: FORCE
endif

$(deps_config): ;
