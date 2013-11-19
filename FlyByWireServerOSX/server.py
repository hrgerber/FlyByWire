#
#  server.py
#  FlyByWire
#
#  Created by abductive on 2013/11/19.
#  Copyright (c) 2013 Retief Gerber. All rights reserved.
#

from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

from Quartz.CoreGraphics import CGEventCreateMouseEvent,CGEventPost,kCGEventMouseMoved,kCGEventLeftMouseDown,kCGEventLeftMouseUp,kCGMouseButtonLeft, kCGHIDEventTap

def mouseEvent(type, posx, posy):
        theEvent = CGEventCreateMouseEvent(
                    None, 
                    type, 
                    (posx,posy), 
                    kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, theEvent)

def mousemove(posx,posy):
        mouseEvent(kCGEventMouseMoved, posx,posy);

def mouseclick(posx,posy):
        # uncomment this line if you want to force the mouse 
        # to MOVE to the click location first (I found it was not necessary).
        #mouseEvent(kCGEventMouseMoved, posx,posy);
        mouseEvent(kCGEventLeftMouseDown, posx,posy);
        mouseEvent(kCGEventLeftMouseUp, posx,posy);

class IphoneRemoteServer(Protocol):
    def connectionMade(self):
        print "Client Connected", self
        self.factory.clients.append(self)
 
    def connectionLost(self, reason):
        print "Client Disconnected", self
        self.factory.clients.remove(self)
 
    def dataReceived(self, data):
        print data
        items = data.split(":")
        if len(items) == 4:
            (event, etype, x, y) = items
            xs = float(x)/480*1900
            ys = float(y)/320*1080
            mousemove(xs,ys)



if __name__ == "__main__":
    factory = Factory()
    factory.protocol = IphoneRemoteServer
    factory.clients = []
    reactor.listenTCP(8000, factory)
    print "FlyByWireServer running"
    reactor.run()  
