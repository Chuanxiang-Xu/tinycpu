# Pipeline

The core is organized around the classic five-stage model:

| Stage | Role |
| --- | --- |
| IF | Instruction fetch from AXI-Lite RAM |
| ID | Decode and register read |
| EX | ALU, branch compare, target/address calculation |
| MEM | AXI-Lite load/store |
| WB | Register writeback |

The v0.6 work-in-progress hardware introduces a real overlapped pipeline with
IF/ID, ID/EX, EX/MEM, and MEM/WB valid registers.

The CPU core no longer has an AXI-Lite master. It uses simple instruction and
data ports, with AXI-Lite loader/control logic moved to the SoC boundary. The
new pipeline implementation is centered in:

- `tinycpu_if_stage.sv`
- `tinycpu_id_stage.sv`
- `tinycpu_ex_stage.sv`
- `tinycpu_mem_stage.sv`
- `tinycpu_wb_stage.sv`
- `tinycpu_hazard.sv`
- `tinycpu_forwarding.sv`
- `tinycpu_core_pipe.sv`

Current hazard policy:

- Multiple instructions can be valid in different stages at the same time.
- EX/MEM and MEM/WB forwarding feed EX operands.
- Load-use hazards freeze IF/ID and insert a bubble into ID/EX.
- Taken branches and jumps flush younger instructions.
- `x0` writes are suppressed in the register file.
- RV32M instructions start `tinycpu_muldiv`, hold in `ST_MULDIV_WAIT` while
  `muldiv_busy` is asserted, and write back when `muldiv_done` pulses.
- `tinycpu_hazard.sv` contains explicit load-use and branch flush policy hooks
  for a later overlapped pipeline.

Known first-cut limitations:

- The GPIO smoke test passes, but directed RV32I branch/load-store regressions
  still expose control/hazard issues.
- Instruction memory is currently simple-read for bring-up; fully synchronous
  IF BRAM timing should be restored before relying on FPGA BRAM inference.
