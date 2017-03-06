

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


# Verbose mode
ifeq ($(VERB),YES)
	CFLAGS += -v
endif

DEBUG ?= YES
ifneq ($(DEBUG),YES)
  ifneq ($(DEBUG),NO)
    $(error DEBUG must be "YES" or "NO")
  endif
endif

ifeq ($(DEBUG),NO)
	CFLAGS += -DNO_DEBUG
endif
#
# define root APP dir and others
#
APPDIR = $(shell pwd)
TERRADIR = $(APPDIR)/../../TerraVM/src

ifeq ($(MOTE),rpi)
	VMDIR = $(TERRADIR)/platforms/RPi
	CFLAGS += -I. -I$(VMDIR) -DLINUX
else
	$(error Command must be 'make rpi')
endif

#INSTALL ?= $(shell ip route get 8.8.8.8 | awk '{print $$NF; exit}' | awk -F'.' '{print $$3*256+$$4; exit}')
ROOT_ID ?= 1
INSTALL ?=4096

#$(error $(INSTALL))

CFLAGS += -I$(TERRADIR)
CFLAGS += -I$(TERRADIR)/interfaces
CFLAGS += -I$(TERRADIR)/system
CFLAGS += -I$(TERRADIR)/lib/serial


# build TinyOS Version ID number (211 ... 212)
ifneq ($(filter $(MOTE),$(TOS_TARGETS)),)
  TOSVERSION = $(subst .,,$(subst /opt/tinyos-,,$(TOSROOT)))
else
  TOSVERSION = 0.0.0
endif

ifeq ($(MOTE),rpi)
  CFLAGS += -Os
endif

PFLAGS += -fno-strict-aliasing # required for accessing VARS

# Initial paths/files
BUILDDIR = build/$(MOTE)
MAIN_APPC = $(BUILDDIR)/app.c
MAIN_EXE = $(BUILDDIR)/main.exe
DUMP_FILE = $(BUILDDIR)/wiring-check.xml



# programs and config "path/names"
GCC = gcc

COMPONENT = TerraUdpUploadAppC

OPT1=-fnesc-include=tos -topdir=$(APPDIR)
OPT2=-fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask -o $(MAIN_EXE) -fnesc-separator=__ -Wall -Wshadow -Wnesc-all -fnesc-cfile=$(MAIN_APPC) --param max-inline-insns-single=100000 -fnesc-dump=wiring   -fnesc-dumpfile=$(DUMP_FILE) -lm -fnesc-no-debug 
OPT3 = $(CFLAGS)
OPT4=-DTERRA_NODE_ID=$(INSTALL)
OPT5=setTimer.o dbg.o 

rpi: builddir exe
	$(info **********  Makefile RPi: *************)

dbg.o: $(VMDIR)/dbg.c
	gcc -c $(VMDIR)/dbg.c -o dbg.o

setTimer.o: $(VMDIR)/setTimer.c
	gcc -c $(VMDIR)/setTimer.c -o setTimer.o

exe: dbg.o setTimer.o
	@echo "    compiling $(COMPONENT) to a $(PLATFORM) binary"
	nescc $(OPT1) $(OPT2) $(OPT3) $(OPT4) $(OPT5) -gcc=$(GCC) $(COMPONENT).nc
	@echo "    compiled $(COMPONENT) to $(MAIN_EXE)"

install.%: 
	@echo "    O Install ainda não está implementado."

install: 
	@echo "    O Install ainda não está implementado."


builddir: 
	@mkdir -p $(BUILDDIR)

