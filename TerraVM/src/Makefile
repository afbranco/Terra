#
#TerraVM make parameters
#
# Define target VM to build: NET, GRP | default NET
#    VM=GRP
#
# Define additional modules: MSGQ | default ''
#    MOD=MSGQ
#
# Configure sensorboard: MTS300CA or MTS300CB(wired) or MDA100 | default MDA100
#    SENSOR=MTS300CA
#
# Generate short queues and long vm memory (Smart Office version) | default SHORT
#    QUEUE=LONG
#
# Configure runtime type: NOBS or BOTH or BOTH2| default BOTH
#    TYPE=NOBS
#
# Configure ROOT node ID: integer 1..65534 | default 1
#    ROOT_ID=1
##
# Verbose Compilation mode: YES or NO | Default NO
#    VERB=YES
#
# SetData functionality: YES or NO | default NO
#    SETDATA=NO
#
# RF Power: 0 1 2 3 4 5 6 7 | default 7
#    RFPOWER=1
#
# INO_RADIO Connection: XBEE0 or XBEE1 or NRF24 or NO_RADIO| default NO_RADIO
#    INO_RADIO=XBEE0
#
# Low Power Listening mode: YES or NO | default NO
#    LPL=NO
#
# Command line examples
#  make micaz  VM=GRP TYPE=NOBS QUEUE=SHORT install.2 mib520,/dev/ttyUSB0
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
VM ?= NET
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  ifneq ($(VM),NET)
   ifneq ($(VM),GRP)
      $(error Mote "$(MOTE)" supports only VM=NET or VM=GRP)
   endif
  endif
else
  ifneq ($(VM),NET)
      $(error Mote "$(MOTE)" supports only VM=NET)
  endif
endif

QUEUE ?= SHORT
ifneq ($(QUEUE),SHORT)
  ifneq ($(QUEUE),LONG)
    $(error QUEUE must be "SHORT" or "LONG")
  endif
endif

VERB ?= NO
ifneq ($(VERB),YES)
  ifneq ($(VERB),NO)
    $(error VERB must be "YES" or "NO")
  endif
endif

SETDATA ?= NO
ifneq ($(SETDATA),YES)
  ifneq ($(SETDATA),NO)
    $(error SETDATA must be "YES" or "NO")
  endif
endif

TYPE ?= BOTH
ifneq ($(TYPE),BOTH)
  ifneq ($(TYPE),NOBS)
    ifneq ($(TYPE),BOTH2)
      $(error TYPE must be "BOTH" or "NOBS" or "BOTH2")
    endif
  endif
endif
ifneq ($(findstring sim,$(MAKECMDGOALS)),)
  ifneq ($(TYPE),BOTH)
    $(error 'If target is the micaz simulator, then TYPE must be BOTH')
  endif
endif

ROOT_ID ?= 1
ifeq ($(shell echo "$(ROOT_ID)<1 || $(ROOT_ID)>65534" | bc), 1)
    $(error 'ROOT_ID must be in 1..65534')
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


LPL ?= NO
ifneq ($(LPL),YES)
  ifneq ($(LPL),NO)
    $(error LPL must be "YES" or "NO")
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

# LPL config
ifeq ($(LPL),YES)
	CFLAGS += -DLPL_ON
	# 90 ms radio OFF
	SLEEP ?= 450
	# 700=10ms radio ON
	XCCA ?= 700
	CFLAGS += -DLOW_POWER_LISTENING
	CFLAGS += -DSLEEP=$(SLEEP) -DMAX_LPL_CCA_CHECKS=$(XCCA)
	CFLAGS += -DLPL_DEF_LOCAL_WAKEUP=$(SLEEP)
	CFLAGS += -DLPL_DEF_REMOTE_WAKEUP=$(SLEEP)
	CFLAGS += -DDELAY_AFTER_RECEIVE=20
endif


#
# define root APP dir
#
APPDIR = $(shell pwd)


#
# Define VM path
#
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  ifeq ($(VM),NET)
	COMMONDIR = $(APPDIR)/platforms/TinyOS/common
	VMDIR = $(APPDIR)/platforms/TinyOS/Net
	CFLAGS += -I. -I$(COMMONDIR) -I$(VMDIR) 
  else
  	COMMONDIR = $(APPDIR)/platforms/TinyOS/common
	VMDIR = $(APPDIR)/platforms/TinyOS/Grp
	CFLAGS += -I. -I$(COMMONDIR) -I$(VMDIR) 
	PFLAGS += -DMODULE_CTP
	CFLAGS += -I$(TOSDIR)/lib/net/ -I$(TOSDIR)/lib/net/4bitle -I$(TOSDIR)/lib/net/ctp 
  endif
endif

ifeq ($(MOTE),uno)
	VMDIR = $(APPDIR)/platforms/inoUno
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(INO_RADIO)
endif
ifeq ($(MOTE),mega)
	VMDIR = $(APPDIR)/platforms/inoMega
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(INO_RADIO)
endif
ifeq ($(MOTE),rpi)
	VMDIR = $(APPDIR)/platforms/RPi
	CFLAGS += -I. -I$(VMDIR) 
endif


CFLAGS += -I$(APPDIR)/interfaces
CFLAGS += -I$(APPDIR)/system
CFLAGS += -I$(APPDIR)/lib/serial

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


#
# define VM memory use
#

ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  ifneq ($(filter $(MOTE),micaz mica2 mica2dot),) # 4KB RAM
    ifeq ($(VM),NET)
      MB_SHORT_ALL = 80
      MB_SHORT_NOBS = 88
      MB_LONG_ALL = 64
      MB_LONG_NOBS = 71
    else
      MB_SHORT_ALL =24
      MB_SHORT_NOBS = 32
      MB_LONG_ALL = 10
      MB_LONG_NOBS = 10
    endif
    ifeq ($(QUEUE) , SHORT)
      ifeq ($(TYPE),BOTH)
        MBLOCKS = $(MB_SHORT_ALL)             # any;  ALL; SHORT
      else ifeq ($(TYPE),BOTH2)
        MBLOCKS = $(MB_SHORT_ALL)             # any;  ALL; SHORT
      else
        MBLOCKS = $(MB_SHORT_NOBS)             # any; NOBS; SHORT
      endif
    else # QUEUE = LONG
      ifeq ($(TYPE),BOTH)
        MBLOCKS = $(MB_LONG_ALL)             # any;  All; LONG
      else ifeq ($(TYPE),BOTH2)
        MBLOCKS = $(MB_LONG_ALL)             # any;  All; LONG
      else
        MBLOCKS = $(MB_LONG_NOBS)             # any; NOBS; LONG
      endif
    endif
  else ifneq ($(filter $(MOTE),iris telosb),) # 8KB RAM
        MBLOCKS = 220
  endif
else ifneq ($(filter $(MOTE),uno),) # 2KB RAM
        MBLOCKS = 14
else ifneq ($(filter $(MOTE),mega),) # 8KB RAM
        MBLOCKS = 220
else ifneq ($(filter $(MOTE),rpi),) # xxxKB RAM
        MBLOCKS = 220  
endif


# Define MemBlocks Size for each additional module/operations
M_SETDATA = 14
M_MSGQ = 8

#
# Configure BS and QUEUE defines
ifeq ($(TYPE),BOTH)
  CFLAGS += -DWITH_BSTATION
else ifeq ($(TYPE),BOTH2)
  CFLAGS += -DWITH_BSTATION -DWITH_AUX_BSTATION
else
  CFLAGS += -DNO_BSTATION
endif

ifeq ($(QUEUE) , SHORT)
    CFLAGS += -DSHORT_QUEUES
endif

# Define the ROOT_ID  node number
CFLAGS += -DROOT_ID=$(ROOT_ID)


# Reset MODULES if VM!=NET
ifeq ($(VM) , GRP)
	MODULES = 'Not applicable'
else
	MODULES = $(MOD)
endif
# Used memory by additional modules
ifneq ($(findstring MSGQ,$(MODULES)),)
    CFLAGS += -DM_MSG_QUEUE
    DM_MSGQ = $(M_MSGQ)
else
    DM_MSGQ = 0
endif
ifeq ($(SETDATA) , YES)
    CFLAGS += -DMODE_SETDATA
    DM_SETDATA = $(M_SETDATA)
else
    DM_SETDATA = 0
endif

# Calculate final MemBlocks
MBLOCKS_F = $(shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA} | bc)
# force short memory - test with printf
# MBLOCKS=40
CFLAGS += -DVM_MEM_BLKS=$(MBLOCKS_F)
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  CFLAGS += -DTOSVER=$(TOSVERSION)
endif
$(info shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA})


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

# Force micaz as mig platform
PLATFORM_MIG = micaz
COMPONENT   = TerraVMAppC

BUILD_EXTRA_DEPS = newProgVersionMsg.java newProgBlockMsg.java reqProgBlockMsg.java setDataNDMsg.java reqDataMsg.java usrMsg.java

newProgVersionMsg.java: BasicServices.h
	mig java -target=$(PLATFORM_MIG) $(CFLAGS) -java-classname=newProgVersionMsg BasicServices.h newProgVersion -o $@

newProgBlockMsg.java: BasicServices.h
	mig java -target=$(PLATFORM_MIG) $(CFLAGS) -java-classname=newProgBlockMsg BasicServices.h newProgBlock -o $@

reqProgBlockMsg.java: BasicServices.h
	mig java -target=$(PLATFORM_MIG) $(CFLAGS) -java-classname=reqProgBlockMsg BasicServices.h reqProgBlock -o $@

setDataNDMsg.java: BasicServices.h
	mig java -target=$(PLATFORM_MIG) $(CFLAGS) -java-classname=setDataNDMsg BasicServices.h setDataND -o $@

reqDataMsg.java: BasicServices.h
	mig java -target=$(PLATFORM_MIG) $(CFLAGS) -java-classname=reqDataMsg BasicServices.h reqData -o $@

usrMsg.java: platforms/TinyOS/Net/usrMsg.h
	mig java -target=$(PLATFORM_MIG) $(CFLAGS) -java-classname=usrMsg platforms/TinyOS/Net/usrMsg.h usrMsg -o $@

ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  include $(MAKERULES)
else ifneq ($(filter $(MOTE),$(INO_TARGETS)),)
  include Makefile_ino
else ifneq ($(filter $(MOTE),$(IX_TARGETS)),)
  include Makefile_ix
endif

