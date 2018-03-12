/* from https://github.com/CMUAbstract/mementos/tree/master/samples */


//#include <common.h>
#include <stdint.h>
#include <msp430.h>

#define NUMSAMPLES 64

unsigned int progressbar = 0;

unsigned samples[NUMSAMPLES];

uint8_t testVar;

/* adapted from http://supp.iar.com/FilesPublic/SUPPORT/000419/AN-G-002.pdf */
unsigned fast_sqrt (unsigned radicand) {
    unsigned a, b;
    b = radicand;
    a = radicand = 0x3f;
    radicand = b / radicand;
    a = radicand = (radicand+a)>>1;
    radicand = b / radicand;
    a = radicand = (radicand+a)>>1;
    radicand = b / radicand;
    radicand = (radicand+a)>>1;
    return radicand;
}

void __attribute__ ((noinline)) trigF1x(){ testVar=1;}
void __attribute__ ((noinline)) trigF2x(){ testVar=2;}
void __attribute__ ((noinline)) trigF3x(){ testVar=3;}
void __attribute__ ((noinline)) trigF4x(){ testVar=4;}


#ifdef __MSP430__
/* ADC code based on msp430f16x-samples/fet140_adc12_08.c */
void setup (void) {

  P3DIR |= 0x01; // pin 3.0 is an output
}


void (*xcb)();
unsigned nSamples=0;
/* ADC code based on msp430f16x-samples/fet140_adc12_08.c */
void __attribute__ ((noinline)) startSample(void (*cb)()){
  xcb = cb;
  nSamples++;

  WDTCTL = WDTPW+WDTHOLD;                   // Stop watchdog timer
  ADC12CTL0 = ADC12ON+MSC+SHT0_15;          // Turn on ADC12, set sampling time
  ADC12CTL1 = SHP+CONSEQ_1;                 // Use sampling timer, single sequence
  ADC12MCTL0 = INCH_8;                      // ref+=AVcc, channel = A8
  ADC12MCTL1 = INCH_9+EOS;                  // ref+=AVcc, channel = A9, end seq.
  ADC12IE = 0x02;                           // Enable ADC12IFG.1
  ADC12CTL0 |= ENC;                         // Enable conversions

trigF3x();
  ADC12CTL0 |= ADC12SC;                     // Start conversion
  //__bis_SR_register(LPM0_bits + GIE);       // Enter LPM0, Enable interrupts
}

unsigned retVal,retValx;
void __attribute__ ((interrupt(ADC12_VECTOR))) ADC12ISR (void)
{
	trigF4x();  
  // results[0] = ADC12MEM0;                   // Move results, IFG is cleared
  // results[1] = ADC12MEM1;                   // Move results, IFG is cleared
  retVal = ADC12MEM0;
  retValx = ADC12MEM1;
  if (nSamples == 3){
  		nSamples=0;
  		(*xcb)();
	} else {
 		startSample(xcb);
 	}
  __bic_SR_register_on_exit(LPM0_bits);     // Clear LPM0, SET BREAKPOINT HERE
}

unsigned sample3(){
	unsigned retVal;
    P3OUT |= 0x01; // pin 3.0 up

    /* do nothing for 100 cycles (~100 us) while accelerometer settles */
    asm volatile ("NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP\n\t"
                  "NOP\n\tNOP\n\tNOP\n\tNOP");

    /* ADC code adapted from msp430f16x-samples/fet140_adc12_08.c */
    WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
    ADC12CTL0 = SHT0_2 + ADC12ON;             // Set sampling time, turn on ADC12
    ADC12CTL1 = SHP;                          // Use sampling timer
    ADC12CTL0 |= ENC;                         // Conversion enabled
    P6SEL |= 0x01;                            // P6.0 ADC option select

    /* manually unrolled version of above for loop */
    ADC12CTL0 |= ADC12SC;                   // Sampling open
    asm volatile ("NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP");
    ADC12CTL0 |= ADC12SC;                   // Sampling open
    asm volatile ("NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP");
    ADC12CTL0 |= ADC12SC;                   // Sampling open
    asm volatile ("NOP\n\tNOP\n\tNOP\n\tNOP\n\tNOP");
	
	retVal = ADC12MEM0; // grab the last of the 3 samples

    P3OUT &= ~0x01; // pin 3.0 down
    return retVal;
}

#endif // __MSP430__


#define SEG15 0xFE00
void store (void) {
    /* put stuff in flash segment 15 */
/*
    FCTL3 = FWKEY;
    FCTL1 = FWKEY + WRT;
    MEMREF(SEG15) = sampmin;
    MEMREF(SEG15+2) = sampmax;
    MEMREF(SEG15+4) = sampmean;
    MEMREF(SEG15+6) = sampstddev;
    FCTL1 = FWKEY;
    FCTL3 = FWKEY + LOCK;
*/
}

