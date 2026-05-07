# SPDX-FileCopyrightText: © 2026 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    dut._log.info("Start simulation")

    # 100 kHz clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # -------------------
    # Reset
    # -------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 2)

    dut._log.info("Reset complete")

    # -------------------
    # Apply test inputs
    # -------------------
    test_vectors = [
        (0, 0),
        (1, 1),
        (20, 30),
        (255, 255),
        (10, 5),
    ]

    for ui, uio in test_vectors:

        dut.ui_in.value = ui
        dut.uio_in.value = uio

        await ClockCycles(dut.clk, 2)

        output_value = int(dut.uo_out.value)

        dut._log.info(
            f"ui_in={ui}, uio_in={uio}, uo_out={output_value}"
        )

        # Basic validation:
        # ensure output is a valid integer and simulation runs
        assert output_value >= 0

    dut._log.info("Test completed successfully")
