# APB Controller (AHB-like to APB Bridge)

## Overview

This module implements an **APB (Advanced Peripheral Bus) controller** that acts as a **bridge between a high-speed master interface** (e.g., AHB-lite–style) and one or more low-speed APB peripherals.

The controller converts **pipelined master transactions** into **non-pipelined two-phase APB transfers**, handling buffering, flow control, and protocol sequencing.

---

## Features

* Supports **read and write transactions**
* Handles **back-to-back writes**
* Implements full **APB two-phase protocol**
* Provides **flow control via `hreadyout`**
* Supports **multiple APB slaves** via `pselx`
* Fully **synchronous FSM-based design**
* No combinational loops
* Suitable for FPGA and ASIC

---

## Supported Protocols

| Side            | Protocol                    |
| --------------- | --------------------------- |
| Master side     | AHB-like–style (simplified) |
| Peripheral side | AMBA APB (APB3-style)       |

---

## Block Diagram

```
        High-Speed Bus (AHB-like)
        --------------------------------
        valid, hwrite, haddr, hwdata
                   |
                   ▼
           +-------------------+
           |  APB Controller   |
           |  (This Module)    |
           +-------------------+
                   |
                   ▼
        APB Bus (Low-Speed)
        --------------------------------
        PADDR, PWDATA, PSELx, PENABLE
```

---

## Interface Signals

### Master-side Inputs

| Signal               | Description                        |
| -------------------- | ---------------------------------- |
| `valid`              | Indicates a valid transfer request |
| `hwrite`             | 1 = write, 0 = read                |
| `haddr`              | Address                            |
| `hwdata`             | Write data                         |
| `hwritereg`          | Indicates write pipelining         |
| `haddr1`, `haddr2`   | Buffered addresses                 |
| `hwdata1`, `hwdata2` | Buffered write data                |

### APB-side Outputs

| Signal    | Description      |
| --------- | ---------------- |
| `paddr`   | APB address      |
| `pwdata`  | APB write data   |
| `pwrite`  | APB direction    |
| `pselx`   | APB slave select |
| `penable` | APB enable phase |

### Flow Control

| Signal      | Description             |
| ----------- | ----------------------- |
| `hreadyout` | Back-pressure to master |

---

## FSM States

| State         | Purpose              |
| ------------- | -------------------- |
| `st_idle`     | Wait for transaction |
| `st_wait`     | Buffer write request |
| `st_writep`   | APB setup (write)    |
| `st_wenablep` | APB access (write)   |
| `st_write`    | Single write         |
| `st_wenable`  | Write enable         |
| `st_read`     | APB setup (read)     |
| `st_renable`  | APB access (read)    |

---

## Protocol Operation

### Write Transaction

```
Cycle 1: valid=1 → st_wait → capture address/data
Cycle 2: st_writep → PSEL=1, PENABLE=0
Cycle 3: st_wenablep → PSEL=1, PENABLE=1 (write occurs)
```

Supports **back-to-back writes** using internal buffering.

---

### Read Transaction

```
Cycle 1: valid=1 → st_read → PSEL=1, PENABLE=0
Cycle 2: st_renable → PSEL=1, PENABLE=1 (read occurs)
```

---

## Flow Control

The signal `hreadyout` is used to **stall the master** when:

* APB is busy
* Internal buffers are occupied

This prevents data loss and ensures correct sequencing.

---

## Design Characteristics

| Property        | Value                     |
| --------------- | ------------------------- |
| Latency         | 2 cycles per APB transfer |
| Throughput      | 1 transaction at a time   |
| Outstanding ops | 1–2 writes                |
| Clocking        | Single synchronous clock  |
| CDC             | Not supported             |
| Error handling  | Not implemented           |

---

## Limitations

This implementation does **not include**:

* PSLVERR error signaling
* Multi-entry FIFOs
* Clock domain crossing
* Security/firewall logic
* Low-power modes

It is intended for:

* Educational use
* Research prototypes
* Lightweight FPGA SoCs

---

## Typical Use Cases

* Microcontroller peripheral bus
* UART / GPIO / Timer access
* FPGA-based SoC designs
* Academic AMBA implementations

---

## Compliance

* APB timing: ✔ compliant
* APB setup/enable phases: ✔
* Back-to-back writes: ✔
* Read-after-write support: ✔

---

## Notes for Extension

To modernize this controller for production use, consider adding:

* FIFO buffering (2–8 entries)
* PSLVERR support
* Clock gating
* SVA assertions
* UVM verification
* AXI interface on master side


---
