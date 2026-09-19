// RC2014 Digital I/O v2 port adapter and interactive panel. GPL-2.0-or-later.
#include "digitalio.h"
#include "lcd_font.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>

// One card instance lives on the emulator thread; SDL handlers and port
// accesses share this state without a separate UI thread or locking.
static SDL_Window *window;
static SDL_Renderer *renderer;
static bool enabled=false, closed=false;
static unsigned input_port=1, output_port=1;
// Separate input sources prevent releasing a key from clearing a latched bit.
// Output is an independent hardware-style latch, not a copy of the inputs.
static uint8_t keys=0, mouse=0, held=0, outputs=0;
static Uint32 last_frame;
static constexpr int WIDTH=680, HEIGHT=330;
// A bit reads high while any input source holds it active.
static uint8_t inputs() { return keys | mouse | held; }
static void rect(int x,int y,int w,int h,int r,int g,int b) {
    SDL_SetRenderDrawColor(renderer,r,g,b,255);
    SDL_Rect box={x,y,w,h}; SDL_RenderFillRect(renderer,&box);
}
static void text(int x,int y,const char *s,int scale=2) {
    // Font bytes are vertical columns; one extra column separates characters.
    for (;*s;s++,x+=6*scale)
        for(int col=0;col<5;col++) for(int row=0;row<8;row++)
            if ((font[static_cast<unsigned char>(*s)*5+col]>>row)&1)
                rect(x+col*scale,y+row*scale,scale,scale,220,234,222);
}
static void circle(int x,int y,int radius,bool on) {
    // Fill a small circular LED directly; no texture or external image needed.
    SDL_SetRenderDrawColor(renderer,on?86:31,on?244:78,on?110:49,255);
    for(int dy=-radius;dy<=radius;dy++) for(int dx=-radius;dx<=radius;dx++)
        if(dx*dx+dy*dy<=radius*radius) SDL_RenderDrawPoint(renderer,x+dx,y+dy);
}
void digitalio_frame() {
    if(!renderer)return;
    rect(0,0,WIDTH,HEIGHT,24,45,38);
    text(26,20,"RC2014  DIGITAL I/O");
    char label[100];
    std::snprintf(label,sizeof(label),"INPUT %u: %3u    OUTPUT %u: %3u",input_port,inputs(),output_port,outputs);
    text(26,48,label);
    // Keep bit 7 at the left, as in a conventional written binary byte.
    for(int column=0;column<8;column++) {
        int bit=7-column,x=26+column*80;
        circle(x+28,102,16,outputs&(1<<bit));
        char n[2]={static_cast<char>('0'+bit),0};text(x+23,129,n);
        bool down=inputs()&(1<<bit);
        rect(x,158,56,48,down?91:61,down?132:78,down?95:69);
        text(x+22,174,n);
        rect(x,218,56,30,held&(1<<bit)?79:37,held&(1<<bit)?117:62,held&(1<<bit)?83:51);
        text(x+5,229,"HOLD",1);
    }
    text(26,266,"CLICK / HOLD KEYS 0-7 = PRESS",1);
    text(26,283,"HOLD = LATCH INPUT    SPACE = RELEASE ALL",1);
    text(26,300,"TYPE BASIC IN TERMINAL; CLOSE HIDES THIS PANEL",1);
    SDL_RenderPresent(renderer);
}
void digitalio_event(const SDL_Event &e) {
    if(!enabled || closed)return;
    // SDL has one event queue for both windows: only act on our own events,
    // except global quit and mouse release, which must also clear held input.
    Uint32 id=SDL_GetWindowID(window);
    if(e.type==SDL_QUIT) { keys=mouse=held=0;SDL_HideWindow(window); }
    if(e.type==SDL_WINDOWEVENT && e.window.windowID==id) {
        // A release can be lost when focus moves to Terminal. Clear momentary
        // inputs, but preserve intentional HOLD selections for BASIC to read.
        if(e.window.event==SDL_WINDOWEVENT_FOCUS_LOST)keys=mouse=0;
        if(e.window.event==SDL_WINDOWEVENT_CLOSE) {keys=mouse=held=0;SDL_HideWindow(window);}
    }
    if((e.type==SDL_KEYDOWN || e.type==SDL_KEYUP) && e.key.windowID==id) {
        SDL_Keycode key=e.key.keysym.sym;
        // Set/clear individual bits so simultaneous keys work and repeats
        // cannot toggle an already pressed input.
        if(key>=SDLK_0 && key<=SDLK_7) {
            uint8_t mask=1<<(key-SDLK_0);
            if(e.type==SDL_KEYDOWN)keys|=mask;else keys&=~mask;
        }
        if(key==SDLK_SPACE && e.type==SDL_KEYDOWN)keys=mouse=held=0;
    }
    if(e.type==SDL_MOUSEBUTTONUP && e.button.button==SDL_BUTTON_LEFT) {
        // Release even outside the panel after dragging away from a button.
        mouse=0;SDL_CaptureMouse(SDL_FALSE);
    }
    if(e.type==SDL_MOUSEBUTTONDOWN && e.button.windowID==id && e.button.button==SDL_BUTTON_LEFT) {
        // Match the drawing geometry; gaps between buttons are not clickable.
        int x=e.button.x-26,column=x/80,y=e.button.y;
        if(x>=0 && column<8 && x%80<56) {
            uint8_t mask=1<<(7-column);
            if(y>=158 && y<206) {mouse=mask;SDL_CaptureMouse(SDL_TRUE);}
            if(y>=218 && y<248)held^=mask;
        }
    }
}
extern "C" void peripheral_events() {
    SDL_Event e;
    // A single dispatcher prevents one window from consuming another's events.
    while(SDL_PollEvent(&e)) { lcd_event(e); digitalio_event(e); }
    // Drain events on every call, but limit drawing to roughly 50 frames/sec.
    if(SDL_GetTicks()-last_frame>=20) {
        lcd_frame();digitalio_frame();last_frame=SDL_GetTicks();
    }
}
static unsigned port_setting(const char *name) {
    // The v2 card has separate input/output links, each selecting ports 0-3.
    const char *s=std::getenv(name);if(!s)return 1;
    char *end;long n=std::strtol(s,&end,10);
    if(!*s || *end || n<0 || n>3) {
        std::fprintf(stderr,"%s must be 0, 1, 2 or 3\n",name);std::exit(1);
    }
    return n;
}
extern "C" int digitalio_init() {
    // Direct executable use is opt-in; the launchers supply the on default.
    const char *mode=std::getenv("RC2014_DIO");
    if(!mode || !std::strcmp(mode,"off"))return 0;
    if(std::strcmp(mode,"on")) {std::fprintf(stderr,"RC2014_DIO must be on or off\n");std::exit(1);}
    input_port=port_setting("RC2014_DIO_INPUT_PORT");output_port=port_setting("RC2014_DIO_OUTPUT_PORT");
    // Leave terminal exit signals with the emulator. SDL reference-counts
    // video initialisation, allowing this panel and the LCD to own it together.
    SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS,"1");
    if(SDL_InitSubSystem(SDL_INIT_VIDEO)<0) {std::fprintf(stderr,"Digital I/O: %s\n",SDL_GetError());std::exit(1);}
    window=SDL_CreateWindow("RC2014 Digital I/O",SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,WIDTH,HEIGHT,SDL_WINDOW_SHOWN);
    if(window)renderer=SDL_CreateRenderer(window,-1,SDL_RENDERER_SOFTWARE);
    if(!renderer) {std::fprintf(stderr,"Digital I/O: %s\n",SDL_GetError());std::exit(1);}
    enabled=true;std::atexit(digitalio_close);digitalio_frame();
    std::fprintf(stderr,"Digital I/O: input %u, output %u; keys 0-7 or mouse; type BASIC in Terminal\n",input_port,output_port);
    return 1;
}
extern "C" int digitalio_read(uint16_t port,uint8_t *value) {
    // Hardware decodes A0-A7 only. Returning zero leaves other ports to the
    // emulator; the value pointer is written only when this card claims a read.
    if(!enabled || (port&255)!=input_port)return 0;
    *value=inputs();return 1;
}
extern "C" int digitalio_write(uint16_t port,uint8_t value) {
    if(!enabled || (port&255)!=output_port)return 0;
    // Retain the byte until the next write, independently of screen refresh.
    outputs=value;return 1;
}
extern "C" void digitalio_close() {
    // Explicit cleanup and atexit may both call here; release resources once.
    if(!enabled || closed)return;closed=true;
    const char *path=std::getenv("RC2014_DIO_DUMP");
    if(path && *path) {
        // Exclusive creation protects previous diagnostic captures.
        FILE *f=std::fopen(path,"wx");
        if(f) {std::fprintf(f,"{\"input\":%u,\"output\":%u}\n",inputs(),outputs);std::fclose(f);}
        else std::fprintf(stderr,"Digital I/O: cannot create dump (choose a new filename)\n");
    }
    SDL_DestroyRenderer(renderer);SDL_DestroyWindow(window);
    renderer=nullptr;window=nullptr;SDL_QuitSubSystem(SDL_INIT_VIDEO);
}
