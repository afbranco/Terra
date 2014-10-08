#
#TerraVM make parameters
#
# Define target VM to build: NET or GRP | default NET
#    VM=GRP
#
# Define additional modules: FFT,VOLCANO,MSGQ | default ''
#    MOD=FFT,VOLCANO | MOD=FFT
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
# Verbose Compilation mode: YES or NO | Default NO
#    VERB=YES
#
# SetData functionality: YES or NO | default NO
#    SETDATA=NO
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
  ifneq ($(VM),INO)
    $(error VM must be "NET" or "GRP" or "INO")
  endif
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

# Verbose mode
ifeq ($(VERB),YES)
	CFLAGS += -v
endif


#
# define root APP dir
#
APPDIR = $(shell pwd)
INODIR = /home/branco/gitspace/Terra/nescino/src/ino

#
# Define VM path
#
ifeq ($(VM),NET)
	VMDIR = $(APPDIR)/CustomVMs/TerraNet
endif
ifeq ($(VM),GRP)
	VMDIR = $(APPDIR)/CustomVMs/TerraGrp
	PFLAGS += -DMODULE_CTP
	CFLAGS += -I$(TOSDIR)/lib/net/ -I$(TOSDIR)/lib/net/4bitle -I$(TOSDIR)/lib/net/ctp 
endif
ifeq ($(VM),INO)
	VMDIR = $(APPDIR)/CustomVMs/TerraIno
	CFLAGS += -I$(INODIR) -DINO
endif

#
# Define XComps path
#
XCOMPSDIR = $(APPDIR)/XComps


# build TinyOS Version ID number (211 ... 212)
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
ifeq (iris,$(word 1,$(MAKECMDGOALS)))
  ifeq ($(VM),INO)
    MOTE=ino
  else
    MOTE=iris
  endif
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
  MB_SHORT_ALL = 88
  MB_SHORT_NOBS = 96
  MB_LONG_ALL = 68
  MB_LONG_NOBS = 75
  MB_TELOSB    = 250
else ifeq ($(VM),GRP)
  MB_SHORT_ALL =28
  MB_SHORT_NOBS = 36
  MB_LONG_ALL = 14
  MB_LONG_NOBS = 14
  MB_TELOSB    = 200
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
    MBLOCKS = $(MB_TELOSB)               # Telos; NO HYB
  endif
endif

# Define MemBlocks Size for each additional module/operations
M_SETDATA = 14
M_MSGQ = 8
M_FFT = 0     # ???
M_VOLCANO = 0 # ???


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


# Reset MODULES if VM!=NET
ifeq ($(VM) , GRP)
	MODULES = 'Not applicable'
else
	MODULES = $(MOD)
endif
# Additional modules -I flag
ifneq ($(findstring FFT,$(MODULES)),)
    CFLAGS += -DM_FFT
    DM_FFT = $(M_FFT)
else
    DM_FFT = 0
endif
ifneq ($(findstring VOLCANO,$(MODULES)),)
    CFLAGS += -DM_VOLCANO
    DM_VOLCANO = $(M_VOLCANO)
else
    DM_VOLCANO = 0
endif
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
MBLOCKS_F = $(shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA}-${DM_FFT}-${DM_VOLCANO} | bc)
# force short memory - test with printf
# MBLOCKS=40
CFLAGS += -DVM_MEM_BLKS=$(MBLOCKS_F) -DTOSVER=$(TOSVERSION)
# $(info shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA}-${DM_FFT}-${DM_VOLCANO})


$(info ***********************)
$(info **** Configuration ****)
$(info VM          = $(VM))
$(info MODULES     = $(MODULES) -- [FFT,VOLCANO,MSGQ])
$(info MOTE        = $(MOTE))
$(info RFPOWER     = $(RFPOWER))
$(info SENSORBOARD = $(SENSORBOARD))
$(info TYPE        = $(TYPE))
$(info HYB         = $(HYB))
$(info SETDATA     = $(SETDATA))
$(info QUEUE       = $(QUEUE))
$(info VM_MEM_BLKS = $(MBLOCKS_F))
$(info VM_MEM      = $(shell echo ${MBLOCKS_F}*24 | bc))
$(info TOSVERSION  = $(TOSVERSION))
$(info ***********************)
$(info Make Cmds- $(MAKECMDGOALS))

PFLAGS += -fno-strict-aliasing # required for accessing VARS
MSG_SIZE = 29
#MSG_SIZE = 34

CFLAGS += -DNO_DEBUG 
CFLAGS += -I. -I$(VMDIR) -I$(XCOMPSDIR)
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

ifeq (ino,$(word 2,$(MAKECMDGOALS)))
  include Makefile_ino
else
  include $(MAKERULES)
endif




