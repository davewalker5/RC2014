/* Execute the assembled player with the emulator's existing libz80 core.
 * No ROM, audio device or hardware is needed. CSV output records actual I/O
 * and Z80 cycle counts for the Python integration checks. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "z80.h"

static Z80Context cpu;
static uint8_t memory[65536];
static unsigned speech_mode;
static unsigned busy_until;
static unsigned sid_register;
static unsigned failures;

static byte read_memory(int unused, ushort address)
{
    /* libz80 supplies a caller-defined context value to every callback. This
     * harness has one global CPU and memory image, so that value is unused.
     * Reads are ordinary RAM reads: no ROM banking or hardware side effects
     * are modelled. Instruction fetches use this same backing memory. */
    (void)unused;
    return memory[address];
}

static void write_memory(int unused, ushort address, byte value)
{
    (void)unused;
    /* The routine may write its own RAM or the small caller-stack window.
     * E000-FBFF is the permitted image/state region. CF00-D001 includes room
     * for downward-growing stack use and the synthetic return address.
     * Record illegal writes but still perform them, so execution can proceed
     * far enough to expose other failures instead of hiding the corruption. */
    if (!((address >= 0xe000 && address < 0xfc00) ||
          (address >= 0xcf00 && address < 0xd002)))
        failures++;
    memory[address] = value;
}

static byte read_port(int unused, ushort port)
{
    (void)unused;
    /* Match the cards' low-byte address decoding. On a Z80, the upper byte of
     * an immediate IN/OUT address can contain A; it is not a different card.
     * This player should only read the MG005 status port, never SID registers. */
    if ((port & 255) != 31) {
        failures++;
        return 0;
    }
    /* Mode 2 deliberately never asserts ready. Other modes consult a deadline
     * in emulated cycles, making the result independent of host CPU speed.
     * The returned value 2 is bit 1 set, matching the MG005 ready-bit mask. */
    if (speech_mode == 2 || cpu.tstates < busy_until)
        return 0;
    return 2;
}

static void write_port(int unused, ushort port, byte value)
{
    (void)unused;
    /* SID access is a two-port protocol: first select a register on D4, then
     * send its value on D5. Trace completed register writes, not selections,
     * so the Python test can compare them with its expected musical events. */
    switch (port & 255) {
    case 212:
        sid_register = value;
        break;
    case 213:
        if (sid_register > 24)
            failures++;
        printf("S,%u,%u,%u\n", cpu.tstates, sid_register, value);
        break;
    case 31:
        /* A correct scheduler checks readiness before OUT. Detect attempts
         * while busy as failures even though we still log them for diagnosis.
         * Codes outside 0-63 are also invalid for the AL2 allophone interface. */
        if (speech_mode == 2 || cpu.tstates < busy_until || value > 63)
            failures++;
        printf("P,%u,%u\n", cpu.tstates, value);
        /* Model handshake acceptance, not exact SP0256 acoustic behaviour.
         * 7,372,800 cycles/second * 0.120 seconds = 884,736 busy cycles.
         * Mode 0 has no busy interval; neither model generates actual audio
         * or simulates the chip's internal allophone buffer and durations. */
        busy_until = cpu.tstates + (speech_mode == 1 ? 884736 : 0);
        break;
    default:
        /* Unexpected ports could indicate corrupted instructions or incorrect
         * constants. Do not silently let unrelated hardware accesses pass. */
        failures++;
    }
}

int main(int argc, char **argv)
{
    /* Python supplies a binary path and a readiness mode (0, 1 or 2). Exit 2
     * indicates a setup failure; exit 1 below indicates an execution failure.
     * Neither condition is success merely because some trace rows appeared. */
    if (argc != 3)
        return 2;
    FILE *input = fopen(argv[1], "rb");
    if (!input)
        return 2;
    /* Load bytes at their assembly origin without overwriting monitor-reserved
     * memory. Reading one additional byte distinguishes an exactly full image
     * from one that would otherwise be silently truncated to the RAM window. */
    size_t length = fread(memory + 0xe000, 1, 0x1c00, input);
    int extra = fgetc(input);
    fclose(input);
    if (!length || extra != EOF)
        return 2;
    speech_mode = (unsigned)atoi(argv[2]);
    /* Supply the CPU core with this harness's memory and port model. Static
     * storage begins zero-filled; every scenario runs in a fresh process, so
     * there is no CPU, memory or busy-deadline state left from an earlier run. */
    cpu.memRead = read_memory;
    cpu.memWrite = write_memory;
    cpu.ioRead = read_port;
    cpu.ioWrite = write_port;
    /* Pretend a caller has already CALLed E000: place its return address at
     * the top of the stack, low byte first. RET should reach PC=0100 and move
     * SP from D000 to D002. No monitor ROM is needed for that calling contract. */
    cpu.PC = 0xe000;
    cpu.R1.wr.SP = 0xd000;
    memory[0xd000] = 0;
    memory[0xd001] = 1; /* Simulated caller return address 0100. */
    /* Distinct nonzero register values expose missing saves, swapped restores
     * and stack imbalance. A zero-filled register set could accidentally hide
     * such bugs if the routine also happened to leave zero in a register. */
    cpu.R1.wr.AF = 0x1234;
    cpu.R1.wr.BC = 0x5678;
    cpu.R1.wr.DE = 0x9abc;
    cpu.R1.wr.HL = 0xdef0;
    cpu.R1.wr.IX = 0x1357;
    cpu.R1.wr.IY = 0x2468;
    /* Alternate registers should remain untouched. Preserve a full snapshot
     * for comparison, and start with interrupts enabled in mode 1 so an
     * unintended DI or interrupt-mode change can also be detected. We do not
     * inject interrupts here: this checks final state, not interrupt latency. */
    memset(&cpu.R2, 0x5a, sizeof(cpu.R2));
    Z80Regs alternate = cpu.R2;
    cpu.IFF1 = cpu.IFF2 = 1;
    cpu.IM = 1;
    /* Stop before executing the synthetic caller's next instruction. A second
     * exit condition bounds execution to 30 emulated seconds if RET is never
     * reached; otherwise a broken delay or scheduler could hang the test. */
    while (cpu.PC != 0x100 && cpu.tstates < 7372800U * 30)
        Z80Execute(&cpu);
    /* Returning is only half the contract: SCM must receive its original
     * registers, flags and stack position. Also require the interrupt state
     * and alternate register bank to match their values at entry. */
    if (cpu.PC != 0x100 || cpu.R1.wr.SP != 0xd002 ||
        cpu.R1.wr.AF != 0x1234 || cpu.R1.wr.BC != 0x5678 ||
        cpu.R1.wr.DE != 0x9abc || cpu.R1.wr.HL != 0xdef0 ||
        cpu.R1.wr.IX != 0x1357 || cpu.R1.wr.IY != 0x2468 ||
        memcmp(&cpu.R2, &alternate, sizeof(alternate)) ||
        cpu.IFF1 != 1 || cpu.IFF2 != 1 || cpu.IM != 1)
        failures++;
    /* Final CSV row: total cycles, result byte, late count, and the player's
     * little-endian software tick. Python checks timing and completion status
     * separately from these C-level CPU/I/O invariants. Any accumulated C
     * failure produces a nonzero exit, even if the result byte claims success. */
    printf("R,%u,%u,%u,%u\n", cpu.tstates, memory[0xe003],
           memory[0xe004], memory[0xe005] + 256 * memory[0xe006]);
    return failures ? 1 : 0;
}
