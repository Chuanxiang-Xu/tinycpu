# Architecture

`v0.6-pipeline-bram-loader` is a source-first, clean-room educational RV32IM
SoC work-in-progress for the PYNQ-Z2 FPGA board.

```text
PYNQ-Z2 pins
  -> pynqz2_top
      -> tinycpu_soc
          -> tinycpu_core_pipe
          -> unified 64 KiB BRAM
          -> dmem MMIO decoder
          -> AXI-Lite loader/control slave
```

The CPU target ISA is standard RISC-V RV32IM. The current milestone implements
RV32I plus the standard RV32M multiply/divide extension for simple freestanding
C programs.

The new core uses IF, ID, EX, MEM, and WB pipeline registers with valid bits,
forwarding hooks, load-use stall policy, and branch flush policy. AXI-Lite is
no longer mixed into the CPU core; the pipeline uses simple Harvard-style
instruction and data memory ports.

Physical RAM is a unified 64 KiB memory. Port A is used for instruction fetch.
Port B is selected between CPU data RAM access and the AXI-Lite loader while
the CPU is halted or reset. The current first cut uses a simple instruction
read path for simulation bring-up; fully synchronous IF BRAM timing remains
follow-up work.

The board wrapper, `pynqz2_top`, connects PYNQ-Z2 pins to the SoC:

- `sysclk` to SoC clock.
- `btn[0]` to active-high reset.
- `sw[1:0]` to GPIO switch input.
- `led[3:0]` to GPIO LED output.

The Vivado project name for this milestone is:

```text
tinycpu_pynq_v0_6_pipeline_bram_loader
```

This project is an independent educational implementation. It does not require
private course repositories, generated Vivado project files, or local reference
directories.
