// LCD controller window and RC2014 port adapter. GPL-2.0-or-later.
#include "lcd.h"
#include "digitalio.h"
#include "lcd_model.h"
#include "lcd_font.h" // Adafruit classic bitmap font; see LICENSE.font.
#include <SDL.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>

// The controller owns guest-visible memory and timing. These objects only
// adapt its ports and draw it, all on the emulator's main thread.
static LCDModel lcd;
static bool enabled=false, closed=false;
static unsigned port=218;
static SDL_Window *window;
static SDL_Renderer *renderer;
static constexpr int WIDTH=640, HEIGHT=204;

static void rectangle(int x,int y,int w,int h,Uint8 r,Uint8 g,Uint8 b) {
    SDL_SetRenderDrawColor(renderer,r,g,b,255);
    SDL_Rect rect={x,y,w,h};SDL_RenderFillRect(renderer,&rect);
}
static void render(const char *snapshot=nullptr) {
    if (!renderer) return;
    rectangle(0,0,WIDTH,HEIGHT,30,53,44);
    // Mounting holes and bezel around a green LCD glass panel.
    for (int x: {12,WIDTH-22}) for (int y: {12,HEIGHT-22}) {
        rectangle(x,y,10,10,166,169,147);rectangle(x+3,y+3,4,4,22,32,26);
    }
    rectangle(22,26,596,152,13,22,17);
    rectangle(27,31,586,142,174,198,103);
    // Blink is a visual host-time effect; controller busy timing uses CPU time.
    bool phase=(SDL_GetTicks()/400)%2==0;
    for (unsigned row=0;row<2;row++) for(unsigned col=0;col<16;col++) {
        uint8_t code=lcd.visible(row,col);
        bool cursor=lcd.cursor_at(row,col);
        for(unsigned y=0;y<8;y++) for(unsigned x=0;x<5;x++) {
            // Codes 0-15 alias eight CGRAM glyphs, stored as horizontal rows.
            // The ordinary font instead stores vertical columns.
            bool on=code<16 ? ((lcd.glyphs[(code&7)*8+y]>>(4-x))&1) : ((font[code*5+x]>>y)&1);
            if (cursor && ((lcd.cursor && y==7) || (lcd.blink && phase))) on=true;
            // Blank the display without changing character or glyph memory.
            on=on && lcd.display && (row==0 || lcd.two_lines);
            rectangle(34+col*36+x*6,45+row*64+y*6,5,5,on?39:162,on?65:187,on?32:96);
        }
    }
    // Capture before presenting while the completed frame is still available.
    if (snapshot && *snapshot) {
        if (access(snapshot,F_OK)==0) std::fprintf(stderr,"LCD: snapshot exists; not overwritten\n");
        else {
            SDL_Surface *s=SDL_CreateRGBSurfaceWithFormat(0,WIDTH,HEIGHT,32,SDL_PIXELFORMAT_ARGB8888);
            if (!s || SDL_RenderReadPixels(renderer,nullptr,SDL_PIXELFORMAT_ARGB8888,s?s->pixels:nullptr,s?s->pitch:0)<0 || SDL_SaveBMP(s,snapshot)<0)
                std::fprintf(stderr,"LCD snapshot: %s\n",SDL_GetError());
            if (s) SDL_FreeSurface(s);
        }
    }
    SDL_RenderPresent(renderer);
}
extern "C" void lcd_close() {
    // Cleanup may be requested explicitly as well as through atexit.
    if (!enabled || closed) return;
    closed=true;
    // Capture diagnostics before destroying the renderer or SDL video state.
    render(std::getenv("RC2014_LCD_SNAPSHOT"));
    const char *path=std::getenv("RC2014_LCD_DUMP");
    if (path && *path) {
        FILE *f=std::fopen(path,"wx");
        if (!f) std::fprintf(stderr,"LCD: cannot create state dump (choose a new filename)\n");
        else {
            // Numeric character codes preserve custom glyphs and non-ASCII
            // bytes that could not be represented faithfully as display text.
            std::fprintf(f,"{\"display\":%s,\"shift\":%u,\"address\":%u,\"rows\":[",lcd.display?"true":"false",lcd.shift,lcd.address);
            for(unsigned r=0;r<2;r++) {
                std::fprintf(f,"%s[",r?",":"");
                for(unsigned c=0;c<16;c++)std::fprintf(f,"%s%u",c?",":"",lcd.visible(r,c));
                std::fprintf(f,"]");
            }
            std::fprintf(f,"],\"cgram\":[");
            for(unsigned i=0;i<64;i++)std::fprintf(f,"%s%u",i?",":"",lcd.glyphs[i]);
            std::fprintf(f,"]}\n");std::fclose(f);
        }
    }
    if(renderer)SDL_DestroyRenderer(renderer);
    if(window)SDL_DestroyWindow(window);
    renderer=nullptr;window=nullptr;SDL_QuitSubSystem(SDL_INIT_VIDEO);
}
extern "C" int lcd_init() {
    // Launchers opt in; direct use defaults to no display window.
    const char *mode=std::getenv("RC2014_LCD");
    if (!mode || !std::strcmp(mode,"off"))return 0;
    if (std::strcmp(mode,"on")) { std::fprintf(stderr,"RC2014_LCD must be on or off\n");std::exit(1); }
    // These four base addresses match the physical module's port choices.
    const char *p=std::getenv("RC2014_LCD_PORT");
    if(p) { char *end;long n=std::strtol(p,&end,10);
        if(!*p || *end || (n!=218 && n!=170 && n!=90 && n!=42)) {std::fprintf(stderr,"Invalid RC2014_LCD_PORT\n");std::exit(1);}port=n;
    }
    // Preserve the emulator's terminal signal handling. Video initialisation
    // is reference-counted so closing another peripheral does not tear it down.
    SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS,"1");
    if(SDL_InitSubSystem(SDL_INIT_VIDEO)<0) {std::fprintf(stderr,"LCD: %s\n",SDL_GetError());std::exit(1);}
    char title[100];std::snprintf(title,sizeof(title),"RC2014 LCD | 16 x 2 | %02X/%02X",port,port+1);
    // Fixed pixel dimensions keep screenshot capture and dot spacing predictable.
    window=SDL_CreateWindow(title,SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,WIDTH,HEIGHT,SDL_WINDOW_SHOWN);
    if(window)renderer=SDL_CreateRenderer(window,-1,SDL_RENDERER_SOFTWARE);
    if(!renderer) {std::fprintf(stderr,"LCD: %s\n",SDL_GetError());std::exit(1);}
    enabled=true;std::atexit(lcd_close);render();
    std::fprintf(stderr,"LCD: 16x2, ports %02X/%02X; type BASIC in Terminal; close window to hide it\n",port,port+1);
    return 1;
}
// Called with elapsed emulated CPU cycles, including time before port access.
extern "C" void lcd_advance(unsigned n) {if(enabled)lcd.advance(n);}
extern "C" int lcd_write(uint16_t p,uint8_t v) {
    // Ignore upper address bits; base selects command/status, base+1 data.
    // Return one only for a port owned by this enabled peripheral.
    if(!enabled)return 0;p&=255;
    if(p!=port && p!=port+1)return 0;lcd.write(p==port+1,v);return 1;
}
extern "C" int lcd_read(uint16_t p,uint8_t *v) {
    // Ignore upper address bits; base selects command/status, base+1 data.
    // Return one only for a port owned by this enabled peripheral.
    if(!enabled)return 0;p&=255;
    if(p!=port && p!=port+1)return 0;*v=lcd.read(p==port+1);return 1;
}
void lcd_event(const SDL_Event &e) {
    if(!enabled || closed)return;
    // Closing a display hides it without terminating the guest or other panel.
    if(e.type==SDL_QUIT || (e.type==SDL_WINDOWEVENT && e.window.windowID==SDL_GetWindowID(window) && e.window.event==SDL_WINDOWEVENT_CLOSE))
        SDL_HideWindow(window);
}
void lcd_frame() { if(enabled && !closed)render(); }
