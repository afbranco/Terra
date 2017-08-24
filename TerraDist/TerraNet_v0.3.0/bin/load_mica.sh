#------------------------------------------------
#
# Load a binary file into micaz mote
#
#------------------------------------------------
#  $1 - USB id
#  $2 - file name (input file without '.exe' suffix)
#  $3 - mote id
#------------------------------------------------
avr-objcopy --output-target=srec $2.exe $2.srec
tos-set-symbols $2.srec $2.srec.out TOS_NODE_ID=$3 ActiveMessageAddressC__addr=$3
#------------------------------------------------------------
uisp -dprog=mib510 -dserial=/dev/ttyUSB$1 --wr_fuse_h=0xd9 -dpart=ATmega128  --wr_fuse_e=ff   --erase --upload if=$2.srec.out --verify
#------------------------------------------------------------
rm $2.srec
rm $2.srec.out
rm $2.exe.out

