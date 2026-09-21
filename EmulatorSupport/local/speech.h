// Provisional MG005/SP0256-AL2 bus adapter. GPL-2.0-or-later.
#ifndef RC2014_SPEECH_H
#define RC2014_SPEECH_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
int speech_init(void);
int speech_write(uint16_t port, uint8_t value);
int speech_read(uint16_t port, uint8_t *value);
void speech_advance(unsigned z80_cycles);
void speech_close(void);
#ifdef __cplusplus
}
#endif
#endif
