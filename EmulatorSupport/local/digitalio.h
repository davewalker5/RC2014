// C entry points are called by the Z80 emulator; SDL event/frame helpers below
// are C++ only. Port handlers return one when they claim an access, else zero.
// GPL-2.0-or-later
#ifndef RC2014_DIGITALIO_H
#define RC2014_DIGITALIO_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
int digitalio_init(void);
int digitalio_read(uint16_t port, uint8_t *value);
int digitalio_write(uint16_t port, uint8_t value);
void digitalio_close(void);
void peripheral_events(void);
#ifdef __cplusplus
}
#include <SDL.h>
void digitalio_event(const SDL_Event &event);
void digitalio_frame(void);
void lcd_event(const SDL_Event &event);
void lcd_frame(void);
#endif
#endif
