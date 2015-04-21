#------------------------------------------------
#
# Load a binary file into micaz mote
#
#------------------------------------------------
#  $1 - USB id
#  $2 - file name (input file without '.exe' suffix)
#  $3 - mote id
#------------------------------------------------
msp430-objcopy --output-target=ihex $2.exe $2.ihex
tos-set-symbols --objcopy msp430-objcopy --objdump msp430-objdump --target ihex $2.ihex $2.ihex.out TOS_NODE_ID=$3 ActiveMessageAddressC__addr=$3 
#------------------------------------------------------------
tos-bsl --telosb -c /dev/ttyUSB$1 -r -e -I -p $2.ihex.out 
#------------------------------------------------------------
rm $2.ihex
rm $2.ihex.out
rm $2.exe.out

