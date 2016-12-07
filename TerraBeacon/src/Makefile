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
# Command line examples
#  make uno INO_RADIO=NRF24 install.2 USB,/dev/ttyUSB0
#
#==================================================================================
#==================================================================================

ALL_TARGETS = micaz mica2 mica2dot telosb iris uno mega rpi
TOS_TARGETS = micaz mica2 mica2dot telosb iris
INO_TARGETS = uno mega
IX_TARGETS = rpi

# Extract Target mote
MOTE = $(word 1,$(MAKECMDGOALS))

# Valid motes
ifeq ($(filter $(MOTE),$(ALL_TARGETS)),)
      $(error Target mote must be: micaz, mica2, mica2dot, telosb, uno, mega, or rpi)
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

ifeq ($(MOTE),uno)
	VMDIR = $(TERRA_APPDIR)/platforms/inoUno
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(INO_RADIO)
endif
ifeq ($(MOTE),mega)
	VMDIR = $(TERRA_APPDIR)/platforms/inoMega
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(INO_RADIO)
endif
ifeq ($(MOTE),rpi)
	VMDIR = $(TERRA_APPDIR)/platforms/RPi
	CFLAGS += -I. -I$(VMDIR) 
endif


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

ifeq ($(MOTE),uno)
  CFLAGS += -O1
endif
ifeq ($(MOTE),mega)
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
$(info MODULES     = $(MODULES) -- [MSGQ])
$(info ROOT_ID     = $(ROOT_ID))
$(info RFPOWER     = $(RFPOWER))
$(info LPL         = $(LPL))
$(info SENSORBOARD = $(SENSORBOARD))
$(info TYPE        = $(TYPE))
$(info SETDATA     = $(SETDATA))
$(info QUEUE       = $(QUEUE))
$(info VM_MEM_BLKS = $(MBLOCKS_F))
$(info VM_MEM      = $(shell echo ${MBLOCKS_F}*24 | bc))
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

