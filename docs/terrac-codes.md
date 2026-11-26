---
layout: terra
title: terrac error codes
---

# terrac error and warning codes

Every error (`E`) and warning (`W`) of the compiler has a stable code: a code never changes its
meaning, and a new error gets a new code. The code appears in the `--diag=json` output and in
the catalog (`terrac --catalog`, also a release asset, `terrac-errors-<version>.json`). An error
stops the compilation; a warning does not.

## Common errors and how to fix them

### Syntax

**E2001: expected `;`.** A statement does not end with `;`. The line in the message is usually
the line *after* the one that misses it.

<!-- check: E2001 -->
```terra
var ubyte x
x = 1;
```

**E2021: expected a statement.** Something that is not a statement comes where one was
expected. The most common cause is a block (`do`, `then`, `loop`, `par`) without its `end`: the
compiler reaches the end of the file still inside the block, and points at the last `;`. Count
the `end`s from the block that starts before the line of the message.

<!-- check: E2021 -->
```terra
loop do
    await 1s;
    emit LED0(TOGGLE);
```

**E2020: expected an expression.** Something is missing after `=`, an operator or a `(`.

<!-- check: E2020 -->
```terra
var ubyte x;
x = ;
```

**E2022, E2023: expected an event, or a variable or event.** After `await` comes an event or a
time; after `emit`, an event; on the left of `=`, a variable.

<!-- check: E2022 -->
```terra
loop do
    await ;
end
```

**E2024: expected an identifier beginning with lower-case.** Variable names start with a
lower-case letter; names in upper case are events and constants.

<!-- check: E2024 -->
```terra
var ubyte Count;
```

### Names

**E3001, E3002: not declared.** The variable, event or function does not exist: a typo, a
variable used before its `var`, or an event that the VM does not have (each `.defs` declares the
events of its firmware: `INIT` does not exist, and `MIC` exists only with the MTS300 board).

<!-- check: E3002 -->
```terra
await INIT;
```

**E3019: packet type not defined.** `pktype X from P` needs a packet `P` of the VM: `radioMsg`
in TerraNet, `msgBS_t` or `msgGR_t` in TerraGrp.

<!-- check: E3019 -->
```terra
pktype myMsg from message with
    var ubyte seq;
end
```

### Types

**E4013, E4015: type or size incompatibility.** The two sides of an assignment, or an event and
its argument, have types that do not convert: for example a record where a number is expected,
or a message of another `pktype`.

<!-- check: E4015 -->
```terra
pktype message from radioMsg with
    var ushort value;
end
var message msg;
var ushort v;
v = msg;
```

**E4016: invalid attribution, not a value.** The left side of `=` must be a variable, a field
or an array element, not an expression.

<!-- check: E4016 -->
```terra
var ubyte x;
x + 1 = 3;
```

**E4030: invalid float operation.** `%`, `~`, `inc`, `dec` and array indexes take only
integers. Convert first: `<ushort>f % 10`.

<!-- check: E4030 -->
```terra
var float f = 2.5;
var float r = f % 2;
```

### Control and limits

**E5001: tight loop.** A path through the body of a loop does not wait for anything (`await`):
the reaction would never end. Add an `await` to every path.

<!-- check: E5001 -->
```terra
var ubyte x = 0;
loop do
    if x > 10 then
        await 1s;
    end
    inc x;
end
```

**E6007: await time above the maximum.** The longest wait is 2147483646 ms, about 24.8 days.

<!-- check: E6007 -->
```terra
await 600h;
```

## Common warnings

**W1001: automatic casting.** A value of a larger type is assigned to a smaller one and may be
cut. When that is intended, write the cast: `x = <ubyte>v;`.

<!-- check: W1001 -->
```terra
var ushort v = 1000;
var ubyte x = v;
```

**W2001 to W2004: nondeterminism.** Two parallel trails do, in the same reaction, things whose
order matters: emit two events that the VM declares `unsafe` with each other (two `SEND`, two LED
events), or write the same variable. The message gives the two lines. Put the actions in
sequence, or after different `await`s. See [Nondeterminism](language.html#nondeterminism).

<!-- check: W2001 -->
```terra
pktype message from radioMsg with
end
var message a, b;
par/and do
    emit SEND(a);
with
    emit SEND(b);
end
```

**W3006: loop with a variable count.** The only `await` of a loop is inside a `loop i, N` with a
variable N: when N is 0, the outer loop does not wait, and the node stops answering.

<!-- check: W3006 -->
```terra
var ubyte n = 0;
loop do
    loop i, n do
        await 1s;
    end
end
```

**W4002: event without any await.** An internal event is emitted but no trail waits for it.

<!-- check: W4002 -->
```terra
event ubyte done;
emit done(1);
```

**W5003: program too big.** The program needs more memory than the firmware has for programs
(from the `.defs`: 1728 bytes in the TerraNet simulator, 576 in TerraGrp). It will not load.

## All the codes

{% include generated/codes.md %}
