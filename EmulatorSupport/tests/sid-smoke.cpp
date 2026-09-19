// Exercise the adapter deterministically, without Z80/BASIC timing variation.
#include "../local/sidulator.h"
#include <cassert>
static void reg(unsigned r,unsigned v) {
    assert(sidulator_write(0x12d4,r));
    assert(sidulator_write(0x34d5,v));
}
static void seconds(unsigned n) { for(unsigned i=0;i<n*1000;i++) sidulator_advance(7373); }
int main() {
    assert(sidulator_init());
    assert(!sidulator_write(0x99,1));
    reg(24,0);seconds(1);
    reg(0,0xd6);reg(1,0x1c); // 7382: approximately 440Hz at 1 MHz.
    reg(5,0);reg(6,0xf0);reg(24,15);reg(4,17);seconds(2);
    reg(24,0);seconds(1);
    // Noise, then voices 2+3 with pulse and sawtooth.
    reg(24,15);reg(4,129);seconds(1);reg(4,0);
    reg(7,0xd6);reg(8,0x1c);reg(9,0);reg(10,8);reg(12,0);reg(13,0xf0);reg(11,65);
    reg(14,0xd6);reg(15,0x0e);reg(19,0);reg(20,0xf0);reg(18,33);seconds(1);
    reg(24,0);seconds(1);
    sidulator_close();
}
