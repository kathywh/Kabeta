# Kabeta
An implementation of pipelined β processor of MIT

**NOTICE** All documents and code are either directly from or built upon [Course 6.004 Computation Structures](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-004-computation-structures-spring-2009/) of MIT OpenCourseWare site under [Creative Commons License](https://creativecommons.org/licenses/by-nc-sa/4.0/) and other [terms of use](https://ocw.mit.edu/terms/). And other relevant documents and tools can be obtained there.

### Introduction to Kabeta

Kabeta is a 5-stage pipelined RISC processor. It conforms to [MIT β document](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-004-computation-structures-spring-2009/labs/MIT6_004s09_lab_beta_doc.pdf) and has some extensions. The main extensions include:

- SVC/IOR/IOW instructions
- More exceptions
- Core/External interrupt controllers
- KabIO -- an universal I/O interface

### How to Run It

Prerequisites:

- an evaluation board of Intel Cyclone IV E FPGA
- Linux, Cygwin or other environment with JRE and AWK
- bsim tool from MIT OpenCourseWare site
- Quartus Prime

It has been tested on Intel Cyclone IV E FPGA and there are some Intel FPGA IPs so far, so an evaluation board of Intel Cyclone IV E FPGA is necessary.

**NOTE** Modifications may be needed according to your evaluation board configuration.

Follow the steps:

1. Enter one of the directories in *test/OnBoardTest*, e.g. *01_LED*.
2. Run the command: `java -jar ../../../tools/bsim.jar test.uasm`, then click the *Assemble to Files* button.
3. Run the command: `gawk -v size=1024 -f ../../../tools/coe2mif.awk test.coe > Alt_EP4CE_InstrMem_4KB.mif`
4. Copy *Alt_EP4CE_InstrMem_4KB.mif* to *proj/Quartus_Prime_16.1* directory.
5. Open the Quartus Prime project, compile and program.

**NOTE** The assembly include file *kabeta.uasm* is a little bit different with the original one from MIT OpenCourseWare.
