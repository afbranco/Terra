#-------------
#  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
#  	Copyright (C) 2014-2017  Adriano Branco, Mauricio Pedro Vieira
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

# Command line examples
#  make micaz  VM:GRP TYPE:NOBS QUEUE:SHORT install.2 mib520,/dev/ttyUSB0
#  make esp TYPE:BOTH MOD:MSGQ  DEBUG:Y WIFI_SSID:terra_iot WIFI_PASSWD:projeto_iot install.10 serial,/dev/ttyUSB0
#  make rpi TYPE:NOBS MOD:MSGQ  DEBUG:Y install.4
#  make mica2dot TYPE=BOTH VM=NET MOD=MSGQ install.2 mib520,/dev/ttyUSB0
#  make mega TYPE=BOTH VM=NET MOD=MSGQ install.4

#==================================================================================
#==================================================================================

# Define targets
ALL_TARGETS = micaz mica2 mica2dot telosb iris uno mega rpi esp droid
TOS_TARGETS = micaz mica2 mica2dot telosb iris
INO_TARGETS = uno mega
IX_TARGETS = rpi
ESP_TARGETS = esp
DROID_TARGETS = droid

# Define family
micaz_FAMILY = TOS
mica2_FAMILY = TOS
mica2dot_FAMILY = TOS
telosb_FAMILY = TOS
iris_FAMILY = TOS
uno_FAMILY = INO
mega_FAMILY = INO
rpi_FAMILY = IX
droid_FAMILY = DROID
esp_FAMILY = ESP

# define options
ALL_OPTIONS = VM TYPE MOD INSTALL QUEUE DEBUG WIFI_SSID WIFI_PASSWD SENSOR MOTE_TYPE VERB SETDATA RFPOWER INO_HALF_CLOCK INO_RADIO USB SERIAL LPL IFLASH BS_BAUD NET_ID ANA0_REF ANA1_REF ANA2_REF ANA3_REF  INO_TOOLS_PATH HDFILE
TOS_OPTIONS = VM TYPE MOD INSTALL QUEUE DEBUG SENSOR MOTE_TYPE VERB SETDATA RFPOWER USB LPL IFLASH BS_BAUD NET_ID HDFILE
INO_OPTIONS = VM TYPE MOD INSTALL QUEUE DEBUG MOTE_TYPE VERB SETDATA RFPOWER INO_HALF_CLOCK INO_RADIO USB SERIAL IFLASH BS_BAUD NET_ID ANA0_REF ANA1_REF ANA2_REF ANA3_REF INO_TOOLS_PATH
IX_OPTIONS  = VM MOD INSTALL QUEUE DEBUG MOTE_TYPE VERB SETDATA IFLASH NET_ID
ESP_OPTIONS = VM TYPE MOD INSTALL QUEUE DEBUG WIFI_SSID WIFI_PASSWD MOTE_TYPE VERB SETDATA RFPOWER USB IFLASH BS_BAUD NET_ID
DROID_OPTIONS  = VM MOD INSTALL CLEAN QUEUE DEBUG MOTE_TYPE VERB SETDATA IFLASH NET_ID

# define MOD available values
MOD_VALUES = MSGQ STAT

#===================================================================================
#  Save makecmdgoals (a read only var) to goals so that we can modify it.
GOALS += $(MAKECMDGOALS) 

#  Extract user options from goals of the form opt,arg, transform to opt=arg,
#  and evaluate.  Then, reduce GOALS to have the args removed.
OptRE := [.:]
GoalOptsValues  := $(shell perl -e 'print join " ", map {s{^(.*?)$(OptRE)}{\U$$1=};$$_} grep /$(OptRE)/, split /\s+/, "$(GOALS)";')
GoalOpts        := $(shell echo $(shell perl -e 'print join " ", map {s{^(.*?)$(OptRE)}{\U$$1=};$$1} grep /$(OptRE)/, split /\s+/, "$(GOALS)";') | tr a-z A-Z) 
GOALS := $(shell perl -e '$$_="$(GOALS)"; s{$(OptRE)\S*}{}g; print;')
$(foreach opt,$(GoalOptsValues),$(eval __$(shell echo $(opt) | tr a-z A-Z)))

# If necessary, re-assignment USB without upper-case
USB_DEV = $(filter USB%,$(GoalOptsValues))
ifneq ($(USB_DEV),)
  $(eval __$(USB_DEV))
endif

# If necessary, re-assignment WIFI_SSID without upper-case
WIFI_SSID_ = $(filter WIFI_SSID%,$(GoalOptsValues))
ifneq ($(WIFI_SSID_),)
  $(eval __$(WIFI_SSID_))
endif

# If necessary, re-assignment WIFI_PASSWD without upper-case
WIFI_PASSWD_ = $(filter WIFI_PASSWD%,$(GoalOptsValues))
ifneq ($(WIFI_PASSWD_),)
  $(eval __$(WIFI_PASSWD_))
endif

# If necessary, re-assignment INO_TOOLS_PATH without upper-case
ifeq ($(__INO_TOOLS_PATH),)
  __INO_TOOLS_PATH = 
else
  ifneq ($(__INO_TOOLS_PATH),A)
    INO_TOOLS_PATH_ = $(filter INO_TOOLS_PATH%,$(GoalOptsValues))
    ifneq ($(INO_TOOLS_PATH_),)
      $(eval __$(INO_TOOLS_PATH_))
    endif
  endif
endif
# If necessary, re-assignment HDFILE without upper-case
HDFILE_ = $(filter HDFILE%,$(GoalOptsValues))
ifneq ($(HDFILE_),)
  $(eval __$(HDFILE_))
endif



# Extract Target mote
_MOTE = $(word 1,$(MAKECMDGOALS))
ifeq ($(_MOTE),)
  override MAKECMDGOALS := help
  _MOTE = $(word 1,$(MAKECMDGOALS))
endif

ifneq ($(_MOTE),help)
#===========================================================================
# Start for non help comand
#===========================================================================
# Validate mote
ifeq ($(filter $(_MOTE),$(ALL_TARGETS)),)
  $(error Target mote must be one of: $(ALL_TARGETS))
endif
# Identify mote family
MOTE_FAMILY = $($(_MOTE)_FAMILY)

# Avoiding override variables
ifneq ($(words $(MAKEOVERRIDES)),0)
    $(info *****)
    $(info ***** Error: Found $(words $(MAKEOVERRIDES)) invalid option(s) construction" => $(MAKEOVERRIDES))
    $(info *****        You must use ":" or "." to separate an OPTION of its VALUE.)
    $(error )
endif
INVALID_OPTIONS = $(filter-out $($(MOTE_FAMILY)_OPTIONS),$(GoalOpts))
ifneq ($(words $(INVALID_OPTIONS)),0)
  ifeq ($(words $(INVALID_OPTIONS)),1)
    $(info *****)
    $(info ***** Error: Found 1 invalid option for mote "$(_MOTE)" => $(INVALID_OPTIONS))
    $(info *****        Valid options are: $($(MOTE_FAMILY)_OPTIONS))
  else
    $(info *****)
    $(info ***** Error: Found $(words $(INVALID_OPTIONS)) invalid options for mote "$(_MOTE)" => $(INVALID_OPTIONS))
    $(info *****        Valid options are: $($(MOTE_FAMILY)_OPTIONS))
  endif
  $(error )
endif


REMAIN_OPTIONS = $(filter-out $(GoalOptsa),$(GOALSa))
$(info $(REMAIN_OPTIONS)--$(GoalOptsa)--$(GOALSa))
MALFORMED_OPTIONS = $(wordlist 2,100,$(REMAIN_OPTIONS))
ifeq ($(firstword $(REMAIN_OPTIONS)),MICAZ)
  ifeq ($(firstword $(MALFORMED_OPTIONS)),SIM-SF)
  	MALFORMED_OPTIONS := $(wordlist 2,100,$(MALFORMED_OPTIONS))
  endif
endif
# Remove allowed extra options as "mib520"
REMAIN_MFW = $(subst MIB,xxx, $(MALFORMED_OPTIONS))
MALFORMED_OPTIONS := $(filter $(MALFORMED_OPTIONS),$(REMAIN_MFW))
# Emit an error
ifneq ($(words $(MALFORMED_OPTIONS)),0)
  $(info *****)
  $(info ***** Error: Malformed options => $(shell echo $(MALFORMED_OPTIONS) | tr A-Z a-z) )
  $(error )
endif

# Check simulator sim-sf mode
ifneq ($(filter sim-sf,$(MAKECMDGOALS)),)
	_TOSSIM=Y
else
	_TOSSIM=N
endif


#
# Check options
#
__VM ?= NET
ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  ifneq ($(__VM),NET)
   ifneq ($(__VM),GRP)
     ifneq ($(__VM),THIN)
	      $(error Mote "$(_MOTE)" supports only VM:NET or VM:GRP or VM:THIN)
     endif
   endif
  endif
else
  ifneq ($(__VM),NET)
      $(error Mote "$(_MOTE)" supports only VM:NET)
  endif
endif


ifneq ($(filter $(_MOTE),$(ESP_TARGETS)),)
	__WIFI_SSID ?= terra_iot
	__WIFI_PASSWD ?= projeto_iot
else
  ifneq ($(__WIFI_SSID),)
      $(error WIFI_SSID must be used only for: $(ESP_TARGETS))
  endif
  ifneq ($(WIFI_PASSWD),)
      $(error WIFI_PASSWD must be used only for: $(ESP_TARGETS))
  endif
  
endif

__QUEUE ?= SHORT
ifneq ($(__QUEUE),SHORT)
  ifneq ($(__QUEUE),LONG)
    $(error QUEUE must be "SHORT" or "LONG")
  endif
endif

__VERB ?= N
ifneq ($(__VERB),Y)
  ifneq ($(__VERB),N)
    $(error VERB must be "Y" or "N")
  endif
endif

__SETDATA ?= N
ifneq ($(__SETDATA),Y)
  ifneq ($(__SETDATA),N)
    $(error SETDATA must be "Y" or "N")
  endif
endif

__TYPE ?= NOBS
ifneq ($(__TYPE),BOTH)
  ifneq ($(__TYPE),NOBS)
    ifneq ($(__TYPE),BOTH2)
      $(error TYPE must be "BOTH" or "NOBS")
    endif
  endif
endif
ifneq ($(findstring sim,$(MAKECMDGOALS)),)
  ifneq ($(__TYPE),BOTH)
    $(error 'If target is the micaz simulator, then TYPE must be BOTH')
  endif
endif
ifneq ($(findstring rpi,$(MAKECMDGOALS)),)
  __TYPE=NOBS
endif

__DEBUG ?= N
ifneq ($(__DEBUG),Y)
  ifneq ($(__DEBUG),N)
    $(error DEBUG must be "Y" or "N")
  endif
endif

__MOTE_TYPE ?= 1
ifeq ($(shell echo "$(__MOTE_TYPE)<1 || $(__MOTE_TYPE)>254" | bc), 1)
    $(error 'MOTE_TYPE must be 1..254')
endif
CFLAGS += -DMOTE_TYPE=$(__MOTE_TYPE)

__INSTALL ?= 1
ifeq ($(shell echo "$(__INSTALL)<1 || $(__INSTALL)>2047" | bc), 1)
    $(error 'in [install.xx] , xx must be in 1..2047')
endif

ifneq ($(filter $(_MOTE),$(INO_TARGETS)),)
  __INO_RADIO ?= NO_RADIO
  ifneq ($(__INO_RADIO),XBEE0)
    ifneq ($(__INO_RADIO),XBEE1)
  	  ifneq ($(__INO_RADIO),NRF24)
        ifneq ($(__INO_RADIO),NO_RADIO)
          $(error INO_RADIO must be "XBEE0", "XBEE1", "NRF24", or "NO_RADIO")
        endif
      endif
    endif
  endif
else
  ifneq ($(__INO_RADIO),)
    $(error INO_RADIO must be set only for motes: $(INO_TARGETS))
  endif
endif

__INO_HALF_CLOCK ?= N
ifneq ($(__INO_HALF_CLOCK),Y)
  ifneq ($(__INO_HALF_CLOCK),N)
    $(error INO_HALF_CLOCK must be "Y" or "N")
  endif
endif

__LPL ?= N
ifneq ($(__LPL),Y)
  ifneq ($(__LPL),N)
    $(error LPL must be "Y" or "N")
  endif
endif

__IFLASH ?= Y
ifneq ($(__IFLASH),Y)
  ifneq ($(__IFLASH),N)
    $(error IFLASH must be "Y" or "N")
  endif
endif


# Default radio power
__RFPOWER ?= 7
ifeq ($(findstring $(__RFPOWER), 0 1 2 3 4 5 6 7 ),)
    $(error 'RFPOWER must have 1 digit value: 0 1 2 3 4 5 6 7')
endif

# Verbose mode
ifeq ($(__VERB),Y)
	CFLAGS += -v
endif

# dbg() mode in linux
ifeq ($(__DEBUG),N)
	CFLAGS += -DNO_DEBUG
endif

# Analog ref IDs
AN_DEFAULT = 0
AN_INTERNAL1V1 = 1
AN_INTERNAL2V56 = 2
AN_EXTERNAL = 3

# ANA0_REF
ifneq ($(filter $(_MOTE),$(INO_TARGETS)),)
  __ANA0_REF ?= INTERNAL1V1
  ifneq ($(__ANA0_REF),DEFAULT)
    ifneq ($(__ANA0_REF),INTERNAL1V1)
  	  ifneq ($(__ANA0_REF),INTERNAL2V56)
        ifneq ($(__ANA0_REF),EXTERNAL)
          $(error ANA0_REF must be "DEFAULT", "INTERNAL1V1", "INTERNAL2V56", or "EXTERNAL")
        endif
      endif
    endif
  endif
else
  ifneq ($(__ANA0_REF),)
    $(error ANA0_REF must be set only for motes: $(INO_TARGETS))
  endif
endif

# ANA1_REF
ifneq ($(filter $(_MOTE),$(INO_TARGETS)),)
  __ANA1_REF ?= INTERNAL1V1
  ifneq ($(__ANA1_REF),DEFAULT)
    ifneq ($(__ANA1_REF),INTERNAL1V1)
  	  ifneq ($(__ANA1_REF),INTERNAL2V56)
        ifneq ($(__ANA1_REF),EXTERNAL)
          $(error ANA1_REF must be "DEFAULT", "INTERNAL1V1", "INTERNAL2V56", or "EXTERNAL")
        endif
      endif
    endif
  endif
else
  ifneq ($(__ANA1_REF),)
    $(error ANA1_REF must be set only for motes: $(INO_TARGETS))
  endif
endif

# ANA2_REF
ifneq ($(filter $(_MOTE),$(INO_TARGETS)),)
  __ANA2_REF ?= INTERNAL1V1
  ifneq ($(__ANA2_REF),DEFAULT)
    ifneq ($(__ANA2_REF),INTERNAL1V1)
  	  ifneq ($(__ANA2_REF),INTERNAL2V56)
        ifneq ($(__ANA2_REF),EXTERNAL)
          $(error ANA2_REF must be "DEFAULT", "INTERNAL1V1", "INTERNAL2V56", or "EXTERNAL")
        endif
      endif
    endif
  endif
else
  ifneq ($(__ANA2_REF),)
    $(error ANA2_REF must be set only for motes: $(INO_TARGETS))
  endif
endif

# ANA3_REF
ifneq ($(filter $(_MOTE),$(INO_TARGETS)),)
  __ANA3_REF ?= INTERNAL1V1
  ifneq ($(__ANA3_REF),DEFAULT)
    ifneq ($(__ANA3_REF),INTERNAL1V1)
  	  ifneq ($(__ANA3_REF),INTERNAL2V56)
        ifneq ($(__ANA3_REF),EXTERNAL)
          $(error ANA3_REF must be "DEFAULT", "INTERNAL1V1", "INTERNAL2V56", or "EXTERNAL")
        endif
      endif
    endif
  endif
else
  ifneq ($(__ANA3_REF),)
    $(error ANA3_REF must be set only for motes: $(INO_TARGETS))
  endif
endif

# INO_TOOLS_PATH can't be Y, y, N or n
ifneq ($(findstring $(__INO_TOOLS_PATH), Y y N n ),)
  $(info Do not use Y or N for INO_TOOLS_PATH option.)
  $(info This must be empty, set with A, or set with the Arduino tools path)
  $(error )
endif


#----------------------------------------------------------------

# LPL config
ifeq ($(__LPL),Y)
    ifeq ($(_TOSSIM) , Y)
      $(error TOSSIM do not implement LPL mode!)
    endif
	CFLAGS += -DLPL_ON
	# 90 ms radio OFF
	__SLEEP ?= 450
	# 700=10ms radio ON
	__XCCA ?= 700
	CFLAGS += -DLOW_POWER_LISTENING
	CFLAGS += -DSLEEP=$(__SLEEP) -DMAX_LPL_CCA_CHECKS=$(__XCCA)
	CFLAGS += -DLPL_DEF_LOCAL_WAKEUP=$(__SLEEP)
	CFLAGS += -DLPL_DEF_REMOTE_WAKEUP=$(__SLEEP)
	CFLAGS += -DDELAY_AFTER_RECEIVE=20
endif


#
# define root APP dir
#
APPDIR = $(shell pwd)


#
# Define VM path
#
ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  ifeq ($(__VM),NET)
	COMMONDIR = $(APPDIR)/platforms/TinyOS/common
	VMDIR = $(APPDIR)/platforms/TinyOS/Net
	CFLAGS += -I. 
	ifeq ($(_TOSSIM) , Y)
		CFLAGS += -I/opt/tinyos-2.1.2/tos/lib/tossim/sf/sim/ -I/opt/tinyos-2.1.2/tos/platforms/micaz/
	endif
	CFLAGS +=  -I$(COMMONDIR) -I$(VMDIR) 
  endif
  ifeq ($(__VM),GRP)
  	COMMONDIR = $(APPDIR)/platforms/TinyOS/common
	VMDIR = $(APPDIR)/platforms/TinyOS/Grp
	CFLAGS += -I. 
	ifeq ($(_TOSSIM) , Y)
		CFLAGS += -I/opt/tinyos-2.1.2/tos/lib/tossim/sf/sim/ -I/opt/tinyos-2.1.2/tos/platforms/micaz/
	endif
	CFLAGS +=  -I$(COMMONDIR) -I$(VMDIR) 
	PFLAGS += -DMODULE_CTP
	CFLAGS += -I$(TOSDIR)/lib/net/ -I$(TOSDIR)/lib/net/4bitle -I$(TOSDIR)/lib/net/ctp 
  endif
  ifeq ($(__VM),THIN)
	COMMONDIR = $(APPDIR)/platforms/TinyOS/common
	VMDIR = $(APPDIR)/platforms/TinyOS/Thin
	CFLAGS += -I. 
	CFLAGS += -D__FLASH_HARDCODED__ 
    CFLAGS +=  -I$(COMMONDIR) -I$(VMDIR) 
    CFLAGS += -DVM_THIN
    CFLAGS += $(VMDIR)/rsa64.o $(VMDIR)/sense64.o
    __HARDCODED_FILE__ = $(__HDFILE)
    
    STAT =  $(shell cp $(__HARDCODED_FILE__) $(VMDIR)/_HardcodedTempFile.h; echo $$?)
    ifeq ($(STAT),1)
      $(error ) 
    endif   
    STAT = $(shell msp430-gcc -c -mcpu=430 -Os -mmcu=msp430f1611 -Wall -Wshadow -fno-strict-aliasing -o$(VMDIR)/rsa64.o $(VMDIR)/rsa64lib.c; echo $$?)
    ifeq ($(STAT),1)
      $(error ) 
    endif   
    STAT = $(shell msp430-gcc -c -mcpu=430 -Os -mmcu=msp430f1611 -Wall -Wshadow -fno-strict-aliasing -o$(VMDIR)/sense64.o $(VMDIR)/sense64lib.c; echo $$?)
    ifeq ($(STAT),1)
      $(error ) 
    endif   
  endif
endif

ifeq ($(_MOTE),uno)
	VMDIR = $(APPDIR)/platforms/inoUno
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(__INO_RADIO) -DUNO
endif
ifeq ($(_MOTE),mega)
	VMDIR = $(APPDIR)/platforms/inoMega
	CFLAGS += -I. -I$(VMDIR) 
	CFLAGS += -D$(__INO_RADIO) -DMEGA
endif
ifeq ($(_MOTE),rpi)
	VMDIR = $(APPDIR)/platforms/RPi
	CFLAGS += -I. -I$(VMDIR) -DLINUX
endif
ifeq ($(_MOTE),esp)
	VMDIR = $(APPDIR)/platforms/esp
	CFLAGS += -I. -I$(VMDIR) -DESP
endif
ifeq ($(_MOTE),droid)
	VMDIR = $(APPDIR)/platforms/droid
	CFLAGS += -I. -I$(VMDIR) -I/home/mauricio/Android/Sdk/ndk-bundle/sources/android/native_app_glue/ -DLINUX -DANDROID
endif

# default 0:cc1000, 1:cc2420, 2:wifi-udp, 3:nrf24, 4:xbee, 5:NoRadio
NETID_mica2 = 0
NETID_mica2dot = 0
NETID_micaz = 1
NETID_telosb = 1
NETID_iris = 1
NETID_esp = 2
NETID_rpi = 2
NETID_droid = 2
NETID_megaNRF24 = 3
NETID_megaXBEE0 = 4
NETID_megaXBEE1 = 4
NETID_megaNO_RADIO = 5
NETID_unoNRF24 = 3
NETID_unoXBEE0 = 4
NETID_unoXBEE1 = 4
NETID_unoNO_RADIO = 5

NETNAME_0 = cc1000
NETNAME_1 = cc2420
NETNAME_2 = wifi-udp
NETNAME_3 = nrf24
NETNAME_4 = xbee
NETNAME_5 = NoRadio

ifeq ($(__NET_ID),)
  __NET_ID = $(NETID_$(_MOTE)$(__INO_RADIO))
  _NET_NAME = $(NETNAME_$(__NET_ID))
else
  ifeq ($(shell echo "$(__NET_ID)<0 || $(__NET_ID)>30" | bc), 1)
    $(error 'in NET_ID:xx , xx must be in 0..30')
  endif
  _NET_NAME = (?)
endif


_MOTE_ADDR = $(shell echo $(__NET_ID)*2048 + $(__INSTALL) | bc)
CFLAGS += -DNET_ID=$(__NET_ID)
CFLAGS += -DTERRA_NODE_ID=$(_MOTE_ADDR)

# Redefine "install.xx" for TOS nodes
ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  ifneq ($(findstring install,$(MAKECMDGOALS)),)
    MAKECMDGOALS += install.$(_MOTE_ADDR)  
  endif
endif


# Defaul values for serial baudrate
BAUD_mica2 = 57600
BAUD_micaz = 57600
BAUD_mica2dot = 19200
BAUD_telosb = 115200
BAUD_iris = 57600
BAUD_rpi = 57600
BAUD_droid = 57600
BAUD_esp = 57600
BAUD_mega = 115200
BAUD_uno = 57600
ALL_BAUDS = 19200 57600 115200

__BS_BAUD ?= $(BAUD_$(_MOTE))
ifneq ($(filter $(__BS_BAUD),$(ALL_BAUDS)),)
  ifneq ($(_MOTE),mica2dot) # Do not change for mica2dot. Original mica2dot baudrate is 19200.
    CFLAGS+= -DPLATFORM_BAUDRATE=$(__BS_BAUD)ul
  endif
else
    $(error BS_BAUD must be: $(ALL_BAUDS))
endif

# Devices Internal Flash max size
INTFLASH_mica2 = 4096
INTFLASH_micaz = 4096
INTFLASH_mica2dot = 4096
INTFLASH_telosb = 126
INTFLASH_iris = 4096
INTFLASH_rpi = 4096
INTFLASH_droid = 4096
INTFLASH_esp = 4096
INTFLASH_mega = 4096
INTFLASH_uno = 1024
__INTFLASH ?= $(INTFLASH_$(_MOTE))
CFLAGS += -DINTFLASH_SIZE=$(__INTFLASH)


CFLAGS += -I$(APPDIR)/interfaces
CFLAGS += -I$(APPDIR)/system
CFLAGS += -I$(APPDIR)/lib/serial

# build TinyOS Version ID number (211 ... 212)
ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  TOSVERSION = $(subst .,,$(subst /opt/tinyos-,,$(TOSROOT)))
else
  TOSVERSION = 0.0.0
endif

#
# Define generic configuration flags
#
ifeq ($(_MOTE),mica2)
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  PFLAGS += -DRFPOWER_IDX=$(__RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(_MOTE),mica2dot)
  PFLAGS += -DCC1K_DEF_FREQ=916400000
  PFLAGS += -DRFPOWER_IDX=$(__RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(_MOTE),micaz)
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${__RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(__RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(_MOTE),iris)
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${__RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(__RFPOWER)
  CFLAGS += -O2
endif
ifeq ($(_MOTE),telosb)
  # cc2420 - Ref.: http://www.ti.com/lit/ds/symlink/cc2420.pdf ; pag-51, table:9
  CC2420_RFPOWER = $(shell echo ${__RFPOWER}*4+3 | bc)
  PFLAGS += -DCC2420_DEF_RFPOWER=$(CC2420_RFPOWER) -DRFPOWER_IDX=$(__RFPOWER)
  CFLAGS += -Os 
endif

ifeq ($(_MOTE),uno)
  CFLAGS += -O1
  # INO_HALF_CLOCK config
  ifeq ($(__INO_HALF_CLOCK),Y)
    CFLAGS += -DINO_HALF_CLOCK 
  endif
endif
ifeq ($(_MOTE),mega)
  CFLAGS += -O1
  CFLAGS += -DRFPOWER_IDX=$(__RFPOWER)
  CFLAGS += -DANA0_REF=$(AN_$(__ANA0_REF)) -DANA1_REF=$(AN_$(__ANA1_REF)) -DANA2_REF=$(AN_$(__ANA2_REF)) -DANA3_REF=$(AN_$(__ANA3_REF))
endif
ifeq ($(_MOTE),rpi)
  CFLAGS += -Os
endif
ifeq ($(_MOTE),esp)
  CFLAGS += -Os
  CFLAGS += -DWIFI_SSID=\"$(__WIFI_SSID)\" -DWIFI_PASSWORD=\"$(__WIFI_PASSWD)\"
endif


#
# Validate SENSOR and define SENSORBOARD
#
ifeq ($(_MOTE),mica2dot)
  ifneq ($(__SENSOR),)
    $(error Invalid SENSOR value "$(SENSOR)" for "mica2dot". Currently Mica2Dot supports only internal temperature sensor.)
  endif
endif
ifneq ($(filter $(_MOTE),micaz mica2 iris),)
  __SENSOR ?= MDA100
  _SENSORX = $(shell echo $(__SENSOR) | tr a-z A-Z)
  ifeq ($(_SENSORX) , MTS300CA)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CA -DSBOARD=300
  endif
  ifeq ($(_SENSORX) , MTS300CB)
    SENSORBOARD = mts300
    CFLAGS += -DMTS300CB -DSBOARD=300
  endif
  ifeq ($(_SENSORX) , MDA100)
    SENSORBOARD = mda100
    CFLAGS += -DMDA100
    CFLAGS += -I$(TOSDIR)/sensorboards/mda100/cb -DSBOARD=100
  endif
  ifeq ($(SENSORBOARD),)
    $(error Invalid SENSOR value "$(SENSOR)" for "$(MOTE)". Options are: MTS300CA, MTS300CB, MDA100)
  endif	
endif
# Force message for undefined sensor
__SENSOR = Not applicable


#
# define VM memory use
#

ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  override _INSTALL := $(_MOTE_ADDR)
  ifneq ($(filter $(_MOTE),micaz mica2 mica2dot),) # 4KB RAM
    ifeq ($(__VM),NET)
      MB_SHORT_ALL = 90
      MB_SHORT_NOBS = 100
      MB_LONG_ALL = 64
      MB_LONG_NOBS = 71
    endif
    ifeq ($(__VM),GRP)
      MB_SHORT_ALL =24
      MB_SHORT_NOBS = 32
      MB_LONG_ALL = 10
      MB_LONG_NOBS = 10
    endif
    ifeq ($(__VM),THIN)
      MB_SHORT_ALL = 100
      MB_SHORT_NOBS = 100
      MB_LONG_ALL = 100
      MB_LONG_NOBS = 100
    endif
    ifeq ($(__QUEUE) , SHORT)
      ifeq ($(__TYPE),BOTH)
        MBLOCKS = $(MB_SHORT_ALL)             # any;  ALL; SHORT
      else ifeq ($(__TYPE),BOTH2)
        MBLOCKS = $(MB_SHORT_ALL)             # any;  ALL; SHORT
      else
        MBLOCKS = $(MB_SHORT_NOBS)             # any; NOBS; SHORT
      endif
    else # QUEUE = LONG
      ifeq ($(__TYPE),BOTH)
        MBLOCKS = $(MB_LONG_ALL)             # any;  All; LONG
      else ifeq ($(__TYPE),BOTH2)
        MBLOCKS = $(MB_LONG_ALL)             # any;  All; LONG
      else
        MBLOCKS = $(MB_LONG_NOBS)             # any; NOBS; LONG
      endif
    endif
  else ifneq ($(filter $(_MOTE),iris telosb),) # 8KB RAM
        MBLOCKS = 200
  endif
else ifneq ($(filter $(_MOTE),uno),) # 2KB RAM
        MBLOCKS = 14
else ifneq ($(filter $(_MOTE),mega),) # 8KB RAM
        MBLOCKS = 220
else ifneq ($(filter $(_MOTE),rpi),) # xxxKB RAM
        MBLOCKS = 220  
else ifneq ($(filter $(_MOTE),droid),) # xxxKB RAM
        MBLOCKS = 220
else ifneq ($(filter $(_MOTE),esp),) # xxxKB RAM
        MBLOCKS = 100  
endif

# Greatest value for MBLOCKS considering all platforms
GENERAL_MAX__BLKS = 220

# Define MemBlocks Size for each additional module/operations
M_SETDATA = 16
M_MSGQ = 8
M_STAT = 0
M_INTFLASH = 0
M_BSTATION = 5

#
# Configure BS and QUEUE defines
ifeq ($(__TYPE),BOTH)
  CFLAGS += -DWITH_BSTATION
else ifeq ($(__TYPE),BOTH2)
  CFLAGS += -DWITH_BSTATION -DWITH_AUX_BSTATION
else
  CFLAGS += -DNO_BSTATION
endif

ifeq ($(__QUEUE) , SHORT)
    CFLAGS += -DSHORT_QUEUES
endif

# Validate MOD values
INVALID_MODS = $(filter-out $(MOD_VALUES),$(__MOD))
ifneq ($(words $(INVALID_MODS)),0)
  $(info ***** Error: Invalid module code => $(INVALID_MODS))
  $(info *****      Valid values are: $(MOD_VALUES))
  $(error )
endif

# Reset MODULES if VM!=NET
ifeq ($(__VM) , GRP)
	MODULES = 'Not applicable'
    $(info ***** Warning: Disabling all MODs for VM:GRP <<==) 
else
	MODULES = $(__MOD)
endif
# Used memory by additional modules
ifneq ($(findstring MSGQ,$(MODULES)),)
    CFLAGS += -DM_MSG_QUEUE
    DM_MSGQ = $(M_MSGQ)
else
    DM_MSGQ = 0
endif
ifneq ($(findstring STAT,$(MODULES)),)
    CFLAGS += -DM_STAT
    DM_STAT = $(M_STAT)
else
    DM_MSGQ = 0
endif
ifeq ($(__SETDATA) , Y)
    CFLAGS += -DMODE_SETDATA
    DM_SETDATA = $(M_SETDATA)
else
    DM_SETDATA = 0
endif

ifeq ($(__IFLASH) , Y)
    CFLAGS += -DMODE_INTFLASH
    DM_INTFLASH = $(M_INTFLASH)
else
    DM_INTFLASH = 0
endif

ifeq ($(__TYPE) , BOTH)
    DM_BSTATION = $(M_BSTATION)
else
    DM_BSTATION = 0
endif


# Calculate final MemBlocks
BLOCK_SIZE = 22
MBLOCKS_F = $(shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA}-${DM_INTFLASH}-${DM_BSTATION} | bc)
# force short memory - test with printf
# MBLOCKS=40
CFLAGS += -DVM_MEM_BLKS=$(MBLOCKS_F)
ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  CFLAGS += -DTOSVER=$(TOSVERSION)
endif
#$(info shell echo ${MBLOCKS}-${DM_MSGQ}-${DM_SETDATA}-${DM_INTFLASH}-${DM_BSTATION})


$(info ***********************)
$(info **** Configuration ****)
$(info MOTE        = $(_MOTE))
$(info TOSSIM      = $(_TOSSIM))
$(info DEBUG       = $(__DEBUG))
$(info VM          = $(__VM))
$(info MODULES     = $(MODULES) -- [MSGQ])
$(info IFLASH      = $(__IFLASH))
$(info NET_ID      = $(__NET_ID) ($(_NET_NAME)))
$(info MOTE_ID     = $(__INSTALL))
$(info MOTE_ADDR   = $(_MOTE_ADDR) ($(__NET_ID):$(__INSTALL)))
$(info MOTE_TYPE   = $(__MOTE_TYPE))
$(info RFPOWER     = $(__RFPOWER))
$(info LPL         = $(__LPL))
$(info SENSORBOARD = $(__SENSOR))
ifeq ($(__TYPE) , BOTH)
    $(info TYPE        = $(__TYPE) : SerialBaudrate=$(__BS_BAUD))
else
    $(info TYPE        = $(__TYPE))
endif
$(info SETDATA     = $(__SETDATA))
$(info QUEUE       = $(__QUEUE))
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

ifneq ($(filter $(_MOTE),$(TOS_TARGETS)),)
  include $(MAKERULES)
else ifneq ($(filter $(_MOTE),$(INO_TARGETS)),)
  include Makefile_ino
else ifneq ($(filter $(_MOTE),$(IX_TARGETS)),)
  include Makefile_ix
else ifneq ($(filter $(_MOTE),$(ESP_TARGETS)),)
  include Makefile_esp
else ifneq ($(filter $(_MOTE),$(DROID_TARGETS)),)
  include Makefile_droid
endif
############################################
# End for non help comand
############################################
else
  _MOTE = $(word 2,$(MAKECMDGOALS))

#$(error |$(MAKECMDGOALS) -- $(_MOTE)|)

# Validate mote
ifneq ($(_MOTE),)
  ifeq ($(filter $(_MOTE),$(ALL_TARGETS) options),)
    $(error Target mote must be one of: $(ALL_TARGETS))
  endif
endif

include Makefile_help

endif
