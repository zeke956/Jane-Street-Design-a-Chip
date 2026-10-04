# SPDX-FileCopyrightText: © 2026 Brown Open Silicon
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

CLKS_PER_BIT = 434  # must match CLKS_PER_BIT in src/project.v


def tx(dut):
    return int(dut.uo_out.value) & 1


def busy(dut):
    return (int(dut.uo_out.value) >> 1) & 1


async def reset(dut):
    clock = Clock(dut.clk, 20, unit="ns")  # 50 MHz
    cocotb.start_soon(clock.start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


async def send(dut, byte):
    """Drive the byte onto ui_in and pulse the send pin (uio[0])."""
    dut.ui_in.value = byte
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 3)
    dut.uio_in.value = 0


async def uart_receive(dut, timeout_bits=20):
    """Software UART receiver: wait for the start bit, sample mid-bit."""
    for _ in range(timeout_bits * CLKS_PER_BIT):
        await RisingEdge(dut.clk)
        if tx(dut) == 0:
            break
    else:
        raise AssertionError("never saw a start bit")

    await ClockCycles(dut.clk, CLKS_PER_BIT // 2)
    assert tx(dut) == 0, "start bit glitched"

    value = 0
    for i in range(8):
        await ClockCycles(dut.clk, CLKS_PER_BIT)
        value |= tx(dut) << i

    await ClockCycles(dut.clk, CLKS_PER_BIT)
    assert tx(dut) == 1, "missing stop bit"
    return value


@cocotb.test()
async def test_idle_high(dut):
    await reset(dut)
    assert tx(dut) == 1, "TX line should idle high"
    assert busy(dut) == 0


@cocotb.test()
async def test_uart_bytes(dut):
    await reset(dut)
    for byte in [0x55, 0xA5, 0x00, 0xFF, 0x3C]:
        rx_task = cocotb.start_soon(uart_receive(dut))
        await send(dut, byte)
        got = await rx_task
        dut._log.info(f"sent 0x{byte:02X}, received 0x{got:02X}")
        assert got == byte
        await ClockCycles(dut.clk, CLKS_PER_BIT)  # let the stop bit finish
        assert busy(dut) == 0


@cocotb.test()
async def test_ignores_send_while_busy(dut):
    await reset(dut)
    rx_task = cocotb.start_soon(uart_receive(dut))
    await send(dut, 0x42)
    await ClockCycles(dut.clk, 3 * CLKS_PER_BIT)
    await send(dut, 0x99)  # should be dropped, TX is mid-frame
    assert await rx_task == 0x42
