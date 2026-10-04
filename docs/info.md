<!---
This file is used to generate the project datasheet. Images in this folder must be
under 512 kb each and under 1 MB combined.
-->

## How it works

A small programmable pin engine for bit-banging hardware protocols (UART, SPI, I2C, and
eventually JTAG, SWD, low-speed USB, 10BASE-T) in firmware instead of fixed logic.

Current milestone: a fixed-function 8N1 UART transmitter at 115200 baud from a 50 MHz clock.
The byte on `ui[7:0]` is sent out of `uo[0]` when `uio[0]` goes high.

## How to test

1. Run the chip at 50 MHz.
2. Connect `uo[0]` (UART_TX) to a USB-serial adapter's RX pin. Open a terminal at 115200 8N1.
3. Set a byte on `ui[7:0]` (e.g. 0x41 for "A") and pulse `uio[0]` high.
4. The character shows up in the terminal. `uo[1]` (BUSY) is high while the frame is sending.

## External hardware

USB-to-serial adapter (3.3 V logic).
