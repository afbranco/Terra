---
layout: terra
title: TerraGrp
---

# TerraGrp: groups, leader election and aggregation

TerraGrp keeps the local operations of [TerraNet](terranet.html) (LEDs, sensors, loopback
events) and replaces the radio by higher-level services: messages to the base station through a
routing tree, groups of nodes, a leader elected in each group, and aggregation of the readings
of a group. Compile with `TerraGrp.defs`.

## Messages to the base station

`SEND_BS` sends a `msgBS_t` to the base station (node 1) through a routing tree (CTP) that the
nodes build by themselves. `getParent()` returns the next node on the way.

<!-- check: ok grp -->
```terra
pktype tempMsg from msgBS_t with
    var ushort temp;
end
var tempMsg msg;
msg.msgId = 1;
loop do
    emit REQ_TEMP();
    msg.temp = await TEMP;
    emit SEND_BS(msg);
    var ubyte status = await SENDBS_DONE;
    await 30s;
end
```

`SENDBS_DONE` arrives **in the same reaction** as the `emit`, with the status of the request
(the message entered the radio queue, or not). It does not confirm the delivery.

## Groups

A group is declared on every node that takes part in it, with the same id and the same `param`,
by `groupInit`:

<!-- check: ok grp -->
```terra
var group_t g;
//             group id  param  nhops  member  election  leader
var ubyte stat = groupInit(g, 1, 0, 2, TRUE, eACTIVE, 0);
```

- **id**: 0 to 31 (above, `groupInit` returns `EINVAL`).
- **param**: two nodes are in the same group only if they use the same id and param.
- **nhops**: how far, in radio hops, the messages of the group go. Use at least 1: with 0 the
  messages do not leave the node, and an aggregation ends with `count` 0.
- **member** (`status`): `TRUE` if this node is a member. A node that is not a member can still
  send to the group and ask for aggregations, but receives no group messages.
- **election** (`elFlag`): `eACTIVE` (votes and can be elected), `ePASSIVE` (votes, is never
  elected) or `eOFF` (out of the election).
- **leader**: the initial leader (0: none).

`SEND_GR` sends a `msgGR_t` to the members of the group `msg.grId` (to all of them with
`msg.node = BROADCAST`, or to one node). `REC_GR` receives it, with the sender in `msg.node`.
`await REC_GR(g)` waits only for messages of group g. Sending to a group that the node did not
declare does not send anything: `SENDGR_DONE` arrives with `EINVAL`. Like `SENDBS_DONE`,
`SENDGR_DONE` comes in the same reaction and does not confirm the delivery.

<!-- check: ok grp -->
```terra
pktype grMsg from msgGR_t with
    var ushort temp;
end
var group_t g;
var grMsg out;
var ubyte stat = groupInit(g, 1, 0, 2, TRUE, eOFF, 0);
par do
    loop do
        var grMsg in = await REC_GR(1);
        emit LED1(TOGGLE);
    end
with
    loop do
        await 20s;
        out.grId = 1;
        out.node = BROADCAST;
        out.msgId = 1;
        emit REQ_TEMP();
        out.temp = await TEMP;
        emit SEND_GR(out);
    end
end
```

The VM keeps up to 32 groups (ids of 5 bits).

## Leader election

In each group with election (`elFlag` not `eOFF`), the members elect a leader by themselves:

- the election starts when the group is declared and is renewed every 5 minutes;
- each voter's vote is its battery voltage; the highest vote wins, and a tie goes to the highest
  node id;
- `ePASSIVE` nodes vote but are never elected.

`LEADER_NEW` arrives with the id of the new leader, and `LEADER_LOST` (with 0) when the group
loses its leader. `await LEADER_NEW(g)` waits only for group g.

<!-- check: ok grp -->
```terra
var group_t g;
var ubyte stat = groupInit(g, 2, 0, 3, TRUE, eACTIVE, 0);
loop do
    var ushort leader = await LEADER_NEW(2);
    if leader == getNodeId() then
        emit LED0(ON);
    else
        emit LED0(OFF);
    end
end
```

## Aggregation

An aggregation asks the members of a group for a sensor reading and combines the answers. It is
declared once with `aggregInit` over a declared group, and run with `emit AGGREG`; the result
comes in `AGGREG_DONE`, an `aggDone_t`.

<!-- check: ok grp -->
```terra
var group_t g;
var aggreg_t a;
var aggDone_t r;
var ubyte stat = groupInit(g, 1, 0, 2, TRUE, eOFF, 0);
a.agId = 1;                    // set before aggregInit: 0 to 7
//               group  sensor    function  comparison  reference
stat = aggregInit(a, g, SID_TEMP, fAVG, opGT, 500);
loop do
    await 1min;
    emit AGGREG(a);
    r = await AGGREG_DONE(1);
    if r.countTrue > r.countFalse then
        emit LED2(ON);         // most of the group is above 500
    end
end
```

- `agId` (0 to 7) is a field of the `aggreg_t` that the program sets **before** `aggregInit`.
  `AGGREG_DONE(x)` waits for the aggregation with that id. `aggregInit` returns `EINVAL` for an
  id above 7 or for a group not declared.
- The sensor is one of the `SID_*` constants. A sensor without a reading (the interrupts, or the
  ports on the simulator) counts as 0.
- The function (`fAVG`, `fSUM`, `fMAX`, `fMIN`) gives `value`. `fMIN` with no answer gives 0.
  `fRESERV` counts the answers and ignores the readings.
- Each reading is compared with `refVal` by `agComp` (`opLT` ... `opNEQ`): `countTrue` and
  `countFalse` count the results. `count` is the number of readings.
- A node outside the group can ask for an aggregation: it receives the answers of the members
  and does not count its own reading.
- `AGGREG` without `aggregInit`, or with the aggregation queue full (3 pending aggregations),
  ends at once with `count` 0.

## Reference

{% include generated/terragrp.md %}
