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
# Define mote type: 1..254 | Default 1
#    MOTE_TYPE=2
#
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
#    INO_RADIO=NO_RADIO
#
# INO_HALF_CLOCK Divide Arduino MCU Clock by 2. Apply when powering ProMini_16MHz(5v) with 3.3v 
# INO_HALF_CLOCK=YES
#
# Low Power Listening mode: YES or NO | default NO
#    LPL=NO
#
# Debug "dbg() mode for Linux: YES or NO | default NO
#    DEBUG=YES
#
# ESP WIFI SSID:  <input ssid> | default iot_terra
#    WIFI_SSID=ssid_rede
#
# ESP WIFI PASSWORD:  <input password> | default projeto_terra
#    WIFI_PASSWD=senha_rede
#
# NODE ID: 1..2047 | default 1
# install.3 
#
# BS_BAUD: 115200, 57600, 19200 | default <platform specific or 19200>
# BS_BAUD=57600
# OBS: Platform specific = telosb, tmote, eyes, intelmote2 => 115200; micaz,mica2, iris => 57600; mica2dot=>19200
# OBS2: Do not change baudrate for mica2dot.
#
# NET ID: 0..30 | default 0:cc1000, 1:cc2420, 2:wifi-udp, 3:esp, 4:nrf24, 5:xbee 
# NET_ID=2
#
# Command line examples
#  make micaz  VM=GRP TYPE=NOBS QUEUE=SHORT install.2 mib520,/dev/ttyUSB0
#  make esp TYPE=BOTH MOD=MSGQ  DEBUG=YES WIFI_SSID=terra_iot WIFI_PASSWD=projeto_iot install.10 serial,/dev/ttyUSB0
#  make rpi TYPE=NOBS MOD=MSGQ  DEBUG=YES install.4
#  make mica2dot TYPE=BOTH VM=NET MOD=MSGQ install.2 mib520,/dev/ttyUSB0
#  make mega TYPE=BOTH VM=NET MOD=MSGQ install.4

#==================================================================================
#==================================================================================

ALL_TARGETS = micaz mica2 mica2dot telosb iris uno mega rpi esp
TOS_TARGETS = micaz mica2 mica2dot telosb iris
INO_TARGETS = uno mega
IX_TARGETS = rpi
ESP_TARGETS = esp

#  Save makecmdgoals (a read only var) to goals so that we can modify it.
GOALS += $(MAKECMDGOALS)

#  Extract user options from goals of the form opt,arg, transform to opt=arg,
#  and evaluate.  Then, reduce GOALS to have the args removed.
OptRE := [,.]
GoalOpts := $(shell perl -e 'print join " ", map {s{^(.*?)$(OptRE)}{\U$$1=};$$_} grep /$(OptRE)/, split /\s+/, "$(GOALS)";')
GOALS := $(shell perl -e '$$_="$(GOALS)"; s{$(OptRE)\S*}{}g; print;')
$(foreach opt,$(GoalOpts),$(eval $(opt)))

# Extract Target mote
MOTE = $(word 1,$(MAKECMDGOALS))

# Check simulator sim-sf mode
ifneq ($(filter sim-sf,$(GOALS)),)
	TOSSIM=YES
else
	TOSSIM=NO
endif


# Valid motes
ifeq ($(filter $(MOTE),$(ALL_TARGETS)),)
      $(error Target mote must be: micaz, mica2, mica2dot, telosb, uno, mega, rpi, or esp)
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


ifneq ($(filter $(MOTE),$(ESP_TARGETS)),)
	WIFI_SSID ?= iot_terra
	WIFI_PASSWD ?= projeto_terra
else
  ifneq ($(WIFI_SSID),)
      $(error WIFI_SSID must be used only for: $(ESP_TARGETS))
  endif
  ifneq ($(WIFI_PASSWD),)
      $(error WIFI_PASSWD must be used only for: $(ESP_TARGETS))
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
ifneq ($(findstring rpi,$(MAKECMDGOALS)),)
  ifneq ($(TYPE),NOBS)
    $(error 'Target rpi must have TYPE=NOBS. TYPE=BOTH is not implemented, yet!')
  endif
endif

DEBUG ?= YES
ifneq ($(DEBUG),YES)
  ifneq ($(DEBUG),NO)
    $(error DEBUG must be "YES" or "NO")
  endif
endif

MOTE_TYPE ?= 1
ifeq ($(shell echo "$(MOTE_TYPE)<1 || $(MOTE_TYPE)>254" | bc), 1)
    $(error 'MOTE_TYPE must be 1..254')
endif
CFLAGS += -DMOTE_TYPE=$(MOTE_TYPE)

INSTALL ?= 1
ifeq ($(shell echo "$(INSTALL)<1 || $(INSTALL)>2047" | bc), 1)
    $(error 'in [install,xx] , xx must be in 1..2047')
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

INO_HALF_CLOCK ?= NO
ifneq ($(INO_HALF_CLOCK),YES)
  ifneq ($(INO_HALF_CLOCK),NO)
    $(error INO_HALF_CLOCK must be "YES" or "NO")
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

# dbg() mode in linux
ifeq ($(DEBUG),NO)
	CFLAGS += -DNO_DEBUG
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
	CFLAGS += -I. 
	ifeq ($(TOSSIM) , YES)
		CFLAGS += -I/opt/tinyos-2.1.2/tos/lib/tossim/sf/sim/ -I/opt/tinyos-2.1.2/tos/platforms/micaz/
	endif
	CFLAGS +=  -I$(COMMONDIR) -I$(VMDIR) 
  else
  	COMMONDIR = $(APPDIR)/platforms/TinyOS/common
	VMDIR = $(APPDIR)/platforms/TinyOS/Grp
	CFLAGS += -I. 
	ifeq ($(TOSSIM) , YES)
		CFLAGS += -I/opt/tinyos-2.1.2/tos/lib/tossim/sf/sim/ -I/opt/tinyos-2.1.2/tos/platforms/micaz/
	endif
	CFLAGS +=  -I$(COMMONDIR) -I$(VMDIR) 
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
	CFLAGS += -I. -I$(VMDIR) -DLINUX
endif
ifeq ($(MOTE),esp)
	VMDIR = $(APPDIR)/platforms/esp
	CFLAGS += -I. -I$(VMDIR) -DESP
endif

# default 0:cc1000, 1:cc2420, 2:wifi-udp, 3:esp, 4:nrf24, 5:xbee
NETID_mica2 = 0
NETID_mica2dot = 0
NETID_micaz = 1
NETID_telosb = 1
NETID_iris = 1
NETID_esp = 2
NETID_rpi = 2
NETID_megaNRF24 = 4
NETID_megaXBEE0 = 5
NETID_megaXBEE1 = 5
NETID_megaNO_RADIO = 5
NETID_unoNRF24 = 4
NETID_unoXBEE0 = 5
NETID_unoXBEE1 = 5
NETID_unoNO_RADIO = 5

NET_ID ?= $(NETID_$(MOTE)$(INO_RADIO))
ifeq ($(shell echo "$(NET_ID)<0 || $(NET_ID)>30" | bc), 1)
    $(error 'in NET_ID=xx , xx must be in 0..30')
endif

MOTE_ADDR = $(shell echo $(NET_ID)*2048 + $(INSTALL) | bc)
CFLAGS += -DNET_ID=$(NET_ID)
CFLAGS += -DTERRA_NODE_ID=$(MOTE_ADDR)

# Defaul values for serial baudrate
BAUD_mica2 = 57600
BAUD_micaz = 57600
BAUD_mica2dot = 19200
BAUD_telosb = 115200
BAUD_iris = 57600
BAUD_rpi = 57600
BAUD_esp = 57600
BAUD_mega = 57600
BAUD_uno = 57600
ALL_BAUDS = 19200 57600 115200

BS_BAUD ?= $(BAUD_$(MOTE))
ifneq ($(filter $(BS_BAUD),$(ALL_BAUDS)),)
  ifneq ($(MOTE),mica2dot) # Do not change for mica2dot. Original mica2dot baudrate is 19200.
    CFLAGS+= -DPLATFORM_BAUDRATE=$(BS_BAUD)ul
  endif
else
    $(error BS_BAUD must be: $(ALL_BAUDS))
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
  # INO_HALF_CLOCK config
  ifeq ($(INO_HALF_CLOCK),YES)
    CFLAGS += -DINO_HALF_CLOCK
  endif
endif
ifeq ($(MOTE),mega)
  CFLAGS += -O1
  CFLAGS += -DRFPOWER_IDX=$(RFPOWER)
endif
ifeq ($(MOTE),rpi)
  CFLAGS += -Os
endif
ifeq ($(MOTE),esp)
  CFLAGS += -Os
  CFLAGS += -DWIFI_SSID=\"$(WIFI_SSID)\" -DWIFI_PASSWORD=\"$(WIFI_PASSWD)\"
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
  override INSTALL := $(MOTE_ADDR)
  ifneq ($(filter $(MOTE),micaz mica2 mica2dot),) # 4KB RAM
    ifeq ($(VM),NET)
      MB_SHORT_ALL = 90
      MB_SHORT_NOBS = 100
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
        MBLOCKS = 200
  endif
else ifneq ($(filter $(MOTE),uno),) # 2KB RAM
        MBLOCKS = 14
else ifneq ($(filter $(MOTE),mega),) # 8KB RAM
        MBLOCKS = 220
else ifneq ($(filter $(MOTE),rpi),) # xxxKB RAM
        MBLOCKS = 220  
else ifneq ($(filter $(MOTE),esp),) # xxxKB RAM
        MBLOCKS = 100  
endif

# Greayes value for MBLOCKS considering all platforms
GENERAL_MAX__BLKS = 220

# Define MemBlocks Size for each additional module/operations
M_SETDATA = 16
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
BLOCK_SIZE = 22
MBLOCKS_F = $(shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA} | bc)
# force short memory - test with printf
# MBLOCKS=40
CFLAGS += -DVM_MEM_BLKS=$(MBLOCKS_F)
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  CFLAGS += -DTOSVER=$(TOSVERSION)
endif
#$(info shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA})


$(info ***********************)
$(info **** Configuration ****)
$(info MOTE        = $(MOTE))
$(info TOSSIM      = $(TOSSIM))
$(info DEBUG       = $(DEBUG))
$(info VM          = $(VM))
$(info MODULES     = $(MODULES) -- [MSGQ])
$(info NET_ID      = $(NET_ID))
$(info MOTE_ID     = $(INSTALL))
$(info MOTE_ADDR   = $(MOTE_ADDR))
$(info MOTE_TYPE   = $(MOTE_TYPE))
$(info RFPOWER     = $(RFPOWER))
$(info LPL         = $(LPL))
$(info SENSORBOARD = $(SENSORBOARD))
$(info TYPE        = $(TYPE))
$(info SETDATA     = $(SETDATA))
$(info QUEUE       = $(QUEUE))
$(info VM_MEM_BLKS = $(MBLOCKS_F))
$(info VM_MEM      = $(shell echo ${MBLOCKS_F}*${BLOCK_SIZE} | bc))
$(info TOSVERSION  = $(TOSVERSION))
$(info ***********************)
$(info Make Cmds- $(MAKECMDGOALS))

PFLAGS += -fno-strict-aliasing # required for accessing VARS



#PFLAGS += -I$(TOSROOT)/tos/lib/printf
#PFLAGS += -DNEW_PRINTF_SEMANTICS

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
else ifneq ($(filter $(MOTE),$(ESP_TARGETS)),)
  include Makefile_esp
endif

