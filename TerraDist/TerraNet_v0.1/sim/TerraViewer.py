#!/usr/bin/python

import sys
import pygame
from pygame.locals import *
from collections import deque
import re

BLACK = (  0,   0,   0)
WHITE = (255, 255, 255)
BLUE =  (  100,   100, 200)
BLUE2 = (  0,   0, 200)
GREEN = (  50, 205,  50)
RED =   (255,   0,   0)
YELOW = (255,   215, 0)
#BACKGROUND = (250, 250, 250)
BACKGROUND = (255, 250, 250)
GRAY = (190, 190, 190)
PINK = (255,20,147)
BROWN = (139,90,43)

nodeSize = 30
nodeDist = 80
offset = nodeDist/2
eraseTime = 300

gNodes=[0 for x in xrange(100)]
eraseQueue = deque()
screen = 0 # Global screen
globalClock = 0
globalFont = 0
background = 0

class gNode:
    def __init__(self,id):
        self.x = int(id/10)
        self.y = id%10
        self.xx = nodeDist*self.x + offset
        self.yy = nodeDist*self.y
        self.id = id
        self.idStr = str(id)
        rect = [self.xx ,self.yy,nodeSize,nodeSize]
        self.node = pygame.draw.rect(screen,BLUE,rect,1)
        self.font = pygame.font.SysFont("dejavusans", 14)
        self.text = self.font.render(self.idStr, 1, GRAY)
        screen.blit(self.text, [self.xx+4,self.yy+4])
        self.LedsValue=0
        self.setLeds(self.LedsValue)
        pygame.display.update(rect)
    def stop(self):
        pygame.draw.rect(screen,BACKGROUND,self.node,0)
        pygame.display.update(self.node)
    def vmstart(self):
        self.text = self.font.render(self.idStr, 1, BLACK, BACKGROUND)
        screen.blit(self.text, [self.xx+4,self.yy+4])
        pygame.display.update(self.node)
    def vmstop(self):
        self.text = self.font.render(self.idStr, 1, GRAY, BACKGROUND)
        screen.blit(self.text, [self.xx+4,self.yy+4])
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
            self.color1,self.fill1 = (YELOW,0)
        if (self.LedsValue & 4):
            self.color2,self.fill2 = (GREEN,0)
        self.led0 = pygame.draw.circle(screen,BACKGROUND,[self.xx+6,self.yy+nodeSize-6],3,0)
        self.led1 = pygame.draw.circle(screen,BACKGROUND,[self.xx+12,self.yy+nodeSize-6],3,0)
        self.led2 = pygame.draw.circle(screen,BACKGROUND,[self.xx+18,self.yy+nodeSize-6],3,0)
        self.led0 = pygame.draw.circle(screen,self.color0,[self.xx+6,self.yy+nodeSize-6],3,self.fill0)
        self.led1 = pygame.draw.circle(screen,self.color1,[self.xx+12,self.yy+nodeSize-6],3,self.fill1)
        self.led2 = pygame.draw.circle(screen,self.color2,[self.xx+18,self.yy+nodeSize-6],3,self.fill2)
        pygame.display.update([self.xx,self.yy-9,self.xx+3,self.yy-6])
    def getLinePoints(self,target):
        targetx = int(target/10);
        targety = target%10;
        if (self.y == targety):
            startx = self.xx + (targetx-self.x+1)*(nodeSize/2) + (targetx-self.x)*1
            stop1x  = self.xx + (targetx-self.x+1)*(nodeSize/2) + (targetx-self.x)*nodeDist - (targetx-self.x)*(nodeSize) - (targetx-self.x)*1
            starty = self.yy + (nodeSize/2) + (targetx-self.x)*2
            stop1y = self.yy + (nodeSize/2) + (targetx-self.x)*2
            stop2x = stop1x - (targetx-self.x)*4
            stop2y = stop1y + (targetx-self.x)*4
        else:
            startx = self.xx + (nodeSize/2) + (targety-self.y)*2
            stop1x  = self.xx + (nodeSize/2) + (targety-self.y)*2
            starty = self.yy + (targety-self.y+1)*(nodeSize/2) + (targety-self.y)*1
            stop1y  = self.yy + (targety-self.y+1)*(nodeSize/2) + (targety-self.y)*nodeDist - (targety-self.y)*(nodeSize) - (targety-self.y)*1
            stop2x = stop1x + (targety-self.y)*4
            stop2y = stop1y - (targety-self.y)*4
        return [[startx,starty],[stop1x,stop1y],[stop2x,stop2y]]
    def radioSendTo(self,target):
        points = self.getLinePoints(target)
        pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
        eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
    def radioSendAll(self):
        if self.id%10 > 1:
            points = self.getLinePoints(self.id-1)
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id/10 > 1 or self.id==11:
            points = self.getLinePoints(self.id-10)
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id%10 < 9:
            points = self.getLinePoints(self.id+1)
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
        if self.id/10 < 9:
            points = self.getLinePoints(self.id+10)
            pygame.display.update(pygame.draw.lines(screen,BLUE,False,points,1))
            eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
    def sensor(self,stype):
        if stype == 1:
            color = RED
            p1 = [self.xx+nodeSize-5,self.yy+nodeSize-4]
            p2 = [self.xx+nodeSize-2,self.yy+nodeSize-4]
            p3 = [self.xx+nodeSize-2,self.yy+nodeSize-5]
            p4 = [self.xx+nodeSize-5,self.yy+nodeSize-5]
        elif stype == 2:
            color = GREEN
            p1 = [self.xx+nodeSize-5,self.yy+nodeSize-6]
            p2 = [self.xx+nodeSize-2,self.yy+nodeSize-6]
            p3 = [self.xx+nodeSize-2,self.yy+nodeSize-7]
            p4 = [self.xx+nodeSize-5,self.yy+nodeSize-7]
        else:
            color = BLACK
            p1 = [self.xx+nodeSize-5,self.yy+nodeSize-8]
            p2 = [self.xx+nodeSize-2,self.yy+nodeSize-8]
            p3 = [self.xx+nodeSize-2,self.yy+nodeSize-9]
            p4 = [self.xx+nodeSize-5,self.yy+nodeSize-9]
        points = [p1,p2,p3,p4,p1]
        pygame.display.update(pygame.draw.lines(screen,color,False,points,1))
        eraseQueue.append((pygame.time.get_ticks()+eraseTime,points))
  
if not pygame.font: print 'Warning, fonts disabled'
if not pygame.mixer: print 'Warning, sound disabled'

##################
#
# Terra View commnad definition
#
# "<<: clock 0 12344 :>>"
# "<<: init col lines :>>"
# "<<: end 0 0 :>>"
# "<<: start 11 :>>"
# "<<: stop 11 :>>"
# "<<: leds 11 3 :>>"
# "<<: radio 11 21 :>>"
# "<<: radio 11 65535 :>>"
# "<<: sensor 11 temp :>>"
# "<<: sensor 11 photo :>>"
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
      'sensor': sensor
    }[cmd](int(node),int(p1),int(p2))

def clock(node,param,p2):
    global globalClock
    pygame.event.pump()
    globalClock = param
    if globalClock%1000 == 0:
        text = globalFont.render(" {}s ".format(globalClock/1000), 1, BLACK,BACKGROUND)
        textpos = text.get_rect(centerx=background.get_width()-text.get_width()-10)
        screen.blit(text, textpos)
        pygame.display.update()
    while ((len(eraseQueue)> 0) and (pygame.time.get_ticks() > eraseQueue[0][0])):
        time,points = eraseQueue.popleft()
        pygame.display.update(pygame.draw.lines(screen,BACKGROUND,False,points,1))
    
def init(node,param,p2):
    global screen
    global globalFont
    global background
    pygame.init()
    ScreenSize = ((node+1)*nodeDist+offset,(param+1)*nodeDist)
    screen = pygame.display.set_mode(ScreenSize)
    pygame.display.set_caption('Terra Simulation Viewer')
    pygame.mouse.set_visible(1)
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill(BACKGROUND)
    globalFont = pygame.font.SysFont("dejavusans", 14)
    screen.blit(background, (0, 0))
    pygame.display.flip()

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
            newVal = (~(1<<bitn) & oldVal) | (value<<bitn)
        else:
            if ((1<<bitn) & oldVal) == 0:
                newVal = (~(1<<bitn) & oldVal) | (1<<bitn)
            else:
                newVal = (~(1<<bitn) & oldVal)
    else:
        newVal = value
    if gNodes[node]:
        gNodes[node].setLeds(newVal)    
    
def radio(node,param,p2):
    if gNodes[node]:
        if (param < 65535):
            gNodes[node].radioSendTo(param);
        else:
            gNodes[node].radioSendAll();
    
def sensor(node,param,p2):
    if gNodes[node]:
        gNodes[node].sensor(param)
    


#print "BEGIN --------------------------------------------"

#inCMD = open("./TViewer.txt",'r')
inCMD = sys.stdin

while 1:
    line = inCMD.readline()
    if len(line)>0:
        a1 = re.split('<<:',line)
        if len(a1)>1:
            a2 = re.split(':>>',a1[1])
            cmd = re.split('\s+',a2[0].strip())
            #print cmd
            procCMD(cmd[0],cmd[1],cmd[2],cmd[3])


#print "END --------------------------------------------"





