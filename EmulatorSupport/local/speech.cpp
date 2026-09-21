// Provisional MG005/SP0256-AL2 adapter. GPL-2.0-or-later.
#include "speech.h"
#include <SDL.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <stdexcept>
#include <string>
#include <vector>

static constexpr unsigned CPU_HZ = 7372800;
static constexpr unsigned SAMPLE_HZ = 48000;
static unsigned port_number = 31, ready_bit = 2, fallback_ms = 120;
static uint64_t busy_cycles;
static SDL_AudioDeviceID audio_device;
static std::string sample_directory;
static FILE *trace_file;
static bool enabled;

static unsigned setting(const char *name, unsigned fallback, unsigned maximum)
{
    const char *text = std::getenv(name);
    if (!text || !*text) return fallback;
    char *end = nullptr;
    unsigned long value = std::strtoul(text, &end, 0);
    if (*end || value > maximum) throw std::runtime_error(std::string("Invalid ") + name);
    return static_cast<unsigned>(value);
}

static void play_sample(unsigned code)
{
    if (!audio_device || sample_directory.empty()) return;
    char name[16];
    std::snprintf(name, sizeof(name), "/%02u.wav", code);
    const std::string path = sample_directory + name;
    SDL_AudioSpec source;
    Uint8 *bytes = nullptr;
    Uint32 length = 0;
    if (!SDL_LoadWAV(path.c_str(), &source, &bytes, &length)) return;
    SDL_AudioCVT conversion;
    if (SDL_BuildAudioCVT(&conversion, source.format, source.channels, source.freq,
                          AUDIO_S16SYS, 1, SAMPLE_HZ) < 0) {
        SDL_FreeWAV(bytes);
        throw std::runtime_error(SDL_GetError());
    }
    std::vector<Uint8> converted(length * conversion.len_mult);
    std::memcpy(converted.data(), bytes, length);
    SDL_FreeWAV(bytes);
    conversion.buf = converted.data();
    conversion.len = static_cast<int>(length);
    if (SDL_ConvertAudio(&conversion) < 0) throw std::runtime_error(SDL_GetError());
    if (SDL_QueueAudio(audio_device, converted.data(), conversion.len_cvt) < 0)
        throw std::runtime_error(SDL_GetError());
    SDL_PauseAudioDevice(audio_device, 0);
    // LRQ timing is provisional. Use the recorded sound's duration when present.
    busy_cycles = static_cast<uint64_t>(conversion.len_cvt / 2) * CPU_HZ / SAMPLE_HZ;
}

extern "C" int speech_init(void)
{
    const char *mode = std::getenv("RC2014_SPEECH");
    if (mode && !std::strcmp(mode, "off")) return 0;
    if (mode && std::strcmp(mode, "on")) { std::fprintf(stderr, "RC2014_SPEECH must be on or off\n"); std::exit(1); }
    try {
        port_number = setting("RC2014_SPEECH_PORT", 31, 255);
        ready_bit = setting("RC2014_SPEECH_READY_BIT", 2, 255);
        if (!ready_bit || (ready_bit & (ready_bit - 1)))
            throw std::runtime_error("RC2014_SPEECH_READY_BIT must be one bit");
        fallback_ms = setting("RC2014_SPEECH_FALLBACK_MS", 120, 2000);
        const char *directory = std::getenv("RC2014_SPEECH_SAMPLES");
        if (directory) sample_directory = directory;
        else if (std::filesystem::is_directory("speech-samples")) sample_directory = "speech-samples";
        const char *trace = std::getenv("RC2014_SPEECH_TRACE");
        if (trace && *trace) {
            trace_file = std::fopen(trace, "wx");
            if (!trace_file) throw std::runtime_error("Cannot create speech trace");
            std::fputs("code\n", trace_file);
        }
        if (!sample_directory.empty()) {
            if (SDL_InitSubSystem(SDL_INIT_AUDIO)) throw std::runtime_error(SDL_GetError());
            SDL_AudioSpec wanted = {};
            wanted.freq = SAMPLE_HZ; wanted.format = AUDIO_S16SYS;
            wanted.channels = 1; wanted.samples = 1024;
            audio_device = SDL_OpenAudioDevice(nullptr, 0, &wanted, nullptr, 0);
            if (!audio_device) throw std::runtime_error(SDL_GetError());
        }
        enabled = true;
        std::atexit(speech_close);
        return 1;
    } catch (const std::exception &e) {
        std::fprintf(stderr, "MG005: %s\n", e.what());
        std::exit(1);
    }
}

extern "C" int speech_write(uint16_t port, uint8_t value)
{
    if (!enabled || (port & 255) != port_number) return 0;
    if (busy_cycles) return 1; // An ALD pulse while LRQ is low is not accepted.
    const unsigned code = value & 63;
    if (trace_file) { std::fprintf(trace_file, "%u\n", code); std::fflush(trace_file); }
    busy_cycles = static_cast<uint64_t>(fallback_ms) * CPU_HZ / 1000;
    try { play_sample(code); }
    catch (const std::exception &e) { std::fprintf(stderr, "MG005: %s\n", e.what()); std::exit(1); }
    return 1;
}

extern "C" int speech_read(uint16_t port, uint8_t *value)
{
    if (!enabled || (port & 255) != port_number) return 0;
    *value = busy_cycles ? 0 : ready_bit;
    return 1;
}

extern "C" void speech_advance(unsigned cycles)
{
    if (!enabled) return;
    busy_cycles = cycles >= busy_cycles ? 0 : busy_cycles - cycles;
}

extern "C" void speech_close(void)
{
    if (trace_file) { std::fclose(trace_file); trace_file = nullptr; }
    if (audio_device) { SDL_CloseAudioDevice(audio_device); audio_device = 0; SDL_QuitSubSystem(SDL_INIT_AUDIO); }
    enabled = false;
}
