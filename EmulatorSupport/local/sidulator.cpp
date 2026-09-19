// Local SID-Ulator port adapter. GPL-2.0-or-later; links to libresidfp.
#include "sidulator.h"
#include <residfp/residfp.h>
#include <SDL.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <string>

// A single SID instance is advanced synchronously with the Z80. SDL consumes
// queued samples asynchronously, but never accesses this synthesiser state.
static std::unique_ptr<reSIDfp::residfp> sid;
static SDL_AudioDeviceID device;
static FILE *wav;
// fraction retains the remainder when converting CPU cycles into SID cycles.
static uint64_t wav_bytes, fraction;
static unsigned sid_clock, reg_port, selected;
static double gain;
// Batch samples to keep audio queue and file writes out of the per-sample path.
static short pending[512];
static unsigned used;
static bool started;
static constexpr unsigned CPU_CLOCK = 7372800, SAMPLE_RATE = 48000;

static const char *setting(const char *name, const char *fallback)
{
    const char *value = std::getenv(name);
    return value ? value : fallback;
}
static double number(const char *name, double fallback, double low, double high)
{
    const char *s = std::getenv(name);
    if (!s) return fallback;
    // Reject trailing text, non-finite numbers and unsupported ranges early.
    char *end;
    double value = std::strtod(s, &end);
    if (!*s || *end || !std::isfinite(value) || value < low || value > high)
        throw std::runtime_error(std::string("Invalid ") + name);
    return value;
}
static void le32(unsigned char *p, uint32_t v)
{
    for (int i=0; i<4; ++i) p[i] = (v >> (8*i)) & 255;
}
static void header()
{
    // Mono 16-bit PCM uses a fixed 44-byte RIFF header. Rewrite it at shutdown
    // once the actual recording length is known; fields are little-endian.
    unsigned char h[44] = {};
    std::memcpy(h, "RIFF", 4); le32(h+4, 36 + wav_bytes);
    std::memcpy(h+8, "WAVEfmt ", 8); le32(h+16, 16);
    h[20]=1; h[22]=1; le32(h+24, SAMPLE_RATE); le32(h+28, SAMPLE_RATE*2);
    h[32]=2; h[34]=16; std::memcpy(h+36, "data",4); le32(h+40,wav_bytes);
    std::rewind(wav);
    if (std::fwrite(h,1,44,wav)!=44) throw std::runtime_error("WAV header write failed");
}
static void flush()
{
    if (!used) return;
    if (wav) {
        if (wav_bytes + used*2 > UINT32_MAX-36) throw std::runtime_error("WAV exceeds 4 GiB");
        // WAV byte order is fixed, unlike the native-endian SDL sample format.
        unsigned char bytes[1024];
        for (unsigned i=0;i<used;i++) {
            uint16_t v=static_cast<uint16_t>(pending[i]);
            bytes[i*2]=v & 255; bytes[i*2+1]=v>>8;
        }
        if (std::fwrite(bytes,2,used,wav)!=used) throw std::runtime_error("WAV write failed");
        wav_bytes+=used*2;
    }
    if (device) {
        if (SDL_QueueAudio(device,pending,used*sizeof(short)))
            throw std::runtime_error(SDL_GetError());
        // Start after a small cushion to absorb host scheduling jitter.
        if (!started && SDL_GetQueuedAudioSize(device)>=2048) {
            SDL_PauseAudioDevice(device,0); started=true;
        }
    }
    used=0;
}
static void fail(const std::exception &e)
{
    std::fprintf(stderr,"SID-Ulator: %s\n",e.what());
    std::exit(1);
}
extern "C" int sidulator_init(void)
{
    // The plain executable interface is opt-in; sound.conf selects the model
    // for launchers. Register atexit once synthesis exists, even before I/O.
    const char *model=setting("RC2014_SID","off");
    if (!std::strcmp(model,"off")) return 0;
    try {
        if (std::strcmp(model,"8580") && std::strcmp(model,"6581"))
            throw std::runtime_error("RC2014_SID must be off, 8580 or 6581");
        double clock_value=number("RC2014_SID_CLOCK",1000000,900000,1100000);
        double port_value=number("RC2014_SID_PORT",212,0,254);
        if (clock_value!=std::floor(clock_value) || port_value!=std::floor(port_value))
            throw std::runtime_error("SID clock and port must be integers");
        sid_clock=static_cast<unsigned>(clock_value);
        reg_port=static_cast<unsigned>(port_value);
        if (reg_port!=212 && reg_port!=164 && reg_port!=84 && reg_port!=36)
            throw std::runtime_error("RC2014_SID_PORT must be 212, 164, 84 or 36");
        gain=number("RC2014_SID_GAIN",0.5,0,1);
        const char *output=setting("RC2014_SID_OUTPUT","audio");
        bool audio=!std::strcmp(output,"audio") || !std::strcmp(output,"both");
        bool record=!std::strcmp(output,"wav") || !std::strcmp(output,"both");
        if (!audio && !record) throw std::runtime_error("RC2014_SID_OUTPUT must be audio, wav or both");
        sid.reset(new reSIDfp::residfp);
        std::atexit(sidulator_close);
        sid->setChipModel(!std::strcmp(model,"6581") ? reSIDfp::MOS6581 : reSIDfp::CSG8580);
        sid->setSamplingParameters(sid_clock,reSIDfp::RESAMPLE,SAMPLE_RATE);
        sid->reset();
        // Let the analogue model settle before connecting the host output.
        short warmup[128];
        for (unsigned i=0;i<sid_clock/1000;i++) sid->clock(1000,warmup);
        if (record) {
            const char *path=std::getenv("RC2014_SID_WAV");
            if (!path || !*path) throw std::runtime_error("Set RC2014_SID_WAV to a new recording filename");
            wav=std::fopen(path,"wbx"); // Never overwrite an existing recording.
            if (!wav) throw std::runtime_error("Cannot create WAV file (must not already exist)");
            header();
        }
        if (audio) {
            // The terminal owns exit signals. Request the exact sample format
            // so the queue can receive the synthesiser's mono samples directly.
            SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS,"1");
            if (SDL_InitSubSystem(SDL_INIT_AUDIO)) throw std::runtime_error(SDL_GetError());
            SDL_AudioSpec spec={};
            spec.freq=SAMPLE_RATE; spec.format=AUDIO_S16SYS; spec.channels=1; spec.samples=512;
            device=SDL_OpenAudioDevice(nullptr,0,&spec,nullptr,0);
            if (!device) throw std::runtime_error(SDL_GetError());
        }
        std::fprintf(stderr,"SID-Ulator: %s, %u Hz, ports %02X/%02X, %s output\n",model,sid_clock,reg_port,reg_port+1,output);
        return 1;
    } catch (const std::exception &e) { fail(e); }
    return 0;
}
extern "C" int sidulator_write(uint16_t port,uint8_t value)
{
    if (!sid) return 0;
    // SID-Ulator uses a selector/data pair and decodes only low address bits.
    // Registers 25-31 are not writable synthesis registers in this model.
    port &= 255;
    if (port==reg_port) { selected=value & 31; return 1; }
    if (port==reg_port+1) {
        if (selected<=24) sid->write(selected,value);
        return 1;
    }
    return 0;
}
extern "C" void sidulator_advance(unsigned z80_cycles)
{
    if (!sid) return;
    try {
        // Preserve fractional clock conversion across calls to avoid pitch
        // drift from rounding every instruction or emulator execution chunk.
        fraction+=static_cast<uint64_t>(z80_cycles)*sid_clock;
        unsigned cycles=fraction/CPU_CLOCK;
        fraction%=CPU_CLOCK;
        // Bound each synthesis call so its worst-case output fits the buffer.
        while (cycles) {
            unsigned step=std::min(cycles,1000u);
            short samples[128]; // <=54 samples for 1000 cycles at supported clocks.
            int count=sid->clock(step,samples);
            for (int i=0;i<count;i++) {
                pending[used++]=static_cast<short>(std::lround(samples[i]*gain));
                if (used==512) flush();
            }
            cycles-=step;
        }
    } catch (const std::exception &e) { fail(e); }
}
extern "C" int sidulator_pace(void)
{
    if (!device) return 0;
    // Audio consumption paces the CPU; avoid adding a second 20ms sleep.
    // Return regularly even if the audio device stops consuming data.
    for (int i=0;i<100 && SDL_GetQueuedAudioSize(device)>4096;i++) SDL_Delay(1);
    if (SDL_GetQueuedAudioSize(device)>48000) {
        std::fprintf(stderr,"SID-Ulator: audio device stalled\n"); std::exit(1);
    }
    return 1;
}
extern "C" void sidulator_close(void)
{
    // Preserve the final partial block in recordings. Live output is cleared
    // for prompt exit, so shutdown does not wait for the queued tail to play.
    try { flush(); } catch (const std::exception &e) { std::fprintf(stderr,"SID-Ulator: %s\n",e.what()); }
    if (device) { SDL_ClearQueuedAudio(device); SDL_CloseAudioDevice(device); device=0; SDL_QuitSubSystem(SDL_INIT_AUDIO); }
    if (wav) {
        try { header(); } catch (const std::exception &e) { std::fprintf(stderr,"SID-Ulator: %s\n",e.what()); }
        std::fclose(wav); wav=nullptr;
    }
    sid.reset();
}
