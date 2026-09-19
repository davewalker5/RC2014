// Exercise the real SDL handlers and port adapter. GPL-2.0-or-later.
#include "../local/digitalio.cpp"
#include "../local/lcd.h"
#include <cassert>
int main(int argc,char **argv) {
    setenv("RC2014_DIO","on",1);setenv("RC2014_LCD","on",1);
    assert(lcd_init());assert(digitalio_init());
    uint8_t value=99;assert(digitalio_read(input_port,&value)&&value==0);
    assert(!digitalio_read(5,&value));assert(!digitalio_write(5,255));
    assert(digitalio_write(0xAB00|output_port,165));assert(outputs==165);
    Uint32 id=SDL_GetWindowID(window);
    SDL_Event e={};e.type=SDL_KEYDOWN;e.key.windowID=id;e.key.keysym.sym=SDLK_0;digitalio_event(e);
    e.key.keysym.sym=SDLK_7;digitalio_event(e);
    assert(digitalio_read(0xFF00|input_port,&value)&&value==129);
    e.type=SDL_KEYUP;e.key.keysym.sym=SDLK_0;digitalio_event(e);assert(inputs()==128);
    e.type=SDL_WINDOWEVENT;e.window.windowID=id;e.window.event=SDL_WINDOWEVENT_FOCUS_LOST;digitalio_event(e);assert(inputs()==0);
    e={};e.type=SDL_MOUSEBUTTONDOWN;e.button.windowID=id;e.button.button=SDL_BUTTON_LEFT;
    e.button.x=26+7*80+10;e.button.y=170;digitalio_event(e);assert(inputs()==1);
    e.type=SDL_MOUSEBUTTONUP;digitalio_event(e);assert(inputs()==0);
    e.type=SDL_MOUSEBUTTONDOWN;e.button.y=230;digitalio_event(e);assert(inputs()==1);
    e.button.x=26+6*80+10;digitalio_event(e);assert(inputs()==3);
    e={};e.type=SDL_WINDOWEVENT;e.window.windowID=id;e.window.event=SDL_WINDOWEVENT_FOCUS_LOST;digitalio_event(e);assert(inputs()==3);
    // Events for another window must not alter/hide this panel.
    e.window.windowID=id+999;e.window.event=SDL_WINDOWEVENT_CLOSE;digitalio_event(e);
    assert(!(SDL_GetWindowFlags(window)&SDL_WINDOW_HIDDEN));assert(inputs()==3);
    digitalio_frame();
    if(argc>1) {
        SDL_Surface *s=SDL_CreateRGBSurfaceWithFormat(0,WIDTH,HEIGHT,32,SDL_PIXELFORMAT_ARGB8888);
        assert(s);assert(SDL_RenderReadPixels(renderer,nullptr,SDL_PIXELFORMAT_ARGB8888,s->pixels,s->pitch)==0);
        assert(SDL_SaveBMP(s,argv[1])==0);SDL_FreeSurface(s);
    }
    e={};e.type=SDL_KEYDOWN;e.key.windowID=id;e.key.keysym.sym=SDLK_SPACE;digitalio_event(e);assert(inputs()==0);
    e={};e.type=SDL_WINDOWEVENT;e.window.windowID=id;e.window.event=SDL_WINDOWEVENT_CLOSE;SDL_PushEvent(&e);peripheral_events();
    assert(SDL_GetWindowFlags(window)&SDL_WINDOW_HIDDEN);
    uint8_t status;assert(lcd_write(218,0x38));assert(lcd_read(218,&status));
    digitalio_close();lcd_close();
    puts("PASS: ports, keys, mouse, latch, focus release, window routing and simultaneous LCD");
}
