# Pipeline

The core is organized around the classic five-stage model:

| Stage | Role |
| --- | --- |
| IF | Instruction fetch from AXI-Lite RAM |
| ID | Decode and register read |
| EX | ALU, branch compare, target/address calculation |
| MEM | AXI-Lite load/store |
| WB | Register writeback |

The v0.5 hardware is stage-structured but serialized. It is not a fully
overlapped five-stage pipeline yet.

One AXI-Lite master is shared by instruction fetch and data accesses. To keep
the v0.5 RV32M milestone small and inspectable, the control path serializes
instructions through stage states and waits around bus transactions. This
preserves explicit stage boundaries in the RTL:

- `tinycpu_if_stage.sv`
- `tinycpu_id_stage.sv`
- `tinycpu_ex_stage.sv`
- `tinycpu_mem_stage.sv`
- `tinycpu_wb_stage.sv`
- `tinycpu_hazard.sv`

Current hazard policy:

- Hazards are mostly avoided by serialization because only one instruction is
  active at a time.
- `x0` writes are suppressed in the register file.
- Branch/jump redirect updates the PC and suppresses fall-through advance.
- Load/store and instruction fetch are serialized through the single AXI-Lite
  master.
- RV32M instructions start `tinycpu_muldiv`, hold in `ST_MULDIV_WAIT` while
  `muldiv_busy` is asserted, and write back when `muldiv_done` pulses.
- `tinycpu_hazard.sv` contains explicit load-use and branch flush policy hooks
  for a later overlapped pipeline.

Future v0.6 work may add:

- Valid/bubble pipeline registers.
- Forwarding.
- Load-use stall handling.
- Branch flush handling.
- Directed hazard tests that make the overlapped behavior observable.
