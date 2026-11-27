Terra @VER@ for Linux x86_64
==========================

Everything to write, compile, simulate, load and flash Terra programs, without installing
anything and without administrator rights. It works from any folder (even a USB stick) and does
not touch the Python, Lua or compilers of the machine. Two versions can live side by side.
To uninstall, delete the folder.

  bin/terrac   prog.terra                  compile (writes prog.vmx next to the source)
  bin/terractl sim prog.vmx --terra prog.terra
                                           simulate a 3x3 grid (TerraNet; --vm grp for TerraGrp)
  bin/terractl load prog.vmx --serial /dev/ttyUSB1
                                           load on the motes through the base station (MIB520)
  bin/terractl listen --serial /dev/ttyUSB1 --terra prog.terra
                                           show the messages that reach the base station
  bin/terractl flash net-bs --node 1 --port /dev/ttyUSB0
                                           flash the micaz firmware (net-bs, net-nobs, grp-bs,
                                           grp-nobs) with a node id; needs avrdude

Add bin/ to the PATH to type only terrac and terractl. The VSCode extension "Terra" brings this
same package inside.

The serial port and avrdude need access to the USB device: on most distributions, the user in
the dialout group (or a udev rule), set once by the administrator.

Contents: lib/terrac (the compiler, with Lua, LPeg and the mcpp preprocessor inside),
lib/terractl.pyz, python/ (Python 3.14 from python-build-standalone), tossim/ (the simulators),
firmware/ (micaz), defs/ (the .defs of the simulator and of the micaz firmware), licenses/.

Documentation: https://afbranco.github.io/Terra
