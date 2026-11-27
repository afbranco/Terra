---
layout: terra
title: Getting started
---

# Getting started

This page goes from nothing to a program running on a simulated network, and then on micaz
motes. It needs a Linux PC (x86_64, glibc 2.29 or newer; tested on Ubuntu 20.04 to 24.04, Linux Mint 22,
Debian 11 to 13, Fedora 41 and 43, openSUSE Leap 15.6 and Tumbleweed, Arch, Rocky and AlmaLinux 9). Nothing is installed on
the machine and no administrator rights are needed: everything stays in one folder, apart from the
Python, Lua or compilers the machine may have. Only the USB access to the motes may need the
administrator, once (step 5).

## 1. Install

Download from the [latest release](https://github.com/afbranco/Terra/releases/latest) one of:

- **With VS Code**: `terra-vscode-<v>-linux-x64.vsix`. In VS Code, open the Extensions view, click
  `...` and *Install from VSIX...* (or run `code --install-extension terra-vscode-<v>-linux-x64.vsix`).
  The extension brings everything inside (compiler, simulators, firmware and its own Python) and
  unpacks it on the first use, in a few seconds. Use the VS Code of the `.deb`, `.rpm` or `.tar.gz`
  packages: the Flatpak and Snap versions run isolated and may not reach the USB port.
- **Without VS Code**: `terra-<v>-linux-x86_64.tar.gz`. Extract it in any folder and add its
  `bin/` to the `PATH` (or call `bin/terrac` and `bin/terractl` by the path):

  ```bash
  tar xzf terra-<v>-linux-x86_64.tar.gz
  export PATH="$PWD/terra-<v>-linux-x86_64/bin:$PATH"
  terrac --help
  ```

Two versions can live side by side (two folders, or *Install Specific Version* of the extension).
To uninstall, remove the extension or delete the folder.

## 2. A first program

Each node counts every 5 seconds and shows the count on its 3 LEDs. Node 11 also reads its
temperature sensor and sends the count and the reading to the base station (node 1), the one
connected to the computer:

<!-- check: ok -->
```terra
#include "TerraNet.defs"

pktype reading from radioMsg with
  var ubyte  count;
  var ushort temp;
end

var reading msg;
var ubyte count = 0;
loop do
  await 5s;
  count = count + 1;
  emit LEDS(count);               // the 3 LEDs show the count, in binary
  if getNodeId() == 11 then       // node 11 is the neighbor of the base station
    msg.type = 1;
    msg.source = getNodeId();
    msg.target = 1;               // node 1: the base station
    msg.count = count;
    emit REQ_TEMP();
    msg.temp = await TEMP;
    emit SEND(msg);
    await SEND_DONE(1);
  end
end
```

`#include "TerraNet.defs"` chooses the VM: TerraNet, with radio messages to the nodes in range
([TerraNet](terranet.html)), or TerraGrp, with groups and aggregation ([TerraGrp](terragrp.html)).
The `pktype` declares the fields of the message after the header of `radioMsg` (`type`, `source`,
`target`). [The Terra language](language.html) explains the rest.

Save it as `hello.terra`.

## 3. Compile

In VS Code, saving compiles: the errors and warnings go to the *Problems* panel and are
underlined in the program, each with a link to its [code](terrac-codes.html) (*Terra: Compile*, or
Ctrl+Shift+B, compiles too). On the hover, the extension shows the documentation of each event,
function and constant of the VM.

In the terminal:

```bash
terrac hello.terra        # writes hello.vmx, the bytecode for the VM
```

The compiler also prints how much memory the program takes on the node.

## 4. Simulate

In VS Code, run *Terra: Simulate* (Command Palette, Ctrl+Shift+P): a terminal opens with the
simulation. In the terminal:

```bash
terractl sim hello.vmx --terra hello.terra --grid 2x2 --time 22
```

```
    0.000  grid 2x2 (4 motes and the BS), net, 22 s simulated
    1.019  terractl: version 1, 4 blocks (2 to 5)
    2.392  <<: vmstart 11 0 0 :>>
    2.436  <<: vmstart 22 0 0 :>>
    ...
    7.274  <<: leds 11 3 1 :>>
    7.404  BS: node 11  reading  type=1 source=11 target=1 count=1 temp=500
   12.201  <<: leds 11 3 2 :>>
   12.338  BS: node 11  reading  type=1 source=11 target=1 count=2 temp=500
```

Each line starts with the simulated time, in seconds. The program is loaded as on the real
network: the base station receives it (`version 1, 4 blocks`) and the nodes pass it on by radio;
`vmstart` is a node starting the program, `leds` its LEDs (node, mask of LEDs, value) and `BS:` a
message that reached the base station, shown field by field by the `pktype` of the program.

The nodes are column×10 + line (11, 12, 21, 22 in a 2x2 grid), up to 9x9; each one hears its 8
neighbors, and the base station hears node 11. A program with `#include "TerraGrp.defs"` runs on
the TerraGrp simulator (in VS Code, by itself; in the terminal, with `--vm grp`). The grid and the
time are in the settings of the extension (`terra.simulation.grid`, `terra.simulation.time`); other
options of `terractl sim` (the seed, nodes that boot later, the log of the VM) are in
[TinyOS platform](tinyos.html#simulating-with-tossim).

For a visual simulation, for teaching, there is [TerraSim](https://terrasim.inf.puc-rio.br) (access
by invitation).

## 5. Run on micaz motes

You need micaz motes with sensor boards (MDA100) and a MIB520 programmer, connected by USB. The
MIB520 opens two ports: the first (`/dev/ttyUSB0`) flashes the firmware, the second
(`/dev/ttyUSB1`) carries the data of the base station.

**USB access.** The user needs read and write access to these ports: on most distributions, being
in the `dialout` group (`sudo usermod -aG dialout <user>`, then log in again). This is the only
step that needs the administrator. Flashing also needs `avrdude` (package `avrdude`).

**Flash the firmware.** Each mote gets the Terra VM once, with its node id. The base station is
node 1 (`net-bs`); the others get `net-nobs` (`grp-bs` and `grp-nobs` for TerraGrp), with ids like
11, 12, 21... Put the mote on the MIB520 and, in VS Code, run *Terra: Flash a micaz* (it asks the
firmware, the id and the port), or:

```bash
terractl flash net-bs --node 1 --port /dev/ttyUSB0
terractl flash net-nobs --node 11 --port /dev/ttyUSB0      # then the next mote, with another id
```

**Compile for the micaz.** The motes have more than the simulator (ports, microphone...). For a
program that uses them, compile it with the `.defs` of the firmware: copy
`defs/terra-<v>-net-micaz-nobs.defs` of the package to the folder of the program, with the name
`TerraNet.defs` (the `.defs` in the folder of the program comes first). `hello.terra` runs on both.

**Load the program.** With the base station on the MIB520 and the other motes on, run *Terra: Load
program on the network* in VS Code, or:

```bash
terractl load hello.vmx --serial /dev/ttyUSB1 --listen --terra hello.terra
```

The motes receive the program by radio, start it, and the messages to the base station show up
as in the simulation. Loading a new version replaces the running one. *Terra: Show messages of the
base station* (`terractl listen`) only shows the messages.

## Next steps

- [The Terra language](language.html), [TerraNet](terranet.html) and [TerraGrp](terragrp.html).
- [terrac](terrac.html) and its [error codes](terrac-codes.html).
- [TinyOS platform](tinyos.html): the release assets one by one, more options of the simulator,
  building the firmware from the source.
- [Customization](customization.html): a VM with other events and functions.
