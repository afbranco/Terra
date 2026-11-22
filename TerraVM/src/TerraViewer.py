#!/usr/bin/python

import sys
import pygame
from pygame.locals import *
from collections import deque
import re
import select
from struct import *

BLACK = (  0,   0,   0)
WHITE = (255, 255, 255)
BLUE =  (  100,   100, 200)
BLUE2 = (  0,   0, 200)
GREEN = (  50, 205,  50)
RED =   (255,   0,   0)
YELOW = (255,   215, 0)
BACKGROUND = (255, 250, 250)
GRAY = (190, 190, 190)
PINK = (255,20,147)
BROWN = (139,90,43)

zoom = 1
_nodeSize = 20
_nodeDist = 40
nodeSize = _nodeSize*zoom
nodeDist = _nodeDist*zoom
nLines = 1
nCols = 1
offset = nodeDist/2
eraseTime = 300

gNodes=[0 for x in xrange(100)]
eraseQueue = deque()
screen = 0 # Global screen
globalClock = 0
runTime = 0
globalFont = 0
background = 0

class gNode:
    def __init__(self,id):
        self.isStarted=False
        self.column = int(id/10)
        self.line = id%10
        self.xx = nodeDist*self.column + offset
        self.yy = nodeDist*self.line - offset
        self.id = id
        self.idStr = str(id)
        rect = [self.xx ,self.yy,nodeSize,nodeSize]
        self.node = pygame.draw.rect(screen,BLUE,rect,1)
        self.font = pygame.font.SysFont("dejavusans", 7*zoom)
        self.text = self.font.render(self.idStr, 1, GRAY)
        screen.blit(self.text, [self.xx+2*zoom,self.yy+2*zoom])
        self.LedsValue=0
        self.setLeds(self.LedsValue)
        self.sensorValue(1)
        self.sensorValue(2)
        self.sensorValue(3)
        pygame.display.update(rect)
    def update(self):
        self.xx = nodeDist*self.column + offset
        self.yy = nodeDist*self.line - offset
        rect = [self.xx ,self.yy,nodeSize,nodeSize]
        self.node = pygame.draw.rect(screen,BLUE,rect,1)
        self.font = pygame.font.SysFont("dejavusans", 7*zoom)
        self.text = self.font.render(self.idStr, 1, GRAY)
        screen.blit(self.text, [self.xx+2*zoom,self.yy+2*zoom])
        self.setLeds(self.LedsValue)
        self.sensor(1)
        self.sensor(2)
        self.sensor(3)
        self.sensorValue(1)
        self.sensorValue(3)
        self.sensorValue(2)
        if self.isStarted:
            self.vmstart()
        else:
            self.vmstop()
        
    def stop(self):
        pygame.draw.rect(screen,BACKGROUND,self.node,0)
        pygame.display.update(self.node)
    def vmstart(self):
        self.isStarted=True
        self.text = self.font.render(self.idStr, 1, BLACK, BACKGROUND)
        screen.blit(self.text, [self.xx+2*zoom,self.yy+2*zoom])
        pygame.display.update(self.node)
    def vmstop(self):
        self.isStarted=False
        self.text = self.font.render(self.idStr, 1, GRAY, BACKGROUND)
        screen.blit(self.text, [self.xx+2*zoom,self.yy+2*zoom])
        pygame.display.update(self.node)
    def getLeds(self):
        return self.LedsValue
    def setLeds(self,val):
        self.LedsValue = val
        self.color0 = BLACK
        self.color1 = BLACK
        self.color2 = BLACK
        self.fill0 = 1
        self.fill1 = 1
        self.fill2 = 1
        if (self.LedsValue & 1):
            self.color0,self.fill0 = (RED,0)
        if (self.LedsValue & 2):
            self.color1,self.fill1 = (GREEN,0)
        if (self.LedsValue & 4):
            self.color2,self.fill2 = (YELOW,0)
        self.led0 = pygame.draw.circle(screen,BACKGROUND,[self.xx+4*zoom,self.yy+nodeSize-4*zoom],2*zoom,0)
        self.led1 = pygame.draw.circle(screen,BACKGROUND,[self.xx+8*zoom,self.yy+nodeSize-4*zoom],2*zoom,0)
        self.led2 = pygame.draw.circle(screen,BACKGROUND,[self.xx+12*zoom,self.yy+nodeSize-4*zoom],2*zoom,0)
        self.led0 = pygame.draw.circle(screen,self.color0,[self.xx+4*zoom,self.yy+nodeSize-4*zoom],2*zoom,self.fill0)
        self.led1 = pygame.draw.circle(screen,self.color1,[self.xx+8*zoom,self.yy+nodeSize-4*zoom],2*zoom,self.fill1)
        self.led2 = pygame.draw.circle(screen,self.color2,[self.xx+12*zoom,self.yy+nodeSize-4*zoom],2*zoom,self.fill2)
        pygame.display.update([self.xx,self.yy+nodeSize-6*zoom,self.xx+14*zoom,self.yy+nodeSize-2*zoom])
    def getLinePoints(self,target):
        targetx = int(target/10);
        targety = target%10;
        # prevent wrong targets
        startx = 0
        stop1x = 0
        starty = 0
        stop1y = 0
        stop2x = 0
        stop2y = 0
        if (self.line == targety and self.column != targetx): # -- 
            startx = self.xx + (targetx-self.column+1)*(nodeSize/2) + (targetx-self.column)*1
            stop1x = self.xx + (targetx-self.column+1)*(nodeSize/2) + (targetx-self.column)*nodeDist - (targetx-self.column)*(nodeSize) - (targetx-self.column)*1
            starty = self.yy + (nodeSize/2) + (targetx-self.column)*2
            stop1y = self.yy + (nodeSize/2) + (targetx-self.column)*2
            stop2x = stop1x - (targetx-self.column)*4
            stop2y = stop1y + (targetx-self.column)*4
        if (self.line != targety and self.column == targetx): # |
            startx = self.xx + (nodeSize/2) + (targety-self.line)*2
            stop1x = self.xx + (nodeSize/2) + (targety-self.line)*2
            starty = self.yy + (targety-self.line+1)*(nodeSize/2) + (targety-self.line)*1
            stop1y = self.yy + (targety-self.line+1)*(nodeSize/2) + (targety-self.line)*nodeDist - (targety-self.line)*(nodeSize) - (targety-self.line)*1
            stop2x = stop1x + (targety-self.line)*4
            stop2y = stop1y - (targety-self.line)*4
        if (self.line != targety and self.column != targetx): # / \
            startx = self.xx + (targetx-self.column+1)*(nodeSize/2) + (targetx-self.column)*1 
            stop1x = self.xx + (targetx-self.column+1)*(nodeSize/2) + (targetx-self.column)*nodeDist - (targetx-self.column)*(nodeSize) - (targetx-self.column)*1
            starty = self.yy + (targety-self.line+1)*(nodeSize/2) + (targety-self.line)*1 + (targety-self.line)*2 
            stop1y = self.yy + (targety-self.line+1)*(nodeSize/2) + (targety-self.line)*nodeDist - (targety-self.line)*(nodeSize) - (targety-self.line)*1 + (targety-self.line)*2
            stop2x = stop1x - (targetx-self.column)*4
            stop2y = stop1y 
        return [[startx,starty],[stop1x,stop1y],[stop2x,stop2y]]
    def getLinePointsFar(self):
        startx = self.xx - 2
        starty = self.yy + 5 
        stop1x = self.xx - 7
        stop1y = self.yy + 5
        stop2x = stop1x 
        stop2y = stop1y + 3
        return [[startx,starty],[stop1x,stop1y],[stop2x,stop2y]]
    def radioSendTo(self,target):
        points = self.getLinePoints(target)
        pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
        eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
    def radioSendFar(self):
        points = self.getLinePointsFar()
        pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
        eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
    def radioSendAll(self):
        if self.id%10 > 1: 
            points = self.getLinePoints(self.id-1) # ^
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id/10 > 1 or self.id==11: 
            points = self.getLinePoints(self.id-10) # <-
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id%10 < 9 and self.id != 1:
            points = self.getLinePoints(self.id+1) # v
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id/10 < 9:
            points = self.getLinePoints(self.id+10) # ->
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id%10 > 1 and self.id/10 > 1:
            points = self.getLinePoints(self.id-11) # \^
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id%10 < 9 and self.id/10 > 1:
            points = self.getLinePoints(self.id-9) # /v
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id%10 > 1 and self.id/10 > 0 and self.id/10 < 9:
            points = self.getLinePoints(self.id+9) # /^
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id%10 < 9 and self.id/10 > 0 and self.id/10 < 9:
            points = self.getLinePoints(self.id+11) # \v
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))

    def sensorValue(self,stype):
        global sData
        self.sfont = pygame.font.SysFont("dejavusans", 3*zoom)
        if self.id > 1 :
            if stype == 1:
                self.s1text = self.sfont.render(format(sData[(self.id*3)+stype-1],'04d'), 1, GRAY,BACKGROUND)
                screen.blit(self.s1text, [self.xx+nodeSize-8*zoom,self.yy+nodeSize-11*zoom])
                pygame.display.update()
            elif stype == 2:
                self.s2text = self.sfont.render(format(sData[(self.id*3)+stype-1],'04d'), 1, GRAY,BACKGROUND)
                screen.blit(self.s2text, [self.xx+nodeSize-8*zoom,self.yy+nodeSize-15*zoom])
                pygame.display.update()
            else :
                self.s3text = self.sfont.render(format(sData[(self.id*3)+stype-1],'04d'), 1, GRAY,BACKGROUND)
                screen.blit(self.s3text, [self.xx+nodeSize-8*zoom,self.yy+nodeSize-19*zoom])
                pygame.display.update()
        else:
            if stype == 1:
                self.s1text = self.sfont.render('temp', 1, GRAY,BACKGROUND)
                screen.blit(self.s1text, [self.xx+nodeSize-10*zoom,self.yy+nodeSize-11*zoom])
            elif stype == 2:
                self.s2text = self.sfont.render('photo', 1, GRAY,BACKGROUND)
                screen.blit(self.s2text, [self.xx+nodeSize-10*zoom,self.yy+nodeSize-15*zoom])
            else :
                self.s3text = self.sfont.render('volts', 1, GRAY,BACKGROUND)
                screen.blit(self.s3text, [self.xx+nodeSize-10*zoom,self.yy+nodeSize-19*zoom])
        

    def sensor(self,stype):
        if stype == 1:
            color = RED
            p1 = [self.xx+nodeSize-4*zoom,self.yy+nodeSize-2*zoom]
            p2 = [self.xx+nodeSize-2*zoom,self.yy+nodeSize-2*zoom]
            p3 = [self.xx+nodeSize-2*zoom,self.yy+nodeSize-3*zoom]
            p4 = [self.xx+nodeSize-4*zoom,self.yy+nodeSize-3*zoom]
        elif stype == 2:
            color = GREEN
            p1 = [self.xx+nodeSize-4*zoom,self.yy+nodeSize-4*zoom]
            p2 = [self.xx+nodeSize-2*zoom,self.yy+nodeSize-4*zoom]
            p3 = [self.xx+nodeSize-2*zoom,self.yy+nodeSize-5*zoom]
            p4 = [self.xx+nodeSize-4*zoom,self.yy+nodeSize-5*zoom]
        else:
            color = BLACK
            p1 = [self.xx+nodeSize-4*zoom,self.yy+nodeSize-6*zoom]
            p2 = [self.xx+nodeSize-2*zoom,self.yy+nodeSize-6*zoom]
            p3 = [self.xx+nodeSize-2*zoom,self.yy+nodeSize-7*zoom]
            p4 = [self.xx+nodeSize-4*zoom,self.yy+nodeSize-7*zoom]
        points = [p1,p2,p3,p4,p1]
        pygame.display.update(pygame.draw.lines(screen,color,False,points,1))
        eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))

    def serial(self,stype):
        if stype == 0:  # out
            color = RED
            p1 = [self.xx+2*zoom,self.yy+1*zoom]
            p2 = [self.xx+4*zoom,self.yy+1*zoom]
            p3 = [self.xx+4*zoom,self.yy+2*zoom]
            p4 = [self.xx+2*zoom,self.yy+2*zoom]
        else:           # in
            color = BLUE
            p1 = [self.xx+5*zoom,self.yy+1*zoom]
            p2 = [self.xx+7*zoom,self.yy+1*zoom]
            p3 = [self.xx+7*zoom,self.yy+2*zoom]
            p4 = [self.xx+5*zoom,self.yy+2*zoom]
        points = [p1,p2,p3,p4,p1]
        pygame.display.update(pygame.draw.lines(screen,color,False,points,1))
        eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))

    def error(self,ecode):
        if ecode == 0 : # error reset
            pygame.draw.rect(screen,BLUE,self.node,1)
            pygame.display.update(self.node)
        else:
            pygame.draw.rect(screen,RED,self.node,1)
            pygame.display.update(self.node)

    def getXY(self):
        return (self.xx, self.yy)
  
##################
#
# Terra View commnad definition
#
# "<<: clock 0 12344 :>>"
# "<<: init col lines time:>>"
# "<<: end 0 0 :>>"
# "<<: start 11 :>>"
# "<<: stop 11 :>>"
# "<<: leds 11 3 :>>"
# "<<: radio 11 21 :>>"
# "<<: radio 11 65535 :>>"
# "<<: sensor 11 temp :>>"
# "<<: sensor 11 photo :>>"
# "<<: serial 0 0 :>>"
# "<<: serial 1 0 :>>"
# "<<: error 1 10 :>>"
###################
def procCMD(cmd,node,p1,p2):
    return {
      'clock': clock,
      'init': init,
      'end': end,
      'start': start,
      'stop': stop,
      'vmstart': vmstart,
      'vmstop': vmstop,
      'leds': leds,
      'radio': radio,
      'sensor': sensor,
      'serial': serial,
      'error': error
    }[cmd](int(node),int(p1),int(p2))

def clock(node,param,p2):
    global globalClock
    globalClock = param
    if globalClock%1000 == 0:
        text = globalFont.render(" {}s of {}s [zoom: x{}] ".format(globalClock/1000,runTime,zoom), 1, BLACK,BACKGROUND)
        textpos = text.get_rect(x=10)
        #textpos = text.get_rect(centerx=background.get_width()-text.get_width()-10)
        screen.blit(text, textpos)
        pygame.display.update()
    while ((len(eraseQueue)> 0) and (pygame.time.get_ticks() > eraseQueue[0][0])):
        time,points = eraseQueue.popleft()
        pygame.display.update(pygame.draw.lines(screen,BACKGROUND,False,points,1))
        pygame.event.pump()

def calcZoom(DispW,DispH):
    global nodeDist
    global nodeSize
    global offset
    zoomH = DispH/(nLines*_nodeDist+(_nodeDist/2))
    zoomW = DispW/((nCols+1)*_nodeDist+(_nodeDist/2))
    if zoomH < zoomW:
        z = zoomH
    else:
        z = zoomW
    if z < 1:
        z = 1
    nodeSize = _nodeSize*z
    nodeDist = _nodeDist*z
    offset = nodeDist/2
    return z
   
def init(_nCols,_nLines,p2):
    global screen
    global globalFont
    global background
    global runTime
    global zoom
    global nodeSize
    global nodeDist
    global nLines
    global nCols
    global offset
    global hasDisplay

    nLines = _nLines
    nCols = _nCols
    runTime = p2
    pygame.init()
    DispInfo = pygame.display.Info()
    #print DispInfo
    DispW = DispInfo.current_w
    DispH = DispInfo.current_h
    # prevent dual monitor system
    if (DispH > DispW):
        DispH = DispW*9/16
    if (DispW > (2*DispH)):
        DispW = DispH*16/9
    zoom = calcZoom(int(0.90*DispW),int(0.90*DispH))
    if zoom > 4 :
        zoom = 4
    nodeSize = _nodeSize*zoom
    nodeDist = _nodeDist*zoom
    offset = nodeDist/2
    #print "zoom=",zoom, "nCols=",nCols, "nLines=",nLines
    pygame.display.set_caption('Terra Simulation Viewer - ({}x{})'.format(nLines,nCols))
    pygame.mouse.set_visible(1)
    ScreenSize = ((nCols+1)*nodeDist+offset,nLines*nodeDist + offset)
    screen = pygame.display.set_mode(ScreenSize,HWSURFACE | DOUBLEBUF | RESIZABLE)
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill(BACKGROUND)
    globalFont = pygame.font.SysFont("dejavusans", 7*zoom)
    screen.blit(background, (0, 0))
    pygame.display.flip()
    clock(0,0,0)
    hasDisplay = True
    readSData()


def end(node,p1,p2):
    exit(0)
    
def start(node,param,p2):
    gNodes[node]=gNode(node)
    
def stop(node,param,p2):
    if gNodes[node]:
        gNodes[node].stop()

def vmstart(node,param,p2):
    if gNodes[node]:
        gNodes[node].vmstart()

def vmstop(node,param,p2):
    if gNodes[node]:
        gNodes[node].vmstop()
    
def leds(node,bitn,value):
    oldVal = gNodes[node].getLeds()
    if bitn < 3:
        if value < 2: # Set/Unset
            newVal = ( (~(1<<bitn) & 7) & oldVal) | (value<<bitn)
        else: # Toggle
            if ((1<<bitn) & oldVal) == 0:
                newVal = oldVal | (1<<bitn)
            else:
                newVal = ( (~(1<<bitn) & 7) & oldVal)
    else:
        newVal = value
    if gNodes[node]:
        gNodes[node].setLeds(newVal & 7)    
    
def radio(node,param,p2):
    if gNodes[node]:
        if (param < 65535):
            if (abs(param/10 - node/10) < 2) and (abs(param%10 - node%10) < 2):
                gNodes[node].radioSendTo(param);
            else:
               gNodes[node].radioSendFar();
        else:
            gNodes[node].radioSendAll();
    
def sensor(node,param,p2):
    if gNodes[node]:
        gNodes[node].sensor(param)

def serial(node,param,p2):
    if gNodes[node]:
        gNodes[node].serial(param)    

def error(node,param,p2):
    if gNodes[node]:
        gNodes[node].error(param)    
    
def update(ScreenSize):
    global screen
    global background
    global globalFont
    screen = pygame.display.set_mode(ScreenSize,HWSURFACE | DOUBLEBUF | RESIZABLE)
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill(BACKGROUND)
    screen.blit(background, (0, 0))
    globalFont = pygame.font.SysFont("dejavusans", 7*zoom)
    pygame.display.flip()
    text = globalFont.render(" {}s of {}s [zoom: x{}] ".format(globalClock/1000,runTime,zoom), 1, BLACK,BACKGROUND)
    textpos = text.get_rect(x=10)
    screen.blit(text, textpos)
    pygame.display.update()
    for index in range(len(gNodes)):
        if gNodes[index]!=0 :
            gNodes[index].update()


def writeSData():
    buff = pack('300H',*sData)
    fData = open('sensors.bin', "wb")
    fData.write(buff)
    fData.close()

def readSData():
    global sData
    fData = open('sensors.bin', "rb")
    buff = fData.read(600)
    sData = unpack('300H',buff)
    fData.close()

def mouseClick(button,pos):
    global sData
    nodeId = ((pos[0]/nodeDist)*10 + (pos[1]/nodeDist)+1)
    if nodeId<100 and gNodes[nodeId]!=0 :
        nodeXY = gNodes[nodeId].getXY()
        dx = (pos[0] - nodeXY[0])/zoom
        dy = (pos[1] - nodeXY[1])/zoom
        sId=0
        if (dx>=10 and dx <=_nodeSize) and (dy>=1 and dy <= 11):
            if (dy>=1 and dy <= 3):
                sId = 3
            elif (dy>=5 and dy <= 7):
                sId = 2
            elif (dy>=9 and dy <= 11):
                sId = 1
        if (sId>0):
            step = 0
            if (button==(1,0,0)):
                step = 10
            if (button==(0,0,1)):
                step = -10
            lData = list(sData)
            lData[(nodeId*3)+sId-1]=lData[(nodeId*3)+sId-1]+step
            if lData[(nodeId*3)+sId-1] < 0:
                lData[(nodeId*3)+sId-1] = 0
            if lData[(nodeId*3)+sId-1] > 0x03ff:
                lData[(nodeId*3)+sId-1] = 0x03ff
            sData = tuple(lData)
            gNodes[nodeId].sensorValue(sId)
            writeSData()
    

#print "BEGIN --------------------------------------------"

#inCMD = open("./TViewer.txt",'r')
inCMD = sys.stdin
hasDisplay=False

while 1:
    status = select.select([inCMD], [], [], 0.01)[0]
    if (status):
      line = inCMD.readline()
      if len(line)>0:
        if screen:
            pygame.event.pump()
        a1 = re.split('<<:',line)
        if len(a1)>1:
            a2 = re.split(':>>',a1[1])
            cmd = re.split('\s+',a2[0].strip())
            #print cmd
            procCMD(cmd[0],cmd[1],cmd[2],cmd[3])
    else:
      if (hasDisplay):
        event = pygame.event.poll()
        if (event.type == pygame.MOUSEBUTTONDOWN):
            mouseClick(pygame.mouse.get_pressed(),pygame.mouse.get_pos())
        elif event.type == pygame.QUIT:
            exit(0)
        elif event.type == VIDEORESIZE:
            xw,xh = event.size
            zoom = calcZoom(xw,xh)
            #print "new zoom=",zoom, xw,xh
            update((xw,xh))


#print "END --------------------------------------------"

