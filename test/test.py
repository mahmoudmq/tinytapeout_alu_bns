# SPDX-FileCopyrightText: © 2026 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    """Testbench for Tiny Tapeout project"""

    dut._log.info("Start simulation")

    # Create 100 kHz clock (10 us period)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # -------------------------
    # Reset DUT
    # -------------------------
    dut._log.info("Applying reset")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Hold reset for 10 cycles
    await ClockCycles(dut.clk, 10)

    # Release reset
    dut.rst_n.value = 1

    # Wait one cycle after reset
    await ClockCycles(dut.clk, 1)

    # -------------------------
    # Test Case 1
    # -------------------------
    dut._log.info("Running Test Case 1")

    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for output to update
    await ClockCycles(dut.clk, 1)

    expected = 50
    actual = int(dut.uo_out.value)

    dut._log.info(f"ui_in = 20, uio_in = 30")
    dut._log.info(f"Expected output = {expected}")
    dut._log.info(f"Actual output   = {actual}")

    assert actual == expected, (
        f"TEST FAILED: expected {expected}, got {actual}"
    )

    # -------------------------
    # Test Case 2
    # -------------------------
    dut._log.info("Running Test Case 2")

    dut.ui_in.value = 10
    dut.uio_in.value = 5

    await ClockCycles(dut.clk, 1)

    expected = 15
    actual = int(dut.uo_out.value)

    dut._log.info(f"ui_in = 10, uio_in = 5")
    dut._log.info(f"Expected output = {expected}")
    dut._log.info(f"Actual output   = {actual}")

    assert actual == expected, (
        f"TEST FAILED: expected {expected}, got {actual}"
    )

    # -------------------------
    # Test Case 3
    # -------------------------
    dut._log.info("Running Test Case 3")

    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 1)

    expected = 0
    actual = int(dut.uo_out.value)

    dut._log.info(f"Expected output = {expected}")
    dut._log.info(f"Actual output   = {actual}")

    assert actual == expected, (
        f"TEST FAILED: expected {expected}, got {actual}"
    )

    dut._log.info("All tests passed successfully!")
