// GPL-2.0-or-later. Timing uses the default RC2014's 7.3728 MHz CPU.
#include "lcd_model.h"
void LCDModel::step(bool right) {
    // CGRAM wraps at 64 bytes; two-line DDRAM skips its unused address gap.
    if (cgram) { address=(address+(right?1:63))&63; return; }
    if (two_lines) {
        if (right && address==0x27) address=0x40;
        else if (right && address==0x67) address=0;
        else if (!right && address==0x40) address=0x27;
        else if (!right && address==0) address=0x67;
        else address=(address+(right?1:127))&127;
    } else address=(address+(right?1:79))%80;
}
void LCDModel::write(bool data,uint8_t v) {
    // The hardware requires software to wait or poll before another write.
    if (busy()) return;
    busy_until=cycles+273; // ceil(37us * 7.3728 MHz)
    if (data) {
        // Only the low five bits represent dots in each custom glyph row.
        if (cgram) glyphs[address&63]=v&31;
        else ram[address&127]=v;
        // Entry mode advances the address and optionally scrolls the viewport.
        step(increment);
        if (!cgram && entry_shift) shift=(shift+(increment?1:39))%40;
    // Commands are decoded by their highest set bit, from address selection
    // down to clear/home. Those last two operations have longer busy times.
    } else if (v&128) { address=v&127;cgram=false; }
    else if (v&64) { address=v&63;cgram=true; }
    else if (v&32) { two_lines=(v&8)!=0; } // 8-bit transfer, 5x8 glyphs only.
    else if (v&16) {
        if (v&8) shift=(shift+((v&4)?39:1))%40;
        else step((v&4)!=0);
    } else if (v&8) { display=v&4;cursor=v&2;blink=v&1; }
    else if (v&4) { increment=v&2;entry_shift=v&1; }
    else if (v&2) { address=0;cgram=false;shift=0;busy_until=cycles+11207; }
    else if (v&1) {
        ram.fill(' ');address=0;cgram=false;shift=0;increment=true;
        busy_until=cycles+11207;
    }
}
uint8_t LCDModel::read(bool data) {
    // Status remains readable while busy. Data reads use a simplified direct
    // memory access rather than the physical controller's prefetch pipeline.
    if (!data) return status();
    if (busy()) return 0xff;
    uint8_t v=cgram?glyphs[address&63]:ram[address&127];
    step(increment);busy_until=cycles+273;
    return v;
}
