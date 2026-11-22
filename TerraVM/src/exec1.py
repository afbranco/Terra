#!/usr/bin/python

import sys
from TOSSIM import *

# Create components
t = Tossim([])
m = t.mac()
r = t.radio()

sfFlag=True;
liveFlag= True;
#liveFlag= False;

try:
    sf = SerialForwarder(9002)
except NameError:
    sfFlag=False;
    print "Executando sem o SerialForward!"

if (sfFlag and liveFlag):
    throttle = Throttle(t, 10)

t.addChannel("AM", sys.stdout);
t.addChannel("Acks", sys.stdout);
t.addChannel("Packet", sys.stdout);
t.addChannel("Serial", sys.stdout);
t.addChannel("QueueC", sys.stdout);
t.addChannel("Scheduler", sys.stdout);
t.addChannel("terra", sys.stdout);


# Create message list
Group = list();
QtdGeral=0;

# Parameters
QtdMaxMotes =100;
QtdMotes = 100;
MaiorMoteId=100;
MoteInic = 0;
IntervaloColeta = 30;
TempoPasso = 500.0;     # step time duration for log
BSConnectMote = 1;

#--------------------------------------------
def inicGroup(Qtd,Group):
    """Mote list"""
    Group = list();
    for i in range(0, Qtd):
        Group.append(MoteInic+i+1);
    return Group;

def inicNoise(QtdMaxMotes):
    """Noise initialization"""
    noise = open("meyer-heavy_short.txt", "r")
    lines = noise.readlines()
    for line in lines:
        str = line.strip()
        if (str != ""):
            val = int(str);
            for i in range(1, QtdMaxMotes+1):
                t.getNode(MoteInic+i).addNoiseTraceReading(val)
    for i in range(1, QtdMaxMotes+1):
        print "Creating noise model for ",MoteInic+i;
        t.getNode(MoteInic+i).createNoiseModel()



def inicMote1():
    """Switch-on a mote"""
    t.getNode(1).bootAtTime(t.time());
    print "Script: Started mote: 1";
    
def inicMote(mote):
    """Switch-on a mote"""
    t.getNode(MoteInic+mote).bootAtTime(t.time());

    Gain = 85.0;
    if ((mote==BSConnectMote)):
        r.add(1,MoteInic+mote,Gain);
        r.add(MoteInic+mote,1,Gain);

    r.add(MoteInic+mote,MoteInic+mote+1,Gain);
    r.add(MoteInic+mote+1,MoteInic+mote,Gain);

    r.add(MoteInic+mote,MoteInic+mote+9,Gain);
    r.add(MoteInic+mote+9,MoteInic+mote,Gain);

    r.add(MoteInic+mote,MoteInic+mote+10,Gain);
    r.add(MoteInic+mote+10,MoteInic+mote,Gain);

    r.add(MoteInic+mote,MoteInic+mote+11,Gain);
    r.add(MoteInic+mote+11,MoteInic+mote,Gain);

    print "Script: Started mote:",MoteInic+mote;


def stopMote(mote):
    """Switch-off a mote"""
    t.getNode(MoteInic+mote).turnOff();
    for i in range (1,QtdMotes+1):
        r.remove(MoteInic+i,MoteInic+mote); 
    print "Script: Stoped mote:",MoteInic+mote


def execPassos(passos):
    """Execute x steps"""
    if (sfFlag and liveFlag):
        throttle.checkThrottle();
    t.runNextEvent();
    if (sfFlag):
        sf.process();
    time = t.time()
    while (time + passos > t.time()):
        t.runNextEvent()


def execTempo(TempoTotal,QtdGeral):
    """Execute a while"""
    Qtd1sec = t.ticksPerSecond()
    TExec=Qtd1sec*TempoPasso/1000;
    Rodadas=TempoTotal*1000/TempoPasso;
    qtd=0.0;
    while (qtd < (Rodadas)):
        qtd=qtd+1;
        time = t.time();
        while (time + TExec > t.time()):
            if (sfFlag and liveFlag):
                throttle.checkThrottle();
            t.runNextEvent();
            if (sfFlag):
                sf.process();
        print "second:%.1f" % ((QtdGeral+qtd)*TempoPasso/1000);
        sys.stdout.flush();
    QtdGeral=QtdGeral+qtd;
    return QtdGeral;

#----------------------------------------------------------


#
# 1. Initialize test environment - Create noise
# 
# (the component creation is at the beginning of file)
inicNoise(MaiorMoteId);
if (sfFlag):
    sf.process();
if (sfFlag and liveFlag):
    throttle.initialize();
# 
# 2. Test condition 01
# 
print "******************************************************";
print "*             Test Condition 01                      *";
print "******************************************************";
MoteInic=10;
QtdMotes = 100;
Group=inicGroup(QtdMotes,Group);
inicMote1();
execPassos(1);
#QtdGeral=execTempo(100,QtdGeral);

widthA=4; 
LinesA=3;
LinesB=3;

for i in range (0,LinesA):
    for x in range (1,widthA+1):
        inicMote((i*10)+x);
        execPassos(1);
#        QtdGeral=execTempo(20,QtdGeral);

QtdGeral=execTempo(77,QtdGeral);
for i in range (LinesA,LinesA+LinesB):
    for x in range (1,widthA+1):
        inicMote((i*10)+x);
        execPassos(1);
#        QtdGeral=execTempo(20,QtdGeral);
QtdGeral=execTempo(20,QtdGeral);
#QtdGeral=execTempo(100,QtdGeral);
#QtdGeral=execTempo(120,QtdGeral);
# 20min + Inicializacao do teste que eh 750 seg.
Resto = (1200+750) - (QtdGeral*TempoPasso/1000)
QtdGeral=execTempo(Resto,QtdGeral);
#execPassos(1000);
#
print "******************************************************";
print "*          Final do Script                           *";
print "******************************************************";

#--------------------------------------------------------



