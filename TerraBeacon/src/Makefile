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

#
#TerraBeacon make parameters
#
# Configure sensorboard: MTS300CA or MTS300CB(wired) or MDA100 | default MDA100
#    SENSOR=MTS300CA
#
# Verbose Compilation mode: YES or NO | Default NO
#    VERB=YES
#
# RF Power: 0 1 2 3 4 5 6 7 | default 7
#    RFPOWER=1
#
# INO_RADIO Connection: XBEE0 or XBEE1 or NRF24 or NO_RADIO| default NO_RADIO
#    INO_RADIO=XBEE0
#
# INO_HALF_CLOCK Divide Arduino MCU Clock by 2. Apply when powering ProMini_16MHz(5v) with 3.3v 
# INO_HALF_CLOCK=YES
#
# NET ID: 0..30 | default 0:cc1000, 1:cc2420, 2:wifi-udp, 3:esp, 4:nrf24, 5:xbee 
# NET_ID=2
#
# Command line examples
#  make promini16 INO_RADIO=NRF24 install.2 USB,/dev/ttyUSB0
#
#==================================================================================
#==================================================================================

ALL_TARGETS = micaz mica2 mica2dot telosb iris uno mega rpi promini16 promini8
TOS_TARGETS = micaz mica2 mica2dot telosb iris
INO_TARGETS = uno mega promini16 promini8
INO_UNO_TARGETS = uno promini16 promini8
INO_MEGA_TARGETS = mega
IX_TARGETS = rpi

#  Save makecmdgoals (a read only var) to goals so that we can modify it.
GOALS += $(MAKECMDGOALS)
#  Extract user options from goals of the form opt,arg, transform to opt=arg,
#  and evaluate.  Then, reduce GOALS to have the args removed.
OptRE := [,.]
GoalOpts := $(shell perl -e 'print join " ", map {s{^(.*?)$(OptRE)}{\U$$1=};$$_} grep /$(OptRE)/, split /\s+/, "$(GOALS)";')
GOALS := $(shell perl -e '$$_="$(GOALS)"; s{$(OptRE)\S*}{}g; print;')
$(foreach opt,$(GoalOpts),$(eval $(opt)))

INSTALL ?= 1

# Extract Target mote
MOTE = $(word 1,$(MAKECMDGOALS))

# Valid motes
ifeq ($(filter $(MOTE),$(ALL_TARGETS)),)
      $(error Target mote must be: micaz, mica2, mica2dot, telosb, uno, mega, promini16 promini8, or rpi)
endif

#
# Check options
#
VERB ?= NO
ifneq ($(VERB),YES)
  ifneq ($(VERB),NO)
    $(error VERB must be "YES" or "NO")
  endif
endif

ifneq ($(filter $(MOTE),$(INO_TARGETS)),)
  INO_RADIO ?= NO_RADIO
  ifneq ($(INO_RADIO),XBEE0)
    ifneq ($(INO_RADIO),XBEE1)
  	  ifneq ($(INO_RADIO),NRF24)
        ifneq ($(INO_RADIO),NO_RADIO)
          $(error INO_RADIO must be "XBEE0", "XBEE1", "NRF24", or "NO_RADIO")
        endif
      endif
    endif
  endif
else
  ifneq ($(INO_RADIO),)
    $(error INO_RADIO must be set only for motes: $(INO_TARGETS))
  endif
endif


# Default radio power
RFPOWER ?= 7
ifeq ($(findstring $(RFPOWER), 0 1 2 3 4 5 6 7 ),)
    $(error 'RFPOWER must have 1 digit value: 0 1 2 3 4 5 6 7')
endif

# Verbose mode
ifeq ($(VERB),YES)
	CFLAGS += -v
endif

INO_HALF_CLOCK ?= NO
ifneq ($(INO_HALF_CLOCK),YES)
  ifneq ($(INO_HALF_CLOCK),NO)
    $(error INO_HALF_CLOCK must be "YES" or "NO")
  endif
endif

#----------------------------------------------------------------

#
# define root APP dir
#
APPDIR = $(shell pwd)
TERRA_APPDIR = $(APPDIR)/../../TerraVM/src

#
# Define VM path
#
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  	COMMONDIR = $(TERRA_APPDIR)/platforms/TinyOS/common
	CFLAGS += -I. -I$(COMMONDIR) 
endif

ifneq ($(filter $(MOTE),$(INO_UNO_TARGETS)),)
	VMDIR = $(TERRA_APPDIR)/platforms/inoUno
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(INO_RADIO)
	ifeq ($(INO_HALF_CLOCK),YES)
		CFLAGS += -DINO_HALF_CLOCK
		ifneq ($(MOTE),promini8)
          $(error FAIL: Setting INO_HALF_CLOCK was recommended only for "promini8 5v", but powered with 3v3!)
		endif
	endif
endif
ifneq ($(filter $(MOTE),$(INO_MEGA_TARGETS)),)
	VMDIR = $(TERRA_APPDIR)/platforms/inoMega
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(INO_RADIO)
endif
ifeq ($(MOTE),rpi)
	VMDIR = $(TERRA_APPDIR)/platforms/RPi
	CFLAGS += -I. -I$(VMDIR) 
endif


# default 0:cc1000, 1:cc2420, 2:wifi-udp, 3:nrf24, 4:xbee, 5:NoRadio
NETID_mica2 = 0
NETID_mica2dot = 0
NETID_micaz = 1
NETID_telosb = 1
NETID_iris = 1
NETID_esp = 2
NETID_rpi = 2
NETID_megaNRF24 = 3
NETID_megaXBEE0 = 4
NETID_megaXBEE1 = 4
NETID_megaNO_RADIO = 5
NETID_unoNRF24 = 3
NETID_unoXBEE0 = 4
NETID_unoXBEE1 = 4
NETID_unoNO_RADIO = 5

NETID_promini8NRF24 = 3
NETID_promini8XBEE0 = 4
NETID_promini8XBEE1 = 4
NETID_promini8NO_RADIO = 5

NETID_promini16NRF24 = 3
NETID_promini16XBEE0 = 4
NETID_promini16XBEE1 = 4
NETID_promini16NO_RADIO = 5

NETNAME_0 = cc1000
NETNAME_1 = cc2420
NETNAME_2 = wifi-udp
NETNAME_3 = nrf24
NETNAME_4 = xbee
NETNAME_5 = NoRadio

ifeq ($(NET_ID),)
  NET_ID = $(NETID_$(MOTE)$(INO_RADIO))
  NET_NAME = $(NETNAME_$(NET_ID))
else
  ifeq ($(shell echo "$(NET_ID)<0 || $(NET_ID)>30" | bc), 1)
    $(error 'in NET_ID:xx , xx must be in 0..30')
  endif
  NET_NAME = (?)
endif

NET_ID ?= $(NETID_$(MOTE)$(INO_RADIO))
ifeq ($(shell echo "$(NET_ID)<0 || $(NET_ID)>30" | bc), 1)
    $(error 'in NET_ID=xx , xx must be in 0..30')
endif



MOTE_ADDR = $(shell echo $(NET_ID)*2048 + $(INSTALL) | bc)
CFLAGS += -DNET_ID=$(NET_ID)
CFLAGS += -DTERRA_NODE_ID=$(MOTE_ADDR)


CFLAGS += -I$(TERRA_APPDIR)/lib/serial
CFLAGS += -I$(TERRA_APPDIR)/interfaces
CFLAGS += -I$(TERRA_APPDIR)/system

# build TinyOS Version ID number (211 ... 212)
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  TOSVERSION = $(subst .,,$(subst /opt/tinyos-,,$(TOSROOT)))
else
  TOSVERSION = 0.0.0
endif

#
# Define generic configuration flags
#
ifeq ($(MOTE),mica2)
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  PFLAGS += -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(MOTE),mica2dot)
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  PFLAGS += -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(MOTE),micaz)
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(MOTE),iris)
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(MOTE),telosb)
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -Os
endif

ifneq ($(filter $(MOTE),$(INO_UNO_TARGETS)),)
  CFLAGS += -O1
endif
ifneq ($(filter $(MOTE),$(INO_MEGA_TARGETS)),)
  CFLAGS += -O1
  CFLAGS += -DRFPOWER_IDX=$(RFPOWER)
endif
ifeq ($(MOTE),rpi)
  CFLAGS += -Os
endif


#
# Validate SENSOR and define SENSORBOARD
#
ifeq ($(MOTE),mica2dot)
  ifneq ($(SENSOR),)
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2dot". Currently Mica2Dot supports only internal temperature sensor.)
  endif
endif
ifneq ($(filter $(MOTE),micaz mica2 iris),)
  SENSOR ?= MDA100
  SENSORX = $(shell echo $(SENSOR) | tr a-z A-Z)
  ifeq ($(SENSORX) , MTS300CA)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CA -DSBOARD=300
  endif
  ifeq ($(SENSORX) , MTS300CB)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CB -DSBOARD=300
  endif
  ifeq ($(SENSORX) , MDA100)
    SENSORBOARD = mda100
    CFLAGS += -DMDA100
    CFLAGS += -I$(TOSDIR)/sensorboards/mda100/cb -DSBOARD=100
  endif
  ifeq ($(SENSORBOARD),)
    $(error Invalid SENSOR value "$(SENSOR)" for "$(MOTE)". Options are: MTS300CA, MTS300CB, MDA100)
  endif	
endif


$(info ***********************)
$(info **** Configuration ****)
$(info MOTE        = $(MOTE))
$(info VM          = $(VM))
$(info NET_ID      = $(NET_ID) ($(NET_NAME)))
$(info MOTE_ID     = $(INSTALL))
$(info MOTE_ADDR   = $(MOTE_ADDR) ($(NET_ID):$(INSTALL)))
$(info RFPOWER     = $(RFPOWER))
$(info LPL         = $(LPL))
$(info SENSORBOARD = $(SENSORBOARD))
$(info TYPE        = $(TYPE))
$(info TOSVERSION  = $(TOSVERSION))
$(info ***********************)
$(info Make Cmds- $(MAKECMDGOALS))

PFLAGS += -fno-strict-aliasing # required for accessing VARS


CFLAGS += -DNO_DEBUG
#CFLAGS += -DPRINTF
#CFLAGS += -I$(TOSDIR)/lib/printf

COMPONENT   = TerraBeaconAppC

ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  include $(MAKERULES)
else ifneq ($(filter $(MOTE),$(INO_TARGETS)),)
  include Makefile_ino
else ifneq ($(filter $(MOTE),$(IX_TARGETS)),)
  include Makefile_ix
endif

