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

On Linux, start with **`terra-<v>-linux-x86_64.tar.gz`**: everything in one folder (compiler,
`terractl`, simulators, firmware, `.defs` and its own Python), with nothing to install and no
administrator needed. Extract it anywhere and use `bin/terrac` and `bin/terractl` (see the
`README.txt` inside); delete the folder to uninstall. The other assets are the same pieces, one by
one.

| Asset | What it is |
|---|---|
| `terra-<v>-linux-x86_64.tar.gz` | all of the below for Linux x86_64, ready to use, with Python 3.14 inside |
| `terrac-<v>-linux-x86_64` | the compiler as a single executable for Linux (Lua, LPeg and the preprocessor inside) |
| `terra-<v>-{net,grp}-micaz-nobs.{exe,ihex}` | micaz firmware for a common node (MDA100 sensor board) |
| `terra-<v>-{net,grp}-micaz-nobs.defs` | the `.defs` of that firmware: compile the programs for the micaz with it |
| `terra-<v>-{net,grp}-micaz-bs.{exe,ihex}` | micaz firmware for the base station (node 1, connected to the computer) |
| `terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz` | TOSSIM simulator module (`_TOSSIM.so`, `TOSSIM.py`, Python 3) and its `.defs` |
| `terrac-<v>.tar.gz` | the [compiler](terrac.html), with the `.defs` of the simulator |
| `terra-vscode-<v>-linux-x64.vsix` | extension for VS Code on Linux, with the package `terra-<v>-linux-x86_64` inside: nothing else to install |
| `terra-vscode-<v>.vsix` | extension for VS Code, other systems: highlighting, docs on hover, `terrac` errors, load, simulate and flash |
| `terractl-<v>.pyz` | `terractl` (Python 3): loads programs, shows the messages, flashes the micaz with an id, simulates a grid |
| `TerraVMControl-<v>.jar` | the Java TerraControl, replaced by `terractl` |

## Installing the firmware on a micaz

The `.ihex` files have node id 1. For another id, use `terractl` (asset `terractl-<v>.pyz`,
Python 3), which sets the id in the `.exe` and calls `avrdude`. Node 2 on a MIB520 programmer at
`/dev/ttyUSB0`:

```bash
python3 terractl-<v>.pyz flash terra-<v>-net-micaz-nobs.exe --node 2 --port /dev/ttyUSB0
```

The base station is node 1: install `terra-<v>-net-micaz-bs.ihex` as it is (or `flash` the
`-bs.exe` with `--node 1`). Use the same VM (Net or Grp) on all the nodes. `terractl flash ... -o
node2.ihex` only writes the file; the tools of the
[tinyos-toolchain](https://github.com/afbranco/tinyos-toolchain) image (`tos-set-symbols`) give the
same result.

## Sending a program to the network

The base station is connected to the computer. The MIB520 opens two ports: the first flashes the
firmware, the second carries the data. `terractl` loads the `.vmx` made by `terrac` through the data
port and shows the messages that reach the base station:

```bash
python3 terractl-<v>.pyz load prog.vmx --serial /dev/ttyUSB1 --listen --terra prog.terra
```

The `.pyz` brings `pyserial` inside: it runs with the `python3` of the machine, nothing to install. With `--terra` (or `--types`, the
output of `terrac --types`), the messages are shown field by field, by the `pktype` of the program:
the ones sent with `SEND` to node 1 (TerraNet) or with `SEND_BS` (TerraGrp). `--sf host:port`
connects to a SerialForwarder instead of the serial port. `terractl listen` only shows the messages.

The nodes pass the program on to each other by radio: every node, including the ones out of
range of the base station, receives it and starts it. A new version of the program replaces the
running one; `terractl` keeps the last version number in `~/.local/state/terractl/version`.

The Java TerraControl (`TerraVMControl-<v>.jar`, with the TinyOS SerialForwarder) still comes with
the release, but `terractl` replaces it.

## Simulating with TOSSIM

The `_TOSSIM.so` of the release is a TOSSIM module for Python 3.14 (x86_64), with the Terra VM of
every node. `terractl sim` builds a grid of nodes, loads the program through the base station, as in
the real network, and prints the log of the nodes (LEDs, VM start and errors, radio with `--hide
serial`) and the messages that reach the base station, with the simulated time. With the package
`terra-<v>-linux-x86_64` (or the Linux extension), which has the simulators and their Python
([Getting started](getting-started.html)):

```bash
terractl sim prog.vmx --terra prog.terra --grid 3x3 --time 60      # --vm grp for TerraGrp
```

```
    3.615  <<: vmstart 22 0 0 :>>
    4.672  <<: leds 11 3 1 :>>
    4.759  BS: node 11  reading  type=1 source=11 target=1 count=1 temp=500
```

With the assets one by one, `--tossim` gives the folder of the module, and the Python has to be
3.14: on another machine, run it in the image of the toolchain:

```bash
tar xzf terra-<v>-net-tossim-py3-x86_64.tar.gz
podman run --rm -v "$PWD:/w:Z" -w /w ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-0dded15 \
  python3 terractl-<v>.pyz sim prog.vmx --tossim terra-<v>-net-tossim-py3-x86_64 --types prog.json
```

The nodes are column×10 + line (11, 12, ... 21, 22, ...), up to 9×9; each one hears its
8 neighbors, and node 1, the base station, hears node 11. Some options:

| Option | What it does |
|---|---|
| `--time S` | simulated seconds (60) |
| `--seed N` | seed of the simulation: the same seed gives the same output |
| `--types prog.json` | shows the messages to the base station by the `pktype` of the program (`terrac --types prog.terra > prog.json`; `--terra prog.terra` runs `terrac` itself, when it is installed where `sim` runs) |
| `--late N --late-at S` | the last N columns boot at second S (30) |
| `--vmdbg file` | writes the `VMDBG` channel (every instruction of the VM) |
| `--channel NAME` | also shows a TOSSIM debug channel (`AM`, `Serial`...) |
| `--hide CMD,...` | log commands not shown (`serial,radio`; empty shows all) |
| `--realtime` | runs at the pace of the clock, for `terractl load --sf localhost:9002` from outside |

Run it in a folder where it can write: the VM creates a `sensors.bin` file there, and the channels
go to `.terractl-sim/`. The TerraGrp module works the same way. A script of your own can also use
the module (`from TOSSIM import Tossim, SerialForwarder`): see `terractl/sim.py`.

TerraSim is a web simulator for teaching, built on these modules, with an editor, a view of the
network and the deploy of the programs. It runs at
[terrasim.inf.puc-rio.br](https://terrasim.inf.puc-rio.br) (access by invitation); the source is
on [GitHub](https://github.com/afbranco/TerraSim).

## Building from the source

The [tinyos-toolchain](https://github.com/afbranco/tinyos-toolchain) container image has
TinyOS 2.1.2, the AVR tools and TOSSIM (Python 3). Build inside it, in `TerraVM/src`:

```bash
git clone https://github.com/afbranco/Terra
cd Terra
podman run --rm -v "$PWD:/terra:Z" -w /terra/TerraVM/src \
  ghcr.io/afbranco/tinyos-toolchain:2.1.2-resolute-py3-0dded15 \
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
