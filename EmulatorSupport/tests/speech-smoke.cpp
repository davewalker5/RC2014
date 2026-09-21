#include "../local/speech.h"
#include <cassert>
int main()
{
    assert(speech_init());
    uint8_t status = 0;
    assert(!speech_read(30, &status));
    assert(speech_read(31, &status) && status == 2);
    assert(speech_write(31, 27));
    assert(speech_read(31, &status) && status == 0);
    assert(speech_write(31, 55)); // busy write is ignored
    speech_advance(7372800);
    assert(speech_read(31, &status) && status == 2);
    assert(speech_write(0x121f, 0x40)); // high address ignored; six-bit code
    assert(speech_read(31, &status) && status == 0);
    speech_close();
}
