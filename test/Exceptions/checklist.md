| Test                                                    | Check Item                                                   |
| ------------------------------------------------------- | ------------------------------------------------------------ |
| 01:    RR-Stage Fault in branch slots                   | No exception, R3 <- 0xA3                                     |
| 02_1:  IF-Stage Fault in branch slots (User Mode)       | Fetch one instruction of Invalid I-Address fault (8000_0014), then go to 814 (branch target) |
| 02_2:  IF-Stage Fault in branch slots (Supervisor Mode) | Double fault, system reset                                   |
| 03_1:  Interrupt when branch at IF-Stage                | Go to Int 0 Handler (8000_0018), return to 804               |
| 03_2:  Interrupt when branch at RR-Stage                | Go to Int 0 Handler (8000_0018), return to 808               |
| 03_3:  Interrupt when branch at EX-Stage                | Go to Int 0 Handler (8000_0018), return to 80C               |
| 03_4:  Interrupt when branch at MA-Stage                | Go to Int 0 Handler (8000_0018), return to 81C (branch target) |
| 04_1:  EX-Stage Fault and pipeline stall                | Invalid Operation fault (8000_000C), no stall                |
| 04_2:  RR-Stage Fault and pipeline stall                | Stall, then Illegal Instruction fault (8000_0008)            |
| 05:    Interrupt and pipeline stall (EX-Stage)          | Go to Int 0 Handler (8000_0018), return to 80C and no stall  |
| 06_1:  Branch (BEQ) and pipeline stall (EX-Stage)       | Stall, then branch to 824                                    |
| 06_2:  Branch (JMP) and pipeline stall (EX-Stage)       | Stall, then branch to 824                                    |
| 07:    Double fault                                     | Illegal Instruction fault (8000_0008), then double fault, system reset |