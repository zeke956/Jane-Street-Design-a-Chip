# Architecture notes

Living doc. Decisions go here once the team agrees on them.

## What we're building

A pin engine: one or more tiny cores whose instruction set is built around pins and time.
Firmware loaded after fabrication decides which protocol runs. No hardwired UART/SPI/I2C
blocks in the final design (the current `uart_tx.v` is scaffolding and goes away).

References worth reading before the ISA gets locked:

- RP2040 PIO (datasheet chapter 3): 9 instructions, side-set, autopull/autopush FIFOs
- TI PRU (AM335x TRM, PRU-ICSS chapter): single-cycle instructions, direct GPIO registers

## Open design questions

1. **Instruction set.** Minimum needed: set/clear pins, wait on pin level or edge, delay N
   cycles, shift in/out, jump, conditional jump. What do we add that PIO doesn't have?
2. **How firmware gets in.** SPI loader on dedicated pins at reset is the likely answer.
   Which pins, and does the loader itself use the engine?
3. **Instruction memory.** Flip-flops vs SRAM macro. SRAM is denser on this node, so check
   Tiny Tapeout's IHP SRAM examples before committing.
4. **How many engines.** One fat core or several small state machines in parallel
   (SPI master + UART at the same time)?
5. **Open-drain.** I2C needs it. Plan: drive `uio_out` low and toggle `uio_oe`.
6. **Host interface.** FIFOs between the engine and the outside world, and how wide.
7. **Clocking.** Fractional clock divider per engine so baud rates come out exact.
8. **Verification.** Python instruction-set simulator as the golden model, constrained-random
   programs compared against RTL, plus formal properties on the core (SymbiYosys).

## Roadmap

| Milestone | Target | Done when |
|---|---|---|
| M0 | Oct 2026 | Fixed UART TX passes tests, GDS action green |
| M1 | Oct 25 | ISA spec v0, Python assembler, instruction-set simulator |
| M2 | Nov 15 | RTL engine runs UART TX/RX firmware in sim and on FPGA |
| M3 | Dec 6 | SPI + I2C firmware working, full GDS run fits 6x4 and meets timing |
| M4 | Jan 4 | Stretch protocol (JTAG/SWD or low-speed USB), formal + random tests |
| M5 | Jan 18 | Freeze, datasheet, submit |

Finals land in December, so M3 needs to be real before then.
