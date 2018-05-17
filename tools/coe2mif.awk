# Description: Convert coe format into mif format
# Usage: gawk -v size=MEM_SIZE_IN_WORDS -f coe2mif.awk COE_FILE > MIF_FILE

BEGIN {
  addr = 0
  print "WIDTH=32;"
  printf "DEPTH=%d;\n", size
  print
  print "ADDRESS_RADIX=HEX;"
  print "DATA_RADIX=HEX;"
  print
  print "CONTENT BEGIN"
}

/^[0-9a-f]+,$/ {
  sub(/,/, ";")
  printf "  %04x : %s\n", addr, $0
  addr++
}

END {
  printf "  [%04x..%04x] : 00000000;\n", addr, size-1
  print "END;\n"
}
