// HD44780-compatible 8-bit, two-line, 5x8 model. GPL-2.0-or-later.
#ifndef RC2014_LCD_MODEL_H
#define RC2014_LCD_MODEL_H
#include <array>
#include <cstdint>
// Controller state is independent of SDL: guest instructions advance it in CPU
// cycles, while the window only reads it to draw the visible portion of DDRAM.
class LCDModel {
public:
    // DDRAM holds character codes; CGRAM holds eight custom 5x8 glyphs.
    // DDRAM addresses include the gap between the two 40-character lines.
    std::array<uint8_t,128> ram{};
    std::array<uint8_t,64> glyphs{};
    // The address counter selects either memory; shift moves the viewport,
    // not the characters stored in DDRAM.
    uint8_t address=0, shift=0;
    bool cgram=false, increment=true, entry_shift=false;
    // Display controls affect rendering without discarding stored text.
    bool display=false, cursor=false, blink=false, two_lines=false;
    // Busy deadlines use emulated time, so host scheduling cannot shorten them.
    uint64_t cycles=0, busy_until=0;
    // Start with blank display memory; custom glyph memory is zero-initialised.
    LCDModel() { ram.fill(' '); }
    void advance(unsigned n) { cycles+=n; }
    bool busy() const { return cycles<busy_until; }
    // Status combines the busy flag in bit 7 and the current address counter.
    uint8_t status() const { return (busy()?128:0)|address; }
    void step(bool right);
    void write(bool data,uint8_t value);
    uint8_t read(bool data);
    uint8_t visible(unsigned row,unsigned col) const {
        // Each row exposes 16 cells from a wrapping 40-character backing line.
        return ram[(row?64:0)+(col+shift)%40];
    }
    bool cursor_at(unsigned row,unsigned col) const {
        // A CGRAM address selects glyph data, so it has no on-screen cursor.
        return !cgram && address==(row?64:0)+(col+shift)%40;
    }
};
#endif
