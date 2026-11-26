---
layout: terra
title: TinyOS platform
---

# The TinyOS platform

The Terra VM for TinyOS 2.1.2 runs on the micaz and in the TOSSIM simulator. The releases have
the firmware and the simulator ready; this page shows how to install them, how to build them
from the source, and how to send programs to the nodes.

The firmware builds also for mica2, iris and telosb (these were used until 2016). The releases
build and test only the micaz: in the TOSSIM simulator and in the Avrora emulator.

## Release assets

| Asset | What it is |
|---|---|
| `terra-<v>-{net,grp}-micaz-nobs.{exe,ihex}` | micaz firmware for a common node (MDA100 sensor board) |
| `terra-<v>-{net,grp}-micaz-nobs.defs` | the `.defs` of that firmware: compile the programs for the micaz with it |
| `terra-<v>-{net,grp}-micaz-bs.{exe,ihex}` | micaz firmware for the base station (node 1, connected to the computer) |
| `terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz` | TOSSIM simulator module (`_TOSSIM.so`, `TOSSIM.py`, Python 3) and its `.defs` |
| `terrac-<v>.tar.gz` | the [compiler](terrac.html), with the `.defs` of the simulator |
| `TerraVMControl-<v>.jar` | TerraControl, the tool that sends programs to the network |

## Installing the firmware on a micaz

The `.ihex` files have node id 1. For another id, set it in the `.exe` with the tools of the
[tinyos-toolchain](https://github.com/afbranco/tinyos-toolchain) image. Node 2 on a MIB520
programmer at `/dev/ttyUSB0`:

```bash
podman run --rm -it --device /dev/ttyUSB0 -v "$PWD:/w:Z" -w /w \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-21d8fb1 sh -c '
    tos-set-symbols --objcopy avr-objcopy --objdump avr-objdump --target ihex \
      terra-<v>-net-micaz-nobs.exe node2.ihex TOS_NODE_ID=2 ActiveMessageAddressC__addr=2 &&
    avrdude -cmib510 -P/dev/ttyUSB0 -pm128 -U hfuse:w:0xd9:m -U efuse:w:0xff:m \
      -C/etc/avrdude.conf -U flash:w:node2.ihex:a'
```

`docker` works in place of `podman`. The base station is node 1: install
`terra-<v>-net-micaz-bs.ihex` as it is. Use the same VM (Net or Grp) on all the nodes.

## Sending a program to the network

The base station is connected to the computer. Two programs run on the computer:

1. the TinyOS **SerialForwarder**, on the data port of the programmer (the MIB520 opens two
   ports: the first flashes the firmware, the second carries the data):

   ```bash
   java net.tinyos.sf.SerialForwarder -comm serial@/dev/ttyUSB1:micaz
   ```

2. **TerraControl** (`java -jar TerraVMControl-<v>.jar`), which connects to the SerialForwarder
   (port 9002), loads the `.vmx` made by `terrac` and sends it to the network.

The nodes pass the program on to each other by radio: every node, including the ones out of
range of the base station, receives it and starts it. A new version of the program replaces the
running one.

## Simulating with TOSSIM

The `_TOSSIM.so` of the release is a TOSSIM module for Python 3 (x86_64), with the Terra VM of
every node. A Python script creates the network, boots the nodes and runs the simulation:

```python
import sys
sys.path.insert(0, "terra-<v>-net-tossim-py3-x86_64")
from TOSSIM import SerialForwarder, Tossim

t = Tossim([])
sf = SerialForwarder(9002)             # for TerraControl, as with the real base station
r = t.radio()
for a, b in ((1, 2), (2, 1)):          # two nodes that hear each other
    r.add(a, b, -60.0)
for n in (1, 2):
    m = t.getNode(n)
    for _ in range(100):
        m.addNoiseTraceReading(-98)
    m.createNoiseModel()
    m.bootAtTime(n * 1000)
while t.time() < 600 * t.ticksPerSecond():
    t.runNextEvent()
    sf.process()
```

Node 1 is the base station. Start TerraControl and send the program, as in the real network.
Run the script in a folder where it can write: the VM creates a `sensors.bin` file there. The
simulation runs as fast as the computer can; a real-time pace (`Throttle` in the module) and a
view of the nodes are up to the script.

[TerraSim](https://github.com/afbranco/TerraSim) is a web simulator for teaching, built on these
modules, with an editor, a view of the network and the deploy of the programs.

## Building from the source

The [tinyos-toolchain](https://github.com/afbranco/tinyos-toolchain) container image has
TinyOS 2.1.2, the AVR tools and TOSSIM (Python 3). Build inside it, in `TerraVM/src`:

```bash
git clone https://github.com/afbranco/Terra
cd Terra
podman run --rm -v "$PWD:/terra:Z" -w /terra/TerraVM/src \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-21d8fb1 \
  make micaz VM=NET MOD=MSGQ TYPE=NOBS
```

The firmware is `build/micaz/main.exe`, and the `.defs` for it is `build/micaz/TerraNet.defs`.
`make micaz sim-sf VM=NET MOD=MSGQ TYPE=ALL` builds the simulator module (`_TOSSIM.so`). The
release script `release/build-tinyos.sh` builds and tests all the assets.

Parameters of `make`, in the form `NAME=value` (see the header of `TerraVM/src/Makefile`):

| Parameter | Values | Default | Meaning |
|---|---|---|---|
| `VM` | `NET`, `GRP` | `NET` | the VM: [TerraNet](terranet.html) or [TerraGrp](terragrp.html) |
| `TYPE` | `NOBS`, `BS`, `ALL` | `ALL` | common node, base station, or both (the simulator needs `ALL`) |
| `MOD` | `MSGQ`, `FFT`, `VCN_DAT`, `VCN_DET` | none | extra modules; the releases build TerraNet with `MSGQ` (message queue) |
| `SENSOR` | `MDA100`, `MTS300CA`, `MTS300CB` | `MDA100` | sensor board; the MTS300 adds the microphone and the buzzer |
| `QUEUE` | `SHORT`, `LONG` | `SHORT` | sizes of the queues and of the program memory |
| `HYB` | `YES`, `NO` | `YES` | iris and telosb with the same memory as the micaz |
| `RFPOWER` | 0 to 7 | 4 | default radio power |
| `SETDATA` | `YES`, `NO` | `NO` | let TerraControl set data in the nodes |
| `LPL` | `YES`, `NO` | `NO` | low power listening |
| `VERB` | `YES`, `NO` | `NO` | verbose build |

`make micaz ... install.2 mib520,/dev/ttyUSB0` builds and installs with node id 2.

The `.defs` of a build is generated with it, from `TerraVM/src/defs/Terra{Net,Grp}.defs.in`: it
declares only what that firmware has (the ports exist only on mica motes, the microphone only
with the MTS300 board, the queue only with `MSGQ`), and the memory for programs of the build.
Compile the programs for a firmware with its `.defs`.
