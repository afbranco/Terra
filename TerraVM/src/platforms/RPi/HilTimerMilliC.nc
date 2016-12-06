configuration HilTimerMilliC{
  provides interface Init;
  provides interface Timer<TMilli> as TimerMilli[uint8_t num];
}
implementation{

  enum {
    TIMER_COUNT = uniqueCount(UQ_TIMER_MILLI)
  };

  components SingleTimerMilliP;
  components new VirtualizeTimerC(TMilli, TIMER_COUNT);

  Init = SingleTimerMilliP;

  TimerMilli = VirtualizeTimerC;
  VirtualizeTimerC.TimerFrom -> SingleTimerMilliP;

}