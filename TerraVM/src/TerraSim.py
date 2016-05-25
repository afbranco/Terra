#!/usr/bin/python

from __future__ import print_function
import sys
from TOSSIM import *

outDBG = open("./log.txt","w")
outVM =  open("./logVM.txt","w")
outCMD = sys.stdout


##################
#
# Terra View command definition
#
# "<<: clock 0 12344 :>>"
# "<<: init col lines maxTime:>>"
# "<<: end 0 0 :>>"
# "<<: start 11 :>>"
# "<<: stop 11 :>>"
# "<<: leds 11 3 :>>"
# "<<: radio 11 21 :>>"
# "<<: radio 11 65535 :>>"
# "<<: sensor 11 temp :>>"
# "<<: sensor 11 photo :>>"
###################
def wcmd(cmd,node=0,p1=0,p2=0):
    print ("<<: {} {} {} {} :>>".format(cmd,node,p1,p2),file=outCMD)
    try:
        outCMD.flush()
    except IOError:
        wdbg("System closed!")
        exit(0)
	sys.stdout.flush()

def wdbg(text):
    print (text,file=outDBG)
    outDBG.flush()

def wvm(text):
    print (text,file=outVM)
    outVM.flush()
    

class Network:
    def __init__(self,maxNode):
        # Create components
        self.tossim = Tossim([])
        self.mac = self.tossim.mac()
        self.radio = self.tossim.radio()

        self.sfFlag=True
        self.liveFlag= True

        try:
            #print("Antes do SF",file=sys.stderr)
            self.sf = SerialForwarder(9002)
            #print("Depois do SF",file=sys.stderr)
        except NameError:
            self.sfFlag=False
            wdbg("Executando sem o SerialForward!")
        except:
            print("Error to start SF",file=sys.stderr)
        #print("Depois do SF",file=sys.stderr)
        

        if (self.sfFlag and self.liveFlag):
            self.throttle = Throttle(self.tossim, 1)

		# CTP Channels
        #self.tossim.addChannel("Forwarder", outDBG)
        #self.tossim.addChannel("CtpForwarder", outDBG)
        #self.tossim.addChannel("Route", outDBG)
        #self.tossim.addChannel("TreeRouting", outDBG)
        #self.tossim.addChannel("TreeRoutingCtl", outDBG)

        self.tossim.addChannel("AM", outCMD)
        ##self.tossim.addChannel("Acks", outDBG)
        self.tossim.addChannel("Packet", outCMD)
        ##self.tossim.addChannel("Serial", outDBG)
        ##self.tossim.addChannel("QueueC", outDBG)
        ##self.tossim.addChannel("HplAtm128Timer0AsyncP", outDBG)
        ##self.tossim.addChannel("Scheduler", outDBG)
        self.tossim.addChannel("LedsC", outCMD)
        
        #--------------------------------------
        #self.tossim.addChannel("terra", outDBG)
        #self.tossim.addChannel("TVIEW", outDBG)
        self.tossim.addChannel("TVIEW", outCMD)
        self.tossim.addChannel("VMDBG", outVM)
        self.ExecTime = 0
        self.localTime = 0

        # Parameters
        self.maxNode = maxNode
        self.MaiorMoteId=100
        self.MoteInic = 10
        self.IntervaloColeta = 30
        self.viewerStep = 100      # step time duration for the viewer
        self.BSConnectMote = 1

        """Noise initialization"""
        noise = open("meyer-heavy_short.txt", "r")
        lines = noise.readlines()
        for line in lines:
            str = line.strip()
            if (str != ""):
                val = int(str)
                for i in range(1, self.maxNode+1):
                    self.tossim.getNode(i).addNoiseTraceReading(val)
        for i in range(1, self.maxNode+1):
            wdbg(("Creating noise model for ",i))
            self.tossim.getNode(i).createNoiseModel()

        # start to process...
        if (self.sfFlag):
            self.sf.process()
        if (self.sfFlag and self.liveFlag):
            self.throttle = Throttle(self.tossim, 1)
            self.throttle.initialize()
            
    def inicMote1(self):
        """Switch-on a mote"""
        self.tossim.getNode(1).bootAtTime(self.tossim.time())
        self.execSteps(1)  # need at least one step to excute the command
        wcmd("start",1)
        wdbg("Script: Started mote: 1")
        
    def addRadio(self,source,offset):
        Gain = 85.0
        self.radio.add(source,source+offset,Gain)
        self.radio.add(source+offset,source,Gain)

    radioDir = {}
    radioDir['T']=-1
    radioDir['B']=+1
    radioDir['R']=+10
    radioDir['L']=-10
    radioDir['TR']=+9
    radioDir['BL']=-9
    radioDir['BR']=+11
    radioDir['TL']=-11

        
    def inicMote(self,mote):
        Gain = 85.0
        """Switch-on a mote"""
        moteId = self.MoteInic+mote
        self.tossim.getNode(moteId).bootAtTime(self.tossim.time())
        # Connect mote 1 to 11
        if ((mote==self.BSConnectMote)):
            self.radio.add(1,moteId,Gain)
            self.radio.add(moteId,1,Gain)

        if  moteId/10 == 1 and moteId%10 > 1 :  # NOT Left	
            # Connect x<->x+1 (bottom)
            self.addRadio(moteId,self.radioDir['B'])
            # Connect x<->x-1 (top)
            self.addRadio(moteId,self.radioDir['T'])
            # Connect x<->x+10 (right)
            self.addRadio(moteId,self.radioDir['R'])
            # Connect x<->x+9 (top-right)
            self.addRadio(moteId,self.radioDir['TR'])
		    # Connect x<->x+11 (bottom-right)
            self.addRadio(moteId,self.radioDir['BR'])
        if  moteId%10 == 1:	# NOT Top
            # Connect x<->x+1 (bottom)
            self.addRadio(moteId,self.radioDir['B'])
            # Connect x<->x+10 (right)
            self.addRadio(moteId,self.radioDir['R'])
            # Connect x<->x-10 (left)
            self.addRadio(moteId,self.radioDir['L'])
		    # Connect x<->x-9 (bottom-left)
            self.addRadio(moteId,self.radioDir['BL'])
		    # Connect x<->x+11 (bottom-right)
            self.addRadio(moteId,self.radioDir['BR'])
        if  moteId%10 == 9:	# NOT Bottom
            # Connect x<->x-1 (top)
            self.addRadio(moteId,self.radioDir['T'])
            # Connect x<->x+10 (right)
            self.addRadio(moteId,self.radioDir['R'])
            # Connect x<->x-10 (left)
            self.addRadio(moteId,self.radioDir['L'])
            # Connect x<->x+9 (top-right)
            self.addRadio(moteId,self.radioDir['TR'])
            # Connect x<->x-11 (top-left)
            self.addRadio(moteId,self.radioDir['TL'])
        if  moteId/10 > 1 and moteId%10 > 1 and moteId%10 < 9:  # all	
            # Connect x<->x+1 (bottom)
            self.addRadio(moteId,self.radioDir['B'])
            # Connect x<->x-1 (top)
            self.addRadio(moteId,self.radioDir['T'])
            # Connect x<->x+10 (right)
            self.addRadio(moteId,self.radioDir['R'])
            # Connect x<->x-10 (left)
            self.addRadio(moteId,self.radioDir['L'])
            # Connect x<->x+9 (top-right)
            self.addRadio(moteId,self.radioDir['TR'])
		    # Connect x<->x-9 (bottom-left)
            self.addRadio(moteId,self.radioDir['BL'])
		    # Connect x<->x+11 (bottom-right)
            self.addRadio(moteId,self.radioDir['BR'])
            # Connect x<->x-11 (top-left)
            self.addRadio(moteId,self.radioDir['TL'])

        # need at least one step to excute the command
        self.execSteps(1) 
        # Logs
        wcmd("start",moteId)
        wdbg(("Script: Started mote:",moteId))

    def stopMote(self,mote):
        """Switch-off a mote"""
        self.tossim.getNode(self.MoteInic+mote).turnOff()
# acho que nao precisa desligar o radio!!! Falta testar isso!
#        for i in range (1,self.maxNode+1):
#            self.radio.remove(self.MoteInic+i,self.MoteInic+mote) 
        wcmd("stop",self.MoteInic+mote)
        wdbg(("Script: Stoped mote:",self.MoteInic+mote))

    def execSteps(self,steps):
        """Execute n steps"""
        if (self.sfFlag and self.liveFlag):
            self.throttle.checkThrottle()
        self.tossim.runNextEvent()
        if (self.sfFlag):
            self.sf.process()
        time = self.tossim.time()
        while (time + steps > self.tossim.time()):
            self.tossim.runNextEvent()

    def execTime(self,xTime):
        """Execute a while"""
        Qtd1sec = self.tossim.ticksPerSecond()
        TExec=(Qtd1sec*self.viewerStep)/1000
        Rodadas=(xTime*1000)/self.viewerStep
        qtd=0
        while (qtd < (Rodadas)):
            qtd=qtd+1
            time = self.tossim.time()
            while ((time + TExec) >= self.tossim.time()):
                if (self.sfFlag and self.liveFlag):
                    self.throttle.checkThrottle()
                self.tossim.runNextEvent()
                if (self.sfFlag):
                    self.sf.process()
            self.localTime = int((self.ExecTime+qtd)*self.viewerStep)
            wcmd("clock",0,self.localTime)
            if (self.localTime%500 == 0):
                wdbg("second:%.1f" % (self.localTime/1000.0))
                wvm("second:%.1f" % (self.localTime/1000.0))
        self.ExecTime=self.ExecTime+qtd

    def getLocalTime(self):
        return self.localTime
    
#----------------------------------------------------------

def main(nLines,nColumnsA,nColumnsB,timeB,runTime):
   
    nColumns = nColumnsA + nColumnsB
    maxNode = nColumns*10 + nLines

    # instantiate the network
    net = Network(maxNode)

    #
    # initialize Terra Viewer
    wcmd("init",nColumns,nLines,runTime)
    net.inicMote1()

    # Start Part A
    for i in range (0,nColumnsA):
        for x in range (1,nLines+1):
            net.inicMote((i*10)+x)
    # Start Part B, after a while...
    net.execTime(timeB)
    for i in range (nColumnsA,nColumns):
        for x in range (1,nLines+1):
            net.inicMote((i*10)+x)

    # execTime minus current execution time
    remainTime = runTime - net.getLocalTime()/1000
    net.execTime(remainTime)
    #
    wdbg("******************************************************")
    wdbg("*          Final do Script                           *")
    wdbg("******************************************************")

    #--------------------------------------------------------

def printArgError():
    sys.stderr.write("Invalid parameters.\n")
    sys.stderr.write("{} Lines  ColumnsA  ColumnsB startB(seconds) RunTime(seconds)\n".format(sys.argv[0]))
    sys.stderr.write("{} <1..9> <1..9>    <0..9>   <0..3600>       <0..90000>\n".format(sys.argv[0]))
    
def tryInt(text):
    try:
        return int(text)
    except ValueError:
        return -1

def userInput():
    nLines=-1
    nColumnsA=-1
    nColumnsB=-1
    timeB=-1
    runTime=-1
    while not(nLines >= 1 and nLines <= 9):
        sys.stderr.write("Enter total lines (<1..9>): ")
        nLines = tryInt(raw_input())
    while not((nColumnsA+nColumnsB) <= 9 and (nColumnsA+nColumnsB) >= 1):
        sys.stderr.write("Max columns = 9!\n")
        nColumnsA=-1
        nColumnsB=-1
        while not(nColumnsA >= 1 and nColumnsA <=9):
            sys.stderr.write("Enter fisrt part columns (<1..9>): ")
            nColumnsA = tryInt(raw_input())
        while not(nColumnsB >= 0 and nColumnsB <= 9):
            sys.stderr.write("Enter second part columns (<0..9>): ")
            nColumnsB = tryInt(raw_input())
    while not(timeB >= 0 and timeB <= 3600):
        sys.stderr.write("Enter delay time to second part (<0..3600>): ")
        timeB = tryInt(raw_input())
    while not(runTime >= 0 and runTime <= 90000):
        sys.stderr.write("Enter total run time (<0..90000>): ")
        runTime = tryInt(raw_input())
        
    main(nLines,nColumnsA,nColumnsB,timeB,runTime)


    

if __name__ == '__main__':
    try:
        if len(sys.argv) == 6 :
            nLines=int(sys.argv[1]) 
            nColumnsA=int(sys.argv[2])
            nColumnsB=int(sys.argv[3])
            timeB=int(sys.argv[4])
            runTime=int(sys.argv[5])
            sys.stderr.write("{} {} {} {} {}\n".format(nLines,nColumnsA,nColumnsB,timeB,runTime))
            if ( nLines >= 1 and nLines <= 9 and \
                 nColumnsA >= 1 and nColumnsA <=9 and \
                 nColumnsB >= 0 and nColumnsB <= 9 and \
                 (nColumnsA+nColumnsB) <= 9 and \
                 timeB >= 0 and timeB <= 3600 and \
                 runTime >= 0 and runTime <= 90000 and \
                 runTime > timeB):
                 main(nLines,nColumnsA,nColumnsB,timeB,runTime)
            else:
                printArgError();
        else:
            if len(sys.argv) == 1 : # request user input
                userInput()
            else:
                printArgError();
        wcmd("end")
    except SystemExit:
        raise               #let pass exit() calls
    except KeyboardInterrupt:
        sys.stderr.write("user abort.\n")   #short messy in user mode
        sys.exit(1) 

