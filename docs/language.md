---
layout: terra
title: The Terra language
---

# The Terra language

Terra programs are written in **Céu-T**, a reactive language derived from
[Céu](http://www.ceu-lang.org/) ([Sant'Anna et al., SenSys 2013](https://doi.org/10.1145/2517351.2517360)).
A program does not poll: it reacts to events (a sensor reading,
a radio message, a timer) and goes back to waiting. The compiler (`terrac`) turns the program into
bytecode for the Terra virtual machine, which runs on each node of the network.

Three properties come from the language and are checked by the compiler:

- **No threads, no races.** Parallel blocks (*trails*) share one CPU. A *reaction* to an event
  runs all the trails that were waiting for it, each one until its next `await`, and only then
  the next event is handled.
- **Bounded reactions.** A loop must wait for something (`await`) in every iteration: a loop that
  could spin forever without waiting is a compile error (E5001, *tight loop*).
- **Nondeterminism warnings.** When two trails do conflicting things in the same reaction (write
  the same variable, or emit events that cannot be emitted together), the compiler warns
  (W2xxx).

The model and its guarantees are discussed in the
[Terra article](https://doi.org/10.1145/2811267) (ACM TOSN, 2015); see [Publications](publications.html).

The events, functions and constants that a program can use come from the VM it runs on:
[TerraNet](terranet.html) (radio) or [TerraGrp](terragrp.html) (groups and aggregation).

## A first program

The program below reads the light and the temperature sensors every minute and turns LED0 on
when either reading is above a limit.

<!-- check: ok -->
```terra
var ushort light, temp;
loop do
    emit REQ_PHOTO();          // request a light reading...
    light = await PHOTO;       // ...and wait for it
    emit REQ_TEMP();
    temp = await TEMP;
    if light > 200 or temp > 300 then
        emit LED0(ON);
    else
        emit LED0(OFF);
    end
    await 1min;
end
```

The two readings are taken one after the other. Requesting both in parallel (`par/and`, below)
also works, but the compiler warns (W2001): `REQ_PHOTO` and `REQ_TEMP` are declared `unsafe` with
each other, because the sensor driver serves one request at a time. See
[Nondeterminism](#nondeterminism).

## Program structure

A program is a sequence of statements. The first line includes the `.defs` file of the VM:

<!-- check: skip -->
```terra
#include "TerraNet.defs"
```

The `.defs` declares the events, functions, constants and record types of the VM, and the
memory available for the program. Each firmware has its own `.defs` (the simulator's comes with
`terrac`; the micaz firmware's is a release asset): compile with the one of the firmware the
program will run on, so that the compiler refuses what that firmware does not have.

The source goes through the C preprocessor (`cpp`) before compiling: `#include`, `#define` and
`#if` work, and comments are `// ...` and `/* ... */`.

## Types and variables

| Type | Meaning |
|---|---|
| `ubyte`, `byte` | 8-bit unsigned / signed integer |
| `ushort`, `short` | 16-bit unsigned / signed integer |
| `ulong`, `long` | 32-bit unsigned / signed integer |
| `float` | 32-bit floating point |

Variables are declared with `var`, optionally with an initial value. Names start with a
lower-case letter; names that start with an upper-case letter are events and constants.

<!-- check: ok -->
```terra
var ubyte count = 0;
var ushort a, b;
var float average;
var ushort[5] reads;          // array of 5 ushort, indexes 0 to 4
a = 3;
reads[a] = 100;
average = reads[a] / 2.0;
count = count + 1;
b = a + count;
reads[0] = b;
```

- Integer arithmetic follows the type of the operands. `ulong` operations are unsigned.
- An index outside the array does not crash the node: a write is discarded, a read returns
  element 0, and the VM signals `ERROR` with `E_IDXOVF` (see [Runtime errors](#runtime-errors)).
- Assigning a larger type to a smaller one gives a warning (W1001, *automatic casting*). An
  explicit cast, `<ubyte>x`, cuts the value to the smaller type without the warning.

### Records

A `regtype` groups fields of basic types or arrays:

<!-- check: ok -->
```terra
regtype reading_t with
    var ubyte  seq;
    var ushort node;
    var ushort value;
end
var reading_t r;
r.seq = 1;
r.node = getNodeId();
```

A `packet` is a record type declared in the `.defs` with a `payload[N]` field: `radioMsg` in
TerraNet, `msgBS_t` and `msgGR_t` in TerraGrp. A packet is abstract: a program cannot declare a
variable of it. It derives a concrete type with `pktype`, adding fields whose total size fits in
the payload (or none), and declares variables of that type:

<!-- check: ok -->
```terra
pktype tempMsg from radioMsg with
    var ubyte  seq;
    var ushort temp;
end
var tempMsg msg;
msg.type = 1;
msg.source = getNodeId();
msg.target = BROADCAST;
msg.seq = 0;
emit REQ_TEMP();
msg.temp = await TEMP;
emit SEND(msg);
```

The keyword is `from` (`pktype X from radioMsg`). The new fields take the place of the payload
field (`data`); the other fields of the packet (`type`, `source`, `target`) stay.

### Constants

Constants are `#define`s, processed by the preprocessor. The `.defs` defines the constants of
the VM (`ON`, `BROADCAST`, `SUCCESS`, ...).

<!-- check: ok -->
```terra
#define LIMIT 300
var ushort t;
emit REQ_TEMP();
t = await TEMP;
if t > LIMIT then
    emit LED0(ON);
end
```

## Expressions

Operators, from the lowest to the highest precedence:

| Operators | Meaning |
|---|---|
| `or` | logical or |
| `and` | logical and |
| `\|` | bitwise or |
| `^` | bitwise exclusive or |
| `&` | bitwise and |
| `==` `!=` | equal, different |
| `<` `<=` `>` `>=` | comparison |
| `<<` `>>` | shifts |
| `+` `-` | sum, difference |
| `*` `/` `%` | product, division, remainder |
| `not` `-` `~` `<T>` | logical not, negation, bitwise not, cast to type T |
| `x[i]` `x.f` | array element, record field |

- Integer division truncates. Division or remainder by zero gives 0 and signals `ERROR` with
  `E_DIVZERO`; the program goes on.
- A shift by 32 bits or more gives 0 (`-1` for `>>` of a negative value).
- `%`, `~`, `inc`, `dec` and array indexes do not accept `float` (E4030).
- `sizeof<T>` is the size in bytes of a type (a basic type, a `regtype` or a `pktype`), as a `ushort`.
- `inc x;` and `dec x;` add and subtract 1.

<!-- check: ok -->
```terra
var ushort v = 1000;
var ubyte low, high;
var ushort size = sizeof<ulong>;
low = <ubyte>(v & 0xFF);
high = <ubyte>(v >> 8);
inc size;
if not (low == 0) and high != 0 then
    emit LEDS(<ubyte>size);
end
```

## Flow control

### Conditionals

<!-- check: ok -->
```terra
var ushort t;
emit REQ_TEMP();
t = await TEMP;
if t > 500 then
    emit LEDS(4);
else/if t > 300 then          // note the slash: else/if
    emit LEDS(2);
else
    emit LEDS(1);
end
```

### Loops

`loop do ... end` repeats forever; `loop i, N do ... end` declares `i` and runs the body with `i`
from 0 to N-1. Both can end early with `break`.

<!-- check: ok -->
```terra
loop i, 3 do
    emit LEDS(i);
    await 1s;
end
loop do
    await 1s;
    emit LED0(TOGGLE);
end
```

Every path through the body of a loop must wait for something, or the compiler stops with E5001
(*tight loop*): a reaction would never end and the node would stop answering. A `loop i, N` with a
variable N that waits only inside the inner loop gives W3006: when N is 0, the outer loop spins.

<!-- check: E5001 -->
```terra
var ubyte x = 0;
loop do
    x = x + 1;
end
```

### Parallel blocks

<!-- check: skip -->
```terra
par/or do  <block 1>  with  <block 2>  ...  end    // ends when the first block ends; the others are aborted
par/and do <block 1>  with  <block 2>  ...  end    // ends when all the blocks have ended
par do     <block 1>  with  <block 2>  ...  end    // never ends (blocks that loop forever)
```

`par/or` is the way to give an action a deadline: the block that finishes first aborts the other.

<!-- check: ok -->
```terra
pktype message from radioMsg with
end
var message msg;
par/or do
    msg = await RECEIVE;
    emit LED1(ON);             // a message arrived in time
with
    await 10s;
    emit LED0(ON);             // timeout
end
```

### Blocks with finally

`do ... finally ... end` runs the `finally` part when the block ends, normally or because a
`par/or` or a `break` aborted it.

<!-- check: ok -->
```terra
par/or do
    do
        emit LED2(ON);
        await FOREVER;
    finally
        emit LED2(OFF);          // runs when the par/or ends
    end
with
    await 5s;
end
```

### Blocks with a value

A block can produce a value with `return`:

<!-- check: ok -->
```terra
var ushort t;
t = do
        emit REQ_TEMP();
        var ushort v = await TEMP;
        if v > 1000 then
            return 1000;
        end
        return v;
    end;
emit LEDS(<ubyte>t);
```

## Events

`emit` raises an **output event** (an action of the VM: a LED, a sensor request, a radio send);
`await` waits for an **input event** (a sensor reading, a message, the end of a send) and returns
its value. The [TerraNet](terranet.html) and [TerraGrp](terragrp.html) pages list them.

Some input events have a second form with an argument, `await EVT(x)`, that waits only for the
occurrences that match x: `await RECEIVE(1)` waits for a message whose `type` is 1, and
`await AGGREG_DONE(2)` for the aggregation with id 2. The VM pages say what x selects for each
event.

<!-- check: ok -->
```terra
pktype message from radioMsg with
    var ubyte[4] values;
end
var message msg;
loop do
    msg = await RECEIVE(1);    // only messages of type 1
    emit LEDS(msg.values[0]);
end
```

When the variable is of a different size or type than the event, the value is converted.

### Internal events

A program can declare its own events to signal between trails:

<!-- check: ok -->
```terra
event ushort reading;
par/and do
    var ushort v = await reading;
    if v > 300 then
        emit LED0(ON);
    end
with
    emit REQ_TEMP();
    var ushort t = await TEMP;
    emit reading(t);
end
```

`await FOREVER` never returns: it keeps a trail alive (for example, inside a `par/or`).

### Timers

`await` with a time waits that long: `await 500ms`, `await 10s`, `await 2min`, `await 1h`, or a
combination such as `await 1min30s`. The time can be a variable or an expression:
`await (t)ms`.

<!-- check: ok -->
```terra
var ushort period = 500;
loop do
    emit LED1(TOGGLE);
    await (period)ms;
end
```

- **The millisecond is 1/1024 s.** The VM inherits the TinyOS timer, which runs at 1024 ticks
  per second. `await 1s` waits 0.977 s and `await 1min` 58.6 s: every time comes out 2.4% shorter
  than written. `getTime()` counts the same ticks. For an exact decimal time, write it in ticks
  (`await 30720ms` is 30 real seconds).
- **The shortest wait is one tick.** `await 0ms` waits 1/1024 s.
- **The longest wait is 2147483646 ms (about 24.8 days).** A constant above it is a compile
  error (E6007); a variable or expression above it waits the maximum and signals `ERROR` with
  `E_TIMEOVF`.

## Nondeterminism

The trails of a `par` run one after the other inside a reaction, in an order the program must
not depend on. The compiler warns when two trails can, in the same reaction:

- write the same variable (W2003), or write and read it;
- emit two events that the `.defs` declares `unsafe` with each other (W2001), such as two `SEND`
  in TerraNet, or two LED events.

<!-- check: W2001 -->
```terra
par/and do
    emit LED0(ON);
with
    emit LEDS(2);
end
```

The warning does not stop the compilation: the program runs, but the result may depend on the
order. Put the actions in sequence, or in different reactions (one of them after an `await`).

## Runtime errors

The VM does not stop for most errors: it signals the input event `ERROR` with a code and goes on.

| Code | When | What the VM does |
|---|---|---|
| `E_DIVZERO` (10) | division or remainder by zero | the result is 0 |
| `E_IDXOVF` (11) | array index out of bounds | a write is discarded; a read returns element 0 |
| `E_TIMEOVF` (12) | `await` time above the maximum | waits the maximum |
| `E_STKOVF` (20) | stack overflow | fatal: the program stops |

<!-- check: ok -->
```terra
par do
    loop do
        var ubyte e = await ERROR;
        emit LEDS(e);
    end
with
    var ubyte zero = 0;
    var ubyte x = 10 / zero;   // E_DIVZERO: x is 0
    await FOREVER;
end
```

## Common patterns

**Periodic action**: do something every minute.

<!-- check: ok -->
```terra
loop do
    await 1min;
    emit LED0(TOGGLE);
end
```

**Do and wait at least**: do something, but take at least one minute before going on.

<!-- check: ok -->
```terra
par/and do
    emit REQ_TEMP();
    var ushort t = await TEMP;
with
    await 1min;
end
emit LED0(ON);
```

**Retry until it works**: try every minute until the action succeeds.

<!-- check: ok -->
```terra
pktype message from radioMsg with
end
var message msg;
msg.type = 1;
msg.target = 1;
loop do
    emit SEND_ACK(msg);
    var ubyte acked = await SEND_DONE_ACK;
    if acked == TRUE then
        break;
    end
    await 1min;
end
emit LED1(ON);
```

**Timeout**: an action with a deadline (see [Parallel blocks](#parallel-blocks)).

**Repeat for a while**: repeat a do-and-wait for four hours.

<!-- check: ok -->
```terra
par/or do
    loop do
        par/and do
            emit REQ_PHOTO();
            var ushort p = await PHOTO;
        with
            await 1min;
        end
    end
with
    await 4h;
end
```

## Example: collect readings at the base station

Every node sends its temperature to the base station (node 1) every 30 seconds and toggles LED2
when it hears a message of another node. In the simulator and in the lab, node 1 is the
base station (the bridge to the computer) and the programs run on the other nodes.

<!-- check: ok -->
```terra
pktype tempMsg from radioMsg with
    var ushort temp;
end
var tempMsg out;
par do
    loop do
        await 30s;
        emit REQ_TEMP();
        out.temp = await TEMP;
        out.type = 1;
        out.source = getNodeId();
        out.target = 1;
        emit SEND(out);
        await SEND_DONE;
    end
with
    loop do
        var tempMsg in = await RECEIVE(1);
        emit LED2(TOGGLE);
    end
end
```
