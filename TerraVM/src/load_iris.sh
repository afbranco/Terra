#------------------------------------------------
#
# Load a binary file into iris mote
#
#------------------------------------------------
#  $1 - USB id
#  $2 - file name (input file without '.exe' suffix)
#  $3 - mote id
#------------------------------------------------
avr-objcopy --output-target=srec $2.exe $2.srec
#avr-objcopy --output-target=ihex $2.exe $2.ihex
tos-set-symbols $2.srec $2.srec.out TOS_NODE_ID=$3 ActiveMessageAddressC__addr=$3
#------------------------------------------------------------
avrdude -cmib510 -P/dev/ttyUSB$1 -U hfuse:w:0xd9:m -pm1281 -U efuse:w:0xff:m -C/etc/avrdude/avrdude.conf  -U flash:w:$2.srec.out:a
#------------------------------------------------------------
rm $2.srec
rm $2.srec.out
rm $2.exe.out

