#
#  server.py
#  FlyByWire
#
#  Created by abductive on 2013/11/19.
#  Copyright (c) 2013 Retief Gerber. All rights reserved.
#
from time import sleep

from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

from Quartz.CoreGraphics import CGEventCreateMouseEvent,CGEventPost,kCGEventMouseMoved,kCGEventLeftMouseDown,kCGEventLeftMouseUp,kCGMouseButtonLeft, kCGHIDEventTap
from AppKit import NSScreen

screen_frame = NSScreen.mainScreen().frame()

screen_width = screen_frame.size.width
screen_height = screen_frame.size.height

print "Host screen size", screen_width, screen_height

touch_width = object()
touch_height = object()

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
        items = data.split(":")
        if len(items) == 3:
        	global touch_width, touch_height
        	(bounds, touch_width, touch_height) = items
        	if (bounds == "bounds"):
				print 'Touch Bounds', touch_width, touch_height 
				sleep(1)
				self.transport.write("configured")

        if len(items) == 4:
            (event, etype, x, y) = items
            if (event == "touch"):
            	global screen_width, screen_height
            	xs = float(x)/float(touch_width)*screen_width
            	ys = float(y)/float(touch_height)*screen_height
            	print "Mouse position", int(xs), int(ys)
            	mousemove(xs,ys)



if __name__ == "__main__":
    factory = Factory()
    factory.protocol = IphoneRemoteServer
    factory.clients = []
    reactor.listenTCP(8000, factory)
    print "FlyByWireServer running"
    reactor.run()  
