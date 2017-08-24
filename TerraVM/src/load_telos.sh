#-------------
#  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
#  	Copyright (C) 2014-2017  Adriano Branco
#	
#	This file is part of Terra IoT.
#	
#	Terra IoT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Terra IoT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
#-------------
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

