# Terra for VS Code

[Terra](https://afbranco.github.io/Terra/) is a programming system for wireless sensor networks: a
small virtual machine on the motes (TinyOS, micaz and the TOSSIM simulator) and a reactive language
based on Céu. This extension:

- highlights `.terra` files and brings snippets (`loop`, `par/or`, `pktype`, `send`...);
- shows the documentation of the events, functions, constants and types of the VM on hover and in
  the completion list (from `terra-docs.json` of the same release, for TerraNet or TerraGrp by the
  `#include` of the program);
- compiles with `terrac --diag=json` on save (or with **Terra: Compile**, Ctrl+Shift+B) and lists
  the errors and warnings in Problems, each with a link to its code on the site;
- **Terra: Load program on the network**: compiles and sends the `.vmx` through the base station
  with `terractl` (serial port or SerialForwarder), then shows the messages that reach it, field by
  field by the `pktype` of the program;
- **Terra: Show messages of the base station**;
- **Terra: Simulate**: a grid of nodes in TOSSIM with the program, in a terminal;
- **Terra: Flash a micaz**: a firmware of the release with a node id, through `avrdude`.

**On Linux (x86_64)**, install `terra-vscode-<v>-linux-x64.vsix`: it brings everything inside (the
compiler, `terractl` with its own Python, the TerraNet and TerraGrp simulators and the micaz
firmware), unpacked on the first use into the extension's own folder. Nothing is installed on the
machine and no administrator is needed; the Python, Lua and compilers of the machine are not used
nor touched. Only the USB access of the MIB520 (serial port and `avrdude`) may need the
administrator once (the `dialout` group or a udev rule).

On other systems, `terra-vscode-<v>.vsix` has the editor features and `terractl` (it needs Python
3); set `terra.terracPath` to a `terrac`, and simulate in the `tinyos-toolchain` container image
(`terra.simulation.containerImage`) with the `terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz` of the
release, extracted (asked on the first run).

Any setting given explicitly (`terra.terracPath`, `terra.terractlPath`, the simulator folders)
takes the place of what comes inside the extension.

License: GPL v3 or later. Source: [afbranco/Terra](https://github.com/afbranco/Terra), folder
`vscode/`.
