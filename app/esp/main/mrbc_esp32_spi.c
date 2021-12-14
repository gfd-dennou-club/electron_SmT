/*! @file
  @brief
  mruby/c SPI class for ESP32
*/

#include "mrbc_esp32_spi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/spi_master.h"
#include "driver/gpio.h"
#include "esp_log.h"

static char* tag = "main";
#define DMA_CHAN    2

static struct RClass* mrbc_class_esp32_spi;
spi_device_handle_t spidev;

/*! Method spi_bus_initialize(mosi, miso, sclk, cs, dc, rst, bl) body : wrapper for spi_bus_initialize.
    @param mosi MOSI Pin Number
           miso MISO Pin Number
           sclk SPI Clock Pin Number
           cs   CS Pin Number
           dc   DC Pin Number
           rst  RST Pin Number(If it is not needed, pass -1)
           bl   BL Pin Number (If it is not needed, pass -1)
    @return if succeeded, return true, otherwise return false.
 */
static void
mrbc_esp32_spi_bus_initialize(mrb_vm* vm, mrb_value* v, int argc)
{

    int gpio_mosi = GET_INT_ARG(1);
    int gpio_miso = GET_INT_ARG(2);
    int gpio_sclk = GET_INT_ARG(3);
    int gpio_cs = GET_INT_ARG(4);
    int gpio_dc = GET_INT_ARG(5);
    int gpio_rst = GET_INT_ARG(6);
    int gpio_bl = GET_INT_ARG(7);

    spi_bus_config_t bus_cfg = {
        .mosi_io_num = gpio_mosi,
        .miso_io_num = -1,
        .sclk_io_num = gpio_sclk,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1};

    esp_err_t ret = spi_bus_initialize(HSPI_HOST, &bus_cfg, DMA_CHAN);
    assert(ret == ESP_OK);

    spi_device_interface_config_t devcfg = {
        .clock_speed_hz = SPI_MASTER_FREQ_40M,
        .spics_io_num = gpio_cs,
        .queue_size = 7,
        .flags = SPI_DEVICE_NO_DUMMY,
    };
    ret = spi_bus_add_device(HSPI_HOST, &devcfg, &spidev);
    assert(ret == ESP_OK);
}

/*! Method write_byte(data)
    @param data
 */
static void
mrbc_esp32_spi_write_byte(mrb_vm* vm, mrb_value* v, int argc)
{
    spi_transaction_t transaction;
    esp_err_t ret;
    assert(GET_ARG(1).tt == MRBC_TT_ARRAY);
    mrbc_value *data = GET_ARG(1).array->data;
    uint8_t Data[1024];
    size_t dataLength = GET_INT_ARG(2);
    for (int i = 0; i < dataLength; i++){
        Data[i] = data[i].i;
    }
    memset(&transaction, 0, sizeof(spi_transaction_t));
    transaction.length = 8 * dataLength;
    transaction.tx_buffer = Data;
    ret = spi_device_transmit(spidev, &transaction);
    assert(ret == ESP_OK);
}

/*! Method read_byte()
    @return recv_data
 */
static void
mrbc_esp32_spi_read_byte(mrb_vm* vm, mrb_value* v, int argc)
{
    spi_transaction_t transaction;
    uint8_t recv_data;
    esp_err_t ret;
    memset(&transaction, 0, sizeof(transaction));
    transaction.length = 8;
    transaction.rx_buffer = &recv_data;
 
    ret=spi_device_polling_transmit(spidev, &transaction);
    assert(ret==ESP_OK);
    SET_INT_RETURN(recv_data);
}

/*! Register SPI Class.
 */
void
mrbc_mruby_esp32_spi_gem_init(struct VM* vm)
{
  // クラス SPI 定義
  mrbc_class_esp32_spi = mrbc_define_class(vm, "SPI", mrbc_class_object);
  // 各メソッド定義
  mrbc_define_method(vm, mrbc_class_esp32_spi, "bus_initialize",      mrbc_esp32_spi_bus_initialize);
  mrbc_define_method(vm, mrbc_class_esp32_spi, "write_byte",          mrbc_esp32_spi_write_byte);
  mrbc_define_method(vm, mrbc_class_esp32_spi, "read_byte",           mrbc_esp32_spi_read_byte);
}
