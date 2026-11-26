---
layout: terra
title: TerraNet
---

# TerraNet: radio and local operations

TerraNet is the lighter Terra VM: local operations (LEDs, sensors, loopback events) and radio
messages to the nodes in range, with an optional message queue. Compile with `TerraNet.defs`.

## Local operations

Sensors are read in two steps: `emit` the request and `await` the reading. Readings are the raw
10-bit value of the A/D converter, not a physical unit. Timers are not events of the VM: they are
part of the language (`await 10s`, see [Timers](language.html#timers)).

## Radio

A message is a `radioMsg` with `type`, `source`, `target` and 20 bytes of payload. Derive a type
from it with `pktype` and declare a variable of that type:

<!-- check: ok -->
```terra
pktype tempMsg from radioMsg with
    var ubyte  seq;
    var ushort temp;
end
var tempMsg msg;
msg.type = 1;
msg.source = getNodeId();
msg.target = BROADCAST;        // every node in range; or a node id
msg.seq = 0;
loop do
    emit REQ_TEMP();
    msg.temp = await TEMP;
    emit SEND(msg);
    var ubyte status = await SEND_DONE;
    inc msg.seq;
    await 10s;
end
```

- `SEND` reaches only the nodes in radio range: there is no routing. A program that needs to
  reach a far node forwards the message itself.
- `SEND_DONE` arrives when the radio has finished the send, with the status (`SUCCESS` or an
  error code). It does not mean the message was received: for that, use `SEND_ACK`, which asks
  the target for an acknowledgement and returns `TRUE` or `FALSE` in `SEND_DONE_ACK`.
- `RECEIVE` returns the next message received. `await RECEIVE(t)` waits only for messages of
  type t. The VM keeps two receive buffers: a message that arrives while both wait for the
  program is discarded. A program that receives faster than it handles can keep messages in the
  queue.
- `setRFPower(level)` sets the radio power (0 to 7) of the messages of the program. The default
  is the one of the firmware build (4).

## Message queue

`qPut`, `qGet`, `qSize` and `qClear` keep up to 10 `radioMsg` in a queue of the VM, and
`Q_READY` signals that the queue went from empty to not empty. The queue exists in the firmware
built with `MOD=MSGQ`, as all the TerraNet firmware of the releases.

<!-- check: ok -->
```terra
pktype message from radioMsg with
    var ushort value;
end
var message in, out;
par do
    loop do
        in = await RECEIVE;
        var ubyte stat = qPut(in);
    end
with
    loop do
        await Q_READY;
        loop do
            if qSize() == 0 then
                break;
            end
            var ubyte stat = qGet(out);
            out.target = 1;
            emit SEND(out);
            await SEND_DONE;
        end
    end
end
```

## Reference

{% include generated/terranet.md %}
