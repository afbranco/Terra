#
#TerraVM make parameters
#
# Configure sensorboard: mts300a or mts300b(wired) or mda100 | default mda100
# SENSOR=xxx
#
# Generate short queues and long vm memory (Smart Office version) | default blank
#    QUEUE=SHORT
#
# Configure runtime type: BS or NOBS or ALL | default ALL
#    TYPE=xxx
#
# Hybrid mode: YES => TelosB Mem.Blocks = micaz Mem.Blocks or NO=> TelosB Large Mem.Blocks | Default YES
#  HYB=xxx
#
# Command line example
#  make micaz TYPE=NOBS QUEUE=SHORT install.2 mib520,/dev/ttyUSB0 HYB=NO


#TinyOS micaz radio power
DCC2420_DEF_RFPOWER=3 #(1..9)

# build TinyOS Version ID (211 ... 212)
TOSVERSION = $(subst .,,$(subst /opt/tinyos-,,$(TOSROOT)))

ifneq ($(findstring mica2,$(MAKECMDGOALS)),)
 PFLAGS=-DCC1K_DEF_FREQ=916400000
 MOTE=mica2
 HYB=YES
endif
ifneq ($(findstring micaz,$(MAKECMDGOALS)),)
 #PFLAGS += -DCC2420_DEF_RFPOWER=3
 MOTE=micaz
 HYB=YES
endif
ifneq ($(findstring telosb,$(MAKECMDGOALS)),)
 MOTE=telosb
endif


ifneq ($(findstring mica,$(MAKECMDGOALS)),)
 #SENSOR ?= mts300a
 SENSOR ?= mda100
 ifeq ($(SENSOR) , mts300a)
  SENSORBOARD = mts300
  CFLAGS += -DMTS300CA
  PFLAGS += -DMTS300CA
 endif
 ifeq ($(SENSOR) , mts300b)
  SENSORBOARD = mts300
  CFLAGS += -DMTS300CB
  PFLAGS += -DMTS300CB
 endif
 ifeq ($(SENSOR) , mda100)
  SENSORBOARD = mda100
  CFLAGS += -DMDA100
  CFLAGS += -I$(TOSDIR)/sensorboards/mda100/cb
 endif
endif

TYPE ?= ALL
QUEUE ?= LONG
HYB ?= YES


ifeq ($(HYB),YES)
 MBLOCKS_MIN_SHORT = 40
 MBLOCKS_MIN_LONG = 62
 MBLOCKS_REGULAR_SHORT = 58
 MBLOCKS_REGULAR_LONG = 68
else
 MBLOCKS_MIN_SHORT = 80
 MBLOCKS_MIN_LONG = 80
 MBLOCKS_REGULAR_SHORT = 80
 MBLOCKS_REGULAR_LONG = 80
endif

ifeq ($(TYPE),BS)
  CFLAGS += -DONLY_BSTATION
  ifeq ($(QUEUE) , SHORT)
    CFLAGS += -DSHORT_QUEUES
    MEM_BLKS=$(MBLOCKS_REGULAR_LONG)
  else
    MEM_BLKS=$(MBLOCKS_REGULAR_SHORT)
  endif
endif 
ifeq ($(TYPE),NOBS)
 CFLAGS += -DNO_BSTATION
  ifeq ($(QUEUE) , SHORT)
    CFLAGS += -DSHORT_QUEUES
    MEM_BLKS=$(MBLOCKS_REGULAR_LONG)
  else
    MEM_BLKS=$(MBLOCKS_REGULAR_SHORT)
  endif
endif
ifeq ($(TYPE),ALL)
  ifeq ($(QUEUE) , SHORT)
    CFLAGS += -DSHORT_QUEUES
    MEM_BLKS=$(MBLOCKS_MIN_LONG)
  else
    MEM_BLKS=$(MBLOCKS_MIN_SHORT)
  endif
endif

# force short memory - test with printf
#MEM_BLKS=$(MBLOCKS_REGULAR_SHORT)

CFLAGS += -DVM_MEM_BLKS=$(MEM_BLKS) -DTOSVER=$(TOSVERSION)

DCC2420_DEF_RFPOWER ?= 3

$(info ***********************)
$(info **** Configuration ****)
$(info MOTE        = $(MOTE))
$(info SENSORBOARD = $(SENSORBOARD))
$(info TYPE        = $(TYPE))
$(info QUEUE       = $(QUEUE))
$(info VM_MEM_BLKS = $(MEM_BLKS))
$(info TOSVERSION  = $(TOSVERSION))
$(info ***********************)

PFLAGS += -fno-strict-aliasing # required for accessing VARS
MSG_SIZE = 29

CFLAGS += -DNO_DEBUG 
CFLAGS += -I. -ICustomVMs/TerraNet/ 
CFLAGS += -I$(TOSDIR)/lib/net/ -I$(TOSDIR)/lib/net/ctp  -I$(TOSDIR)/lib/net/4bitle
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


