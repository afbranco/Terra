#
#TerraVM make parameters
#
# Define target VM to build: NET, GRP, INOX, INOS, IX | default NET
#    VM=GRP
#
# Define additional modules: FFT,VCN_DAT,VCN_DET,MSGQ | default ''
#    MOD=FFT,VCN_DAT,VCN_DET | MOD=FFT
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
# Hybrid mode: YES => TelosB/Iris Mem.Blocks = micaz Mem.Blocks or NO=> TelosB?Iris Large Mem.Blocks | Default YES
#    HYB=NO
#
# Verbose Compilation mode: YES or NO | Default NO
#    VERB=YES
#
# SetData functionality: YES or NO | default NO
#    SETDATA=NO
#
# RF Power: 0 1 2 3 4 5 6 7 | default 3
#    RFPOWER=1
#
# XBee USB Connection: 0 or 1 | default 1
#    INO_XBEE_USB=0
#
# Low Power Listening mode: YES or NO | default NO
#    LPL=NO
#
# Command line examples
#  make micaz  VM=GRP TYPE=NOBS QUEUE=SHORT install.2 mib520,/dev/ttyUSB0 HYB=NO



#
# Check options
#
VM ?= NET
ifneq ($(VM),NET)
 ifneq ($(VM),GRP)
  ifneq ($(VM),INOX)
   ifneq ($(VM),INOS)
    ifneq ($(VM),IX)
      $(error VM must be "NET" or "GRP" or "INOX" or "INOS" or "IX")
    endif
   endif
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

INO_XBEE_USB ?= 1
ifneq ($(INO_XBEE_USB),0)
  ifneq ($(INO_XBEE_USB),1)
    $(error INO_XBEE_USB must be "0" or "1")
  endif
endif

INO_INSTALL_PORT ?= /dev/ttyACM0

LPL ?= NO
ifneq ($(LPL),YES)
  ifneq ($(LPL),NO)
    $(error LPL must be "YES" or "NO")
  endif
endif


# Default radio power
RFPOWER ?= 1
ifeq ($(findstring $(RFPOWER), 0 1 2 3 4 5 6 7 ),)
    $(error 'RFPOWER must have 1 digit value: 0 1 2 3 4 5 6 7')
endif

# Verbose mode
ifeq ($(VERB),YES)
	CFLAGS += -v
endif


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
INODIR = /home/branco/gitspace/Terra/nescino/src/ino
IXDIR = /home/branco/gitspace/Terra/nescix/src

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
ifeq ($(VM),INOX)
	VMDIR = $(APPDIR)/CustomVMs/TerraIno
	CFLAGS += -I$(INODIR) -DINOX -DINO_XBEE_USB=$(INO_XBEE_USB)
endif
ifeq ($(VM),INOS)
	VMDIR = $(APPDIR)/CustomVMs/TerraIno
	CFLAGS += -I$(INODIR) -DINOS -DINO_XBEE_USB=$(INO_XBEE_USB)
endif
ifeq ($(VM),IX)
	VMDIR = $(APPDIR)/CustomVMs/TerraIx
	CFLAGS += -I$(IXDIR) -DIX
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
  PFLAGS += -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
  MOTE=mica2
  HYB=YES
endif
ifeq (mica2dot,$(word 1,$(MAKECMDGOALS)))
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  PFLAGS += -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
  MOTE=mica2dot
  HYB=YES
endif
ifeq (micaz,$(word 1,$(MAKECMDGOALS)))
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
  MOTE=micaz
  HYB=YES
endif
ifeq (iris,$(word 1,$(MAKECMDGOALS)))
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -O2
  MOTE=iris
endif
ifeq (telosb,$(word 1,$(MAKECMDGOALS)))
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(RFPOWER)
  CFLAGS += -Os
  MOTE=telosb
endif

ifeq (ino,$(word 2,$(MAKECMDGOALS)))
    MOTE=ino
    ifeq (mega,$(word 1,$(MAKECMDGOALS)))
        MODEL=MEGA
        CPU=atmega2560
    else 
    	ifeq (uno,$(word 1,$(MAKECMDGOALS)))
        	MODEL=UNO
        	CPU=atmega328p
        	$(error Ainda falta terminar a implementação para UNO/ATmega328. Entender melhor as alterações de https://github.com/jmattsson/tinyos-arduino para aplicar em Terra.)
    	else
        	$(error Invalid Arduino Board)
    	endif
    endif
    CFLAGS += -D$(MODEL)
endif

ifeq (ix,$(word 1,$(MAKECMDGOALS)))
  MOTE=ix
endif


#
# Validate SENSOR and define SENSORBOARD
#
ifeq ($(MAKECMDGOALS), mica2dot)
  ifneq ($(SENSOR),)
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2dot". Currently Mica2Dot supports only internal temperature sensor.)
  endif
endif
ifneq ($(MAKECMDGOALS), mica2dot)
ifneq ($(findstring mica,$(MAKECMDGOALS)),)
  SENSOR ?= MDA100
  ifeq ($(SENSOR) , MTS300CA)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CA -DSBOARD=300
  endif
  ifeq ($(SENSOR) , MTS300CB)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CB -DSBOARD=300
  endif
  ifeq ($(SENSOR) , MDA100)
    SENSORBOARD = mda100
    CFLAGS += -DMDA100
    CFLAGS += -I$(TOSDIR)/sensorboards/mda100/cb -DSBOARD=100
  endif
  ifndef SENSORBOARD
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2/micaz". Options are: MTS300CA, MTS300CB, MDA100)
  endif	
endif
endif
# repetindo para o Iris mote
ifneq ($(MAKECMDGOALS), mica2dot)
ifneq ($(findstring iris,$(MAKECMDGOALS)),)
  SENSOR ?= MDA100
  ifeq ($(SENSOR) , MTS300CA)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CA -DSBOARD=300
  endif
  ifeq ($(SENSOR) , MTS300CB)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CB -DSBOARD=300
  endif
  ifeq ($(SENSOR) , MDA100)
    SENSORBOARD = mda100
    CFLAGS += -DMDA100
    CFLAGS += -I$(TOSDIR)/sensorboards/mda100/cb -DSBOARD=100
  endif
  ifndef SENSORBOARD
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2/micaz". Options are: MTS300CA, MTS300CB, MDA100)
  endif	
endif
endif


#
# define VM memory use
#
ifeq ($(VM),NET)
  MB_SHORT_ALL = 80
  MB_SHORT_NOBS = 88
  MB_LONG_ALL = 64
  MB_LONG_NOBS = 71
  MB_TELOSB    = 184
  MB_IRIS    = 184
else ifeq ($(VM),GRP)
  MB_SHORT_ALL =24
  MB_SHORT_NOBS = 32
  MB_LONG_ALL = 10
  MB_LONG_NOBS = 10
  MB_TELOSB    = 184
  MB_IRIS    = 184
else ifeq ($(VM),INOX)
  MB_SHORT_ALL =120
  MB_SHORT_NOBS = 120
  MB_LONG_ALL = 150
  MB_LONG_NOBS = 150
else ifeq ($(VM),INOS)
  MB_SHORT_ALL =120
  MB_SHORT_NOBS = 120
  MB_LONG_ALL = 150
  MB_LONG_NOBS = 150
else ifeq ($(VM),IX)
  MB_SHORT_ALL =120
  MB_SHORT_NOBS = 120
  MB_LONG_ALL = 150
  MB_LONG_NOBS = 150
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
# Iris
  ifeq ($(MOTE),iris)
    MBLOCKS = $(MB_IRIS)               # Iris; NO HYB
  endif
# TelosB
  ifeq ($(MOTE),telosb)
    MBLOCKS = $(MB_TELOSB)               # Telos; NO HYB
  endif
# Ino Mega
  ifeq ($(MOTE),ino)
    MBLOCKS = $(MB_TELOSB)               # Telos; NO HYB
  endif
endif

# Define MemBlocks Size for each additional module/operations
M_SETDATA = 14
M_MSGQ = 8
M_FFT = 0    
M_VCN_DAT = 7
M_VCN_DET = 0


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
ifneq ($(findstring VCN_DAT,$(MODULES)),)
    CFLAGS += -DM_VCN_DAT
    DM_VCN_DAT = $(M_VCN_DAT)
else
    DM_VCN_DAT = 0
endif
ifneq ($(findstring VCN_DET,$(MODULES)),)
    CFLAGS += -DM_VCN_DET
    DM_VCN_DET = $(M_VCN_DET)
else
    DM_VCN_DET = 0
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
MBLOCKS_F = $(shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA}-${DM_FFT}-${DM_VCN_DAT}-${DM_VCN_DET} | bc)
# force short memory - test with printf
# MBLOCKS=40
CFLAGS += -DVM_MEM_BLKS=$(MBLOCKS_F) -DTOSVER=$(TOSVERSION)
#$(info shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA}-${DM_FFT}-${DM_VCN_DAT}-${DM_VCN_DET})


$(info ***********************)
$(info **** Configuration ****)
$(info VM          = $(VM))
$(info MODULES     = $(MODULES) -- [FFT,VCN_DAT,VCN_DET,MSGQ])
$(info MOTE        = $(MOTE) $(MODEL))
$(info RFPOWER     = $(RFPOWER))
$(info LPL         = $(LPL))
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
//CFLAGS += -DPRINTF
//CFLAGS += -I$(TOSDIR)/lib/printf


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
  ifneq ($(VM),INOX)
   ifneq ($(VM),INOS)
    $(error VM must be "INOX" or "INOS" for 'ino' platforms)
   endif 
  endif 
  include Makefile_ino
else
  ifeq (ix,$(word 1,$(MAKECMDGOALS)))
    ifneq ($(VM),IX)
      $(error VM must be "IX" for 'ix' platforms)
    endif 
    include Makefile_ix
  else
    include $(MAKERULES)
  endif
endif




