// C interface to the SID adapter. Writes return one for claimed ports. Advance
// takes Z80 cycles; pace returns one when audio supplies the main-loop throttling.
#ifndef RC2014_SIDULATOR_H
#define RC2014_SIDULATOR_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
int sidulator_init(void);
int sidulator_write(uint16_t port, uint8_t value);
void sidulator_advance(unsigned z80_cycles);
int sidulator_pace(void);
void sidulator_close(void);
#ifdef __cplusplus
}
#endif
#endif
