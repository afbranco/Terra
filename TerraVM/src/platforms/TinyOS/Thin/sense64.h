#ifndef SENSE64_H
#define SENSE64_H

unsigned fast_sqrt (unsigned radicand);
void setup (void);
void startSample(void (*cb)());
unsigned sample3();
void store (void);

#endif /* SENSE64_H */
