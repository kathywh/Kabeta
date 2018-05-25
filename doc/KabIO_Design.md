# KabIO Design

**Date:** May 23, 2018  
**Version:** 1.0  
**Author:** Kathy  
**Reviewer:** (N/A)  

## 1 Introduction

### 1.1 Description

I/O devices of Kabeta processor.

### 1.2 I/O Interface

![](IO_General.png)

*Figure 1. [I/O Interface](IO_General.png)*

**NOTES:**

1. Signal Names
   - BA -- Block Address
   - RA -- Register Address
   - RE -- Read Enable
   - WE -- Write Enable
   - WD -- Write Data
   - RD -- Read Data
   - Rdy -- Ready
2. EIC is a special I/O block with interrupt interface.
### 1.3 I/O Block

![](IO_Block.png)

*Figure 2. [I/O Block](IO_Block.png)*

**NOTES:**

RW -- Read/Write

RC -- Read with Clear

RO -- Read Only

WO -- Write Only

### 1.4 I/O Address Format 

I/O address is divided into two parts, block address and register address.

| 31            7 | 6                     4 | 3                        0 |
| --------------- | :---------------------: | :------------------------: |
| (Reserved)      |      Block Address      |      Register Address      |

### 1.5 I/O Registers

- All registers are 32-bit wide
- Four types:
  - Write Only - read data is undefined
  - Read Only - write has no effect
  - Read Clear - read the register while clear some bits, and write has no effect
  - Read Write - read back what has been written or reset value

## 2 External Interrupt Controller (EIC)

### 2.1 Description

Features:

- 8 IRQ (Interrupt ReQuest) inputs
- An URQ (Urgent ReQuest) input
- URQ has priority over IRQs
- Fixed IRQ priorities, IR0 highest and IRQ7 lowest among IRQs
- IRQs IID=0, URQ IID=1

### 2.2 Block Diagram

![](IO_EIC.png)

*Figure 3. [External Interrupt Controller](IO_EIC.png)*

### 2.3 Registers

#### 2.3.1 Interrupt Enable Register (IE) -- 0x00 - Write Only

| 31            1 |  0   |
| :-------------: | :--: |
|   (Reserved)    | GIE  |

- GIE: Global Interrupt Enable

#### 2.3.2 Interrupt Number Register (IN) -- 0x04 -- Read Only

| 31            3 | 2           0 |
| :-------------: | :-----------: |
|   (Reserved)    |      IN       |

- IN: Interrupt Number

## Appendix A: Document Version History

| Version | Date      | Editor | Reviewer | Comment          |
| ------- | --------- | ------ | -------- | ---------------- |
| 1.0     | 5/23/2018 | Kathy  | (N/A)    | Initial version. |