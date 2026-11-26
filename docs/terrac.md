---
layout: terra
title: terrac
---

# terrac, the Terra compiler

`terrac` compiles a Terra program (`.terra`) into bytecode for the VM (`.vmx`). It is written in
Lua and comes in the release asset `terrac-<version>.tar.gz`, with the `.defs` of the simulator
(`TerraNet.defs`, `TerraGrp.defs`).

## Installing and running

It needs Lua 5.1, LPeg (0.10.2 or 1.x) and the C preprocessor. On Ubuntu or Debian:

```bash
sudo apt-get install lua5.1 lua-lpeg cpp
tar xzf terrac-<version>.tar.gz
cd terrac-<version>
lua5.1 terrac myProgram.terra      # writes myProgram.vmx next to the source
```

The program includes the `.defs` of its VM (`#include "TerraNet.defs"`), found in the folder of
the program or in a folder given with `-I`. Use the `.defs` of the firmware the program will run
on: the one in `terrac-<version>.tar.gz` for the simulator, and
`terra-<version>-{net,grp}-micaz-nobs.defs` for the micaz firmware. A program that uses something
the firmware does not have does not compile.

## Options

| Option | Default | Meaning |
|---|---|---|
| `--opt`, `--no-opt` | `--opt` | optimize the bytecode. If a program behaves differently than expected, compile it with `--no-opt` and report the case |
| `--warn`, `--no-warn` | `--warn` | show the warnings |
| `--wstrong`, `--no-wstrong` | `--wstrong` | warn about strong nondeterminism (W2001, W2003) |
| `--wweak`, `--no-wweak` | `--no-wweak` | warn about weak nondeterminism (W2002, W2004) |
| `-Ipath` | | folder for `#include` files |
| `--diag=json` | text | diagnostics as JSON lines on the standard error |
| `--catalog` | | print the catalog of codes (JSON) and exit |

## Output

At the end, `terrac` prints the memory the program uses, for example:

```
---------------------------------------------------------------------
-- Terra Compiler: TerraNet_MsgQ            VM Code:  000.002.000  --
---------------------------------------------------------------------
--   Memory allocation in bytes:  (code optimized)                 --
--   Total =  Code + Ctl/Vars + Stack           |    Radio Msgs    --
--     120      79       29       12            |         4        --
---------------------------------------------------------------------
```

(the [first program](language.html#a-first-program) of the language page). With warnings, a last
line says how many.

The total must fit in the memory for programs of the firmware, given in the `.defs`: 1728 bytes
in the TerraNet simulator and 1920 in the TerraNet micaz firmware; 576 in the TerraGrp simulator.
Above it, the compiler warns (W5003) and the VM does not load the program. *Radio Msgs* is the
number of radio messages needed to send the program to the nodes.

## Diagnostics

Errors and warnings have a code (`E3001`, `W2003`...) listed in
[terrac error codes](terrac-codes.html). The text output is the same as always:

```
ERR : line 4 : variable/event "x" is not declared
```

With `--diag=json`, the standard error has only JSON lines, one per diagnostic, and always ends
with a summary line:

```json
{"code":"W2003","severity":"warning","file":"p.terra","line":5,"col":3,"msg":"nondeterminism (write conflict) : variable/event `x´ (line 5) vs variable/event `x´ (line 7)","args":{"a":"variable/event `x´ (line 5)","b":"variable/event `x´ (line 7)"},"related":[{"file":"p.terra","line":7,"col":3}]}
{"summary":{"ok":true,"errors":0,"warnings":1,"optimized":true,"vm":{"name":"TerraNet_MsgQ","version":"000.002.000"},"memory":{"total":51,"code":35,"ctl_vars":16,"stack":0,"radio_msgs":3}}}
```

- `line` and `msg` are the same as in the text output; `args` has the values in the message.
- `col` (from 1, in characters) comes when the compiler knows the column; syntax errors also have
  `col_end`, the column just after the token.
- An error inside an `#include`: `line` is the line of the directive in the program, and
  `include` has the `{file, line, col}` of the real place.
- `related`: the second place in the program (W2xxx warnings). These warnings also have, in
  `args`, `kind_a`, `name_a`, `line_a` and the same with `_b`: the kind of access (one of the
  `access_kinds` of the catalog, such as `event`, `variable` or `internal_event`), the name and the
  line.
- Errors of the preprocessor come as `E1004` (warnings, `W6001`), with its file, line and column.
- `E0001` is an internal failure of the compiler, with the Lua message in `args.lua`: please
  report it.
- The summary has `memory` only when there is no error. A diagnostic about the whole program
  (W5003) has no `line`.
