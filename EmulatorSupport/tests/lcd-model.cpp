#include "../local/lcd_model.h"
#include <cassert>
#include <cstdio>
static void command(LCDModel &m,unsigned v) {m.advance(12000);m.write(false,v);}
static void data(LCDModel &m,unsigned v) {m.advance(300);m.write(true,v);}
int main() {
 LCDModel m;command(m,0x38);command(m,0x0f);command(m,1);
 assert(m.busy() && (m.status()&128));m.write(true,'X');assert(m.ram[0]==' ');
 m.advance(11207);assert(!m.busy());m.write(true,'A');assert(m.ram[0]=='A' && m.address==1);
 command(m,0xc0);data(m,'B');assert(m.visible(1,0)=='B');
 command(m,0x08);assert(!m.display && m.ram[0]=='A');command(m,0x0c);assert(m.display);
 command(m,0xa7);data(m,'Z');assert(m.address==0x40);data(m,'C');assert(m.ram[64]=='C');
 command(m,0x18);assert(m.shift==1 && m.visible(0,39)=='A');
 command(m,0x1c);assert(m.shift==0);command(m,0x18);command(m,2);assert(m.shift==0 && m.address==0 && m.ram[0]=='A');
 command(m,0x40);unsigned glyph[]={14,21,31,31,14,21,21,21};for(auto v:glyph)data(m,v);
 command(m,0x80);data(m,0);assert(m.visible(0,0)==0 && m.glyphs[7]==21);
 command(m,0x40);m.advance(300);assert(m.read(true)==14 && m.address==1 && m.busy());
 command(m,0xc0);m.advance(300);assert(m.read(true)=='C' && m.address==0x41);
 command(m,0x04);command(m,0x80);data(m,'D');assert(m.address==0x67);
 command(m,0x07);command(m,0x80);data(m,'E');assert(m.shift==1 && m.address==1);
 command(m,0x10);assert(m.address==0);command(m,0x14);assert(m.address==1);
 command(m,1);assert(m.shift==0 && m.address==0 && m.increment && m.ram[64]==' ' && m.glyphs[0]==14);
 std::puts("PASS: busy rejection/status, DDRAM line wrap, clear/home, visibility, shifts, CGRAM and data reads");
}
