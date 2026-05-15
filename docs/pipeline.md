# Pipeline

The core is organized around the classic five-stage model:

| Stage | Role |
| --- | --- |
| IF | Instruction fetch from AXI-Lite RAM |
| ID | Decode and register read |
| EX | ALU, branch compare, target/address calculation |
| MEM | AXI-Lite load/store |
| WB | Register writeback |

The v0.4 hardware still has one AXI-Lite master shared by instruction fetch and
data accesses. To keep the C-support milestone small, the current control path
serializes instructions through the five stage states and waits around bus
transactions. This makes behavior easy to inspect while preserving explicit
stage boundaries in the RTL:

- `tinycpu_if_stage.sv`
- `tinycpu_id_stage.sv`
- `tinycpu_ex_stage.sv`
- `tinycpu_mem_stage.sv`
- `tinycpu_wb_stage.sv`
- `tinycpu_hazard.sv`

Current hazard policy:

- `x0` write suppression in the register file.
- Branch/jump redirect updates the PC and suppresses the fall-through advance.
- Load/store and instruction fetch are serialized through the single AXI-Lite
  master.
- `tinycpu_hazard.sv` contains the explicit load-use and branch flush policy
  hooks for the later overlapped pipeline.

Because only one instruction is active at a time in v0.4, data hazards are
naturally avoided by serialization. Future work is to allow more overlapping
stage activity, add forwarding paths, and make load-use stalls visible through
pipeline valid/bubble registers.
