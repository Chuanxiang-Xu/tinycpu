# Pipeline

The core is organized around the classic five-stage model:

| Stage | Role |
| --- | --- |
| IF | Instruction fetch through the simple imem port |
| ID | Decode and register read |
| EX | ALU, branch compare, target/address calculation |
| MEM | Simple dmem load/store through BRAM or dmem MMIO |
| WB | Register writeback |

The v1.0 release candidate uses a real overlapped pipeline with IF/ID, ID/EX,
EX/MEM, and MEM/WB valid registers.

The CPU core no longer has an AXI-Lite master. It uses simple instruction and
data ports, with AXI-Lite loader/control logic moved to the SoC boundary. The
new pipeline implementation is centered in:

- `tinycpu_core_pipe.sv`
- `tinycpu_forwarding.sv`
- `tinycpu_muldiv.sv`
- `tinycpu_regfile.sv`
- `tinycpu_alu.sv`
- `tinycpu_decode.sv`

Current hazard policy:

- Multiple instructions can be valid in different stages at the same time.
- EX/MEM and MEM/WB forwarding feed EX operands.
- Load-use hazards freeze IF/ID until the producing load has reached a safe
  writeback point, then insert the needed bubble into ID/EX.
- Taken branches and jumps flush younger instructions.
- `x0` writes are suppressed in the register file.
- RV32M instructions start `tinycpu_muldiv`, assert the pipeline stall while
  the M unit is active, and write back when `muldiv_done` pulses.
- Illegal decode currently raises the core `cpu_trap` flag and stops fetch;
  this is a debug/status behavior, not a full architectural trap/exception
  implementation.

Teaching notes:

- This is an educational pipeline, so the control path is intentionally
  conservative and readable instead of optimized for maximum throughput.
- The core exposes debug valid bits for IF/ID, ID/EX, EX/MEM, and MEM/WB so
  tests can prove that multiple stages are live at once.
- Instruction memory is modeled as a simple ready/valid port at the CPU
  boundary. The SoC maps it to BRAM port A.
- The v1.0 stability claim is based on selected clean-room RV32I/RV32M,
  forwarding, load-use, branch/jump flush, C firmware smoke, and AXI-Lite
  loader/control simulation tests. It does not claim CSRs, interrupts,
  misaligned access traps, invalid-instruction architectural behavior, caches,
  or custom instructions.
