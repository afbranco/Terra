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

INO_XBEE_USB ?= 1
ifneq ($(INO_XBEE_USB),0)
  ifneq ($(INO_XBEE_USB),1)
    $(error INO_XBEE_USB must be "0" or "1")
  endif
endif

COMPONENT=TSdAppC


APPDIR = $(shell pwd)
INODIR = /home/branco/gitspace/Terra/nescino/src/ino
CFLAGS += -I$(INODIR) -DINO -DINO_XBEE_USB=$(INO_XBEE_USB)

PLATFORM=ino
BUILDDIR ?= build/$(PLATFORM)
MAIN_EXE = $(BUILDDIR)/main.exe
MAIN_SREC = $(BUILDDIR)/main.srec
MAIN_IHEX = $(BUILDDIR)/main.ihex
MAIN_HEX = $(BUILDDIR)/main.hex
OBJDUMP = avr-objdump
CPU=atmega2560


OPT_1 = -fnesc-include=tos  -topdir=/home/branco/gitspace/Terra/nescino  -fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask -DPLATFORM_IRIS -o $(MAIN_EXE) -Os -fnesc-separator=__ -Wall -Wshadow -Wnesc-all -fnesc-cfile=build/ino/app.c --param max-inline-insns-single=100000 -fnesc-dump=wiring   -fnesc-dumpfile=build/ino/wiring-check.xml $(COMPONENT).nc -lm  -gcc=avr-gcc -mmcu=$(CPU) -fnesc-target=avr -fnesc-no-debug

OPT_2 = $(CFLAGS)

OPT_3 = -I/opt/tinyos-2.1.2/tos/sensorboards/micasb -I/opt/tinyos-2.1.2/tos/platforms/iris -I/opt/tinyos-2.1.2/tos/platforms/micaz -I/opt/tinyos-2.1.2/tos/platforms/mica -I/opt/tinyos-2.1.2/tos/platforms/iris/chips/rf230 -I/opt/tinyos-2.1.2/tos/chips/rf230 -I/opt/tinyos-2.1.2/tos/lib/rfxlink/layers -I/opt/tinyos-2.1.2/tos/lib/rfxlink/util -I/opt/tinyos-2.1.2/tos/platforms/iris/chips/at45db -I/opt/tinyos-2.1.2/tos/platforms/mica2/chips/at45db -I/opt/tinyos-2.1.2/tos/platforms/mica/chips/at45db -I/opt/tinyos-2.1.2/tos/chips/at45db -I/opt/tinyos-2.1.2/tos/platforms/iris/chips/ds2401 -I/opt/tinyos-2.1.2/tos/platforms/mica2/chips/ds2401 -I/opt/tinyos-2.1.2/tos/chips/ds2401 -I/opt/tinyos-2.1.2/tos/chips/atm1281 -I/opt/tinyos-2.1.2/tos/chips/atm1281/adc -I/opt/tinyos-2.1.2/tos/chips/atm1281/timer -I/opt/tinyos-2.1.2/tos/chips/atm128 -I/opt/tinyos-2.1.2/tos/chips/atm128/adc -I/opt/tinyos-2.1.2/tos/chips/atm128/pins -I/opt/tinyos-2.1.2/tos/chips/atm128/spi -I/opt/tinyos-2.1.2/tos/chips/atm128/i2c -I/opt/tinyos-2.1.2/tos/chips/atm128/timer -I/opt/tinyos-2.1.2/tos/lib/timer -I/opt/tinyos-2.1.2/tos/lib/serial -I/opt/tinyos-2.1.2/tos/lib/power -I/opt/tinyos-2.1.2/tos/lib/diagmsg -I/opt/tinyos-2.1.2/tos/interfaces -I/opt/tinyos-2.1.2/tos/types -I/opt/tinyos-2.1.2/tos/system -DMHZ=16

mega:
	$(info **********  Makefile Ino: Mega *************)

uno:
	$(info **********  Makefile Ino: Uno *************)

exe: 
	@echo "    compiling $(COMPONENT) to a $(PLATFORM) binary"
	nescc $(OPT_1) $(OPT_2) $(OPT_3)
	/home/branco/arduino-1.0.5/hardware/tools/avr/bin/avr-objcopy -O ihex -R .eeprom $(MAIN_EXE) $(MAIN_HEX)
	@echo "    compiled $(COMPONENT) to $(MAIN_EXE)"
	
ino: builddir exe bytes 
	@:
	
install: ino
	/home/branco/arduino-1.0.5/hardware/tools/avrdude -C/home/branco/arduino-1.0.5/hardware/tools/avrdude.conf  -v -patmega2560 -cwiring -P$(INO_INSTALL_PORT) -b115200 -D -Uflash:w:$(MAIN_HEX):i
	
	
builddir: 
	mkdir -p $(BUILDDIR)

bytes: 
	@$(OBJDUMP) -h $(MAIN_EXE) | perl -ne '$$b{$$1}=hex $$2 if /^\s*\d+\s*\.(text|data|bss)\s+(\S+)/; END { printf("%16d bytes in ROM\n%16d bytes in RAM\n",$$b{text}+$$b{data},$$b{data}+$$b{bss}); }'
	
