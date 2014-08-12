#
#TerraVM make parameters
#
# Define target VM to build: NET or GRP | default NET
#    VM=GRP
#
# Configure sensorboard: MTS300CA or MTS300CB(wired) or MDA100 | default MDA100
#    SENSOR=MTS300CA
#
# Generate short queues and long vm memory (Smart Office version) | default SHORT
#    QUEUE=LONG
#
# Configure runtime type: BS or NOBS or ALL | default ALL
#    TYPE=BS
#
# Hybrid mode: YES => TelosB Mem.Blocks = micaz Mem.Blocks or NO=> TelosB Large Mem.Blocks | Default YES
#    HYB=NO
#
# MicaZ/TelosB RF Power: 03 07 11 15 19 23 27 31 | default 03
#    RFPOWER=03
#                       Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
#
# Command line examples
#  make micaz  VM=GRP TYPE=NOBS QUEUE=SHORT install.2 mib520,/dev/ttyUSB0 HYB=NO

#
# Check options
#
VM ?= NET
ifneq ($(VM),NET)
  ifneq ($(VM),GRP)
    $(error VM must be "NET" or "GRP")
  endif
endif

QUEUE ?= SHORT
ifneq ($(QUEUE),SHORT)
  ifneq ($(QUEUE),LONG)
    $(error QUEUE must be "SHORT" or "LONG")
  endif
endif

HYB ?= YES
ifneq ($(HYB),YES)
  ifneq ($(HYB),NO)
    $(error HYB must be "YES" or "NO")
  endif
endif

TYPE ?= ALL
ifneq ($(findstring sim,$(MAKECMDGOALS)),)
  ifneq ($(TYPE),ALL)
    $(error 'If target is the simulator, then TYPE must be ALL')
  endif
endif

#TinyOS micaz default radio power
RFPOWER ?= 03
ifneq ($(findstring $(RFPOWER), 0 1 2 3 4 5 6 7 8 9),)
    $(error 'RFPOWER must have 2 digit value: 03 07 11 15 19 23 27 31')
endif

ifeq ($(findstring $(RFPOWER), 03 07 11 15 19 23 27 31),)
    $(error 'RFPOWER must have one of these numbers: 03 07 11 15 19 23 27 31')
endif

#
# Define VM path
#
ifeq ($(VM),NET)
	VMDIR = CustomVMs/TerraNet/
endif
ifeq ($(VM),GRP)
	VMDIR = CustomVMs/TerraGrp/
	PFLAGS += -DMODULE_CTP
endif

# build TinyOS Version ID (211 ... 212)
TOSVERSION = $(subst .,,$(subst /opt/tinyos-,,$(TOSROOT)))

#
# Define generic configuration flags
#
ifeq (mica2,$(word 1,$(MAKECMDGOALS)))
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  MOTE=mica2
  HYB=YES
endif
ifeq (mica2dot,$(word 1,$(MAKECMDGOALS)))
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  MOTE=mica2dot
  HYB=YES
endif
ifeq (micaz,$(word 1,$(MAKECMDGOALS)))
  PFLAGS += -DCC2420_DEF_RFPOWER=$(RFPOWER)
  MOTE=micaz
  HYB=YES
endif
ifeq (telosb,$(word 1,$(MAKECMDGOALS)))
  PFLAGS += -DCC2420_DEF_RFPOWER=$(RFPOWER)
  MOTE=telosb
endif

#
# Validate SENSOR and define SENSORBOARD
#
ifeq ($(MAKECMDGOALS), mica2dot)
  SENSOR ?=MTS310CA
  ifneq ($(SENSOR),MTS310CA)
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2dot". Option is: MTS310CA)
  endif
  ifeq ($(SENSOR),MTS310CA)
    SENSORBOARD = mts300
    CFLAGS += -DMTS310CA
  endif
endif
ifneq ($(MAKECMDGOALS), mica2dot)
ifneq ($(findstring mica,$(MAKECMDGOALS)),)
  SENSOR ?= MDA100
  ifeq ($(SENSOR) , MTS300CA)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CA
  endif
  ifeq ($(SENSOR) , MTS300CB)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CB
  endif
  ifeq ($(SENSOR) , MDA100)
    SENSORBOARD = mda100
    CFLAGS += -DMDA100
    CFLAGS += -I$(TOSDIR)/sensorboards/mda100/cb
  endif
  ifndef SENSORBOARD
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2". Options are: MTS300CA, MTS300CB, MDA100)
  endif	
endif
endif


#
# define VM memory use
#
ifeq ($(VM),NET)
  MB_SHORT_ALL = 64
  MB_SHORT_NOBS = 72
  MB_LONG_ALL = 46
  MB_LONG_NOBS = 54
else ifeq ($(VM),GRP)
  MB_SHORT_ALL = 16
  MB_SHORT_NOBS = 22
  MB_LONG_ALL = 12
  MB_LONG_NOBS = 12
endif

ifeq ($(HYB),YES) # Same value for all types
  ifeq ($(QUEUE) , SHORT)
    ifeq ($(TYPE),ALL)
      MBLOCKS = $(MB_SHORT_ALL)             # any;  ALL; SHORT
    else 
      MBLOCKS = $(MB_SHORT_NOBS)             # any; NOBS; SHORT
    endif
  else # QUEUE = LONG
    ifeq ($(TYPE),ALL)
      MBLOCKS = $(MB_LONG_ALL)             # any;  All; LONG
    else
      MBLOCKS = $(MB_LONG_NOBS)             # any; NOBS; LONG
    endif
  endif
else # HYB=NO
# Mica2, Mica2Dot, MicaZ
  ifneq ($(findstring mica,$(MOTE)),) # All mica? types
    ifeq ($(QUEUE) , SHORT)
      ifeq ($(TYPE),ALL)
        MBLOCKS = $(MB_SHORT_ALL)             # Mica?;  ALL; SHORT
      else 
        MBLOCKS = $(MB_SHORT_NOBS)             # Mica?; NOBS; SHORT
      endif
    else # QUEUE = LONG
      ifeq ($(TYPE),ALL)
        MBLOCKS = $(MB_LONG_ALL)             # Mica?;  All; LONG
      else
        MBLOCKS = $(MB_LONG_NOBS)             # Mica?; NOBS; LONG
      endif
    endif
  endif
# TelosB
  ifeq ($(MOTE),telosb)
    MBLOCKS = 128               # Telos; NO HYB
  endif
endif


#
# Configure BS and QUEUE defines
ifeq ($(TYPE),BS)
  CFLAGS += -DONLY_BSTATION
else ifeq ($(TYPE),NOBS)
  CFLAGS += -DNO_BSTATION
endif

ifeq ($(QUEUE) , SHORT)
    CFLAGS += -DSHORT_QUEUES
endif


# force short memory - test with printf
# MBLOCKS=40

CFLAGS += -DVM_MEM_BLKS=$(MBLOCKS) -DTOSVER=$(TOSVERSION)

$(info ***********************)
$(info **** Configuration ****)
$(info VM          = $(VM))
$(info MOTE        = $(MOTE))
$(info SENSORBOARD = $(SENSORBOARD))
$(info TYPE        = $(TYPE))
$(info HYB         = $(HYB))
$(info QUEUE       = $(QUEUE))
$(info VM_MEM_BLKS = $(MBLOCKS))
$(info TOSVERSION  = $(TOSVERSION))
$(info ***********************)

PFLAGS += -fno-strict-aliasing # required for accessing VARS
MSG_SIZE = 29
#MSG_SIZE = 34

CFLAGS += -DNO_DEBUG 
CFLAGS += -I. -I$(VMDIR) 
CFLAGS += -I$(TOSDIR)/lib/net/ -I$(TOSDIR)/lib/net/4bitle -I$(TOSDIR)/lib/net/ctp 
#CFLAGS += -DPRINTF
#CFLAGS += -I$(TOSDIR)/lib/printf

COMPONENT   = TerraVMAppC

BUILD_EXTRA_DEPS = newProgVersionMsg.java newProgBlockMsg.java reqProgBlockMsg.java setDataNDMsg.java reqDataMsg.java usrMsg.java

newProgVersionMsg.java: BasicServices.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=newProgVersionMsg BasicServices.h newProgVersion -o $@

newProgBlockMsg.java: BasicServices.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=newProgBlockMsg BasicServices.h newProgBlock -o $@

reqProgBlockMsg.java: BasicServices.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=reqProgBlockMsg BasicServices.h reqProgBlock -o $@

setDataNDMsg.java: BasicServices.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=setDataNDMsg BasicServices.h setDataND -o $@

reqDataMsg.java: BasicServices.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=reqDataMsg BasicServices.h reqData -o $@

usrMsg.java: CustomVMs/TerraNet/usrMsg.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=usrMsg CustomVMs/TerraNet/usrMsg.h usrMsg -o $@

include $(MAKERULES)


