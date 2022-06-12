FalconSystem v5
 by Orion_ [2009 - 2013]

Videl routine by Anders Eriksson from DHS
C2P routine by Mikael Kalms from TBL, Improved by MiKRO
IKBD routine by Patrice Mandin
DSP MP2 Audio Player by Tomas Berndtsson, NoBrain/NoCrew


This is a general Demo/Game System Library for the Falcon 030/060.
The library was designed to compile with VBCC.
Download my windows distribution of VBCC here:
http://onorisoft.free.fr/atari/falcon.htm

Features:
-320x240 in 8bits and 16bits mode.
-640x480 in 8bits mode.
-Double Buffering.
-Triple Buffering. (allow faster processing without the need to wait for the VBL)
-CT60 mode (using work screen in FastRam)
-Chunky to Planar automatic conversion (in 8bits and CT60 mode)
-Emulator mode (for CT60 program but without setting 060 cache & superscalar to avoid emulator crash)
-Mouse and Keyboard processing. (custom IKBD routine)
-'Exit on space key' flag.
-Custom VBL user function pointer. (ex: for custom sound mixer)
-An Additionnal MP2 player C wrapper.


Add falcsys.c and falcsysa.s to your compilation command.
Add mp2.c and mp2.s to your compilation command if you use the MP2 player.

There are a bunch of indication on how to use the library in falcsys.h
But to make it easier to understand I made a little demo showing how to use the different parts of the library, see main.c


Tested on a real Falcon 030/CT60, Hatari, and Aranym.
The mouse and keyboard routine won't work on Aranym. (?)

Any bug report or improving appreciated :)
