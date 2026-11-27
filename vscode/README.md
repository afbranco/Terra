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
- **Terra: Simulate**: a grid of nodes in TOSSIM with the program, in a terminal (by default in the
  `tinyos-toolchain` container image: the simulator module is for Python 3.14);
- **Terra: Flash a micaz**: a firmware of the release with a node id, through `avrdude`.

`terractl` comes inside the extension and needs only Python 3 (`pyserial` comes inside). The
compiler (`terrac-<v>.tar.gz` of the release) needs Lua 5.1 and lpeg; set `terra.terracPath` if it
is not in the PATH. The simulator needs the `terra-<v>-{net,grp}-tossim-py3-x86_64.tar.gz` of the
release, extracted (asked on the first run).

License: GPL v3 or later. Source: [afbranco/Terra](https://github.com/afbranco/Terra), folder
`vscode/`.
