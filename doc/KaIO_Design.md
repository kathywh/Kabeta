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

## Appendix A: Document Version History

| Version | Date      | Editor | Reviewer | Comment          |
| ------- | --------- | ------ | -------- | ---------------- |
| 1.0     | 5/23/2018 | Kathy  | (N/A)    | Initial version. |