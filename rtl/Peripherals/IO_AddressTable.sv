package IO_AddressTable;
  // External Interrupt Controller
  parameter [2:0] EIC_ADDR = 3'h0;
  parameter [3:0] IER_ADDR = 4'h0;
  parameter [3:0] INR_ADDR = 4'h1;

  // Basic Key & Display
  parameter [2:0] BKD_ADDR  = 3'h1;
  parameter [3:0] LEDC_ADDR = 4'h0;
  parameter [3:0] SSDC_ADDR = 4'h1;
  parameter [3:0] KDIE_ADDR = 4'h2;
  parameter [3:0] KEYS_ADDR = 4'h3;

  parameter [2:0] RESV2_ADDR = 3'h2;
  parameter [2:0] RESV3_ADDR = 3'h3;
  parameter [2:0] RESV4_ADDR = 3'h4;
  parameter [2:0] RESV5_ADDR = 3'h5;
  parameter [2:0] RESV6_ADDR = 3'h6;
  parameter [2:0] RESV7_ADDR = 3'h7;
endpackage