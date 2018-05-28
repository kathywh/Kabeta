################################################################################
#                              Global Assignments                              #
################################################################################

# Device Settings
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE6F17C8
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVCMOS"
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"

# Configuration Settings
set_global_assignment -name CYCLONEIII_CONFIGURATION_SCHEME "ACTIVE SERIAL"
set_global_assignment -name USE_CONFIGURATION_DEVICE ON
set_global_assignment -name CYCLONEIII_CONFIGURATION_DEVICE EPCS16
set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF

################################################################################
#                               File Assignments                               #
################################################################################

set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
set_global_assignment -name SDC_FILE scripts/SystemChip.sdc
set_global_assignment -name QIP_FILE ../../rtl/IP/Alt_EP4CE_SysPLL.qip
set_global_assignment -name QIP_FILE ../../rtl/IP/Alt_EP4CE_InstrMem_4KB.qip
set_global_assignment -name QIP_FILE ../../rtl/IP/Alt_EP4CE_DataMem_16KB.qip
set_global_assignment -name VERILOG_FILE ../../rtl/CommonDefinitions.v
set_global_assignment -name VERILOG_FILE ../../rtl/RegisterRstEn.v
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/IO_AddressTable.sv
set_global_assignment -name VERILOG_FILE ../../rtl/Peripherals/Handshaker.v
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/IO_AccessItf.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/ReadWriteRegister.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/ReadOnlyRegister.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/ReadClearRegister.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/IO_Interface.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/ExtInterruptCtrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/BasicKeyDisplay.sv
set_global_assignment -name VERILOG_FILE ../../rtl/SystemPLL.v
set_global_assignment -name VERILOG_FILE ../../rtl/Synchronizer.v
set_global_assignment -name VERILOG_FILE ../../rtl/ResetSynchronizer.v
set_global_assignment -name VERILOG_FILE ../../rtl/RegisterFile.v
set_global_assignment -name VERILOG_FILE ../../rtl/RegisterEn.v
set_global_assignment -name VERILOG_FILE ../../rtl/InstructionRegister.v
set_global_assignment -name VERILOG_FILE ../../rtl/InstructionMemory.v
set_global_assignment -name VERILOG_FILE ../../rtl/InstructionDecoder.v
set_global_assignment -name VERILOG_FILE ../../rtl/CoreInterruptUnit.v
set_global_assignment -name VERILOG_FILE ../../rtl/DataMemory.v
set_global_assignment -name VERILOG_FILE ../../rtl/BranchExceptionUnit.v
set_global_assignment -name VERILOG_FILE ../../rtl/ArithmeticLogicUnit.v
set_global_assignment -name VERILOG_FILE ../../rtl/AddressInc.v
set_global_assignment -name VERILOG_FILE ../../rtl/AddressAdder.v
set_global_assignment -name VERILOG_FILE ../../rtl/Kabeta.v
set_global_assignment -name SYSTEMVERILOG_FILE ../../rtl/Peripherals/KabIO.sv
set_global_assignment -name VERILOG_FILE ../../rtl/SystemChip.v

################################################################################
#                             Location Assignments                             #
################################################################################

# Reset/Clock
set_location_assignment	PIN_E15 -to Reset
set_location_assignment	PIN_E1  -to Clock

# LEDs
set_location_assignment	PIN_G15	-to LED[0]
set_location_assignment	PIN_F16	-to LED[1]
set_location_assignment	PIN_F15	-to LED[2]
set_location_assignment	PIN_D16	-to LED[3]

# Keys
set_location_assignment	PIN_M12	 -to Keys[0]
set_location_assignment	PIN_E16	 -to Keys[1]
set_location_assignment	PIN_M16  -to Keys[2]
set_location_assignment	PIN_M15  -to Keys[3]

# Seven Segment Display
set_location_assignment	PIN_B7	-to Segment[0]
set_location_assignment	PIN_A8	-to Segment[1]
set_location_assignment	PIN_A6	-to Segment[2]
set_location_assignment	PIN_B5	-to Segment[3]
set_location_assignment	PIN_B6	-to Segment[4]
set_location_assignment	PIN_A7	-to Segment[5]
set_location_assignment	PIN_B8	-to Segment[6]
set_location_assignment	PIN_A5	-to Segment[7]

set_location_assignment	PIN_B1	-to Digital[0]
set_location_assignment	PIN_A2	-to Digital[1]
set_location_assignment	PIN_B3  -to Digital[2]
set_location_assignment	PIN_A3	-to Digital[3]
set_location_assignment	PIN_B4	-to Digital[4] 
set_location_assignment	PIN_A4	-to Digital[5]