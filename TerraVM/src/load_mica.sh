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
avr-objcopy --output-target=srec $2.exe $2.srec
tos-set-symbols $2.srec $2.srec.out TOS_NODE_ID=$3 ActiveMessageAddressC__addr=$3
#------------------------------------------------------------
uisp -dprog=mib510 -dserial=/dev/ttyUSB$1 --wr_fuse_h=0xd9 -dpart=ATmega128  --wr_fuse_e=ff   --erase --upload if=$2.srec.out --verify
#------------------------------------------------------------
rm $2.srec
rm $2.srec.out
rm $2.exe.out

