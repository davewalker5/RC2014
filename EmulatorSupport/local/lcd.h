// C interface to the LCD adapter. Advance uses elapsed Z80 cycles; read/write
// return one for handled ports and zero to allow the emulator to dispatch elsewhere.
#ifndef RC2014_LCD_H
#define RC2014_LCD_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
int lcd_init(void);
void lcd_advance(unsigned cycles);
int lcd_write(uint16_t port,uint8_t value);
int lcd_read(uint16_t port,uint8_t *value);
void lcd_close(void);
#ifdef __cplusplus
}
#endif
#endif
