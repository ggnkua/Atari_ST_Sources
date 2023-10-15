6-4-2023

           Instant Graphics! Online Graphics Script Interpreter
                   Copyright 1988-2023 by Larry Mears
                 Version 2.19 by Larry Mears, Freeware

 
    IGDEV12 with IG219 engine, IG219.ACC and IG219.EMU for Interlink 
                       by Larry Mears, Freeware

	Note: You may find a list of Atari BBSs here:
	www.sfhqbbs.org/ataribbslist.php
	or maybe here in the future: ataribbs.com


IMPORTANT USE WITH HSMODA07.ZIP set up 32K serial buffer the ST's 
default serial buffer is only 256 bytes I believe, not near enough!!
This will all work fine offline but not good at all online without a bigger
serial buffer.  Interlink can do it's on serial buffer up to 31K and
Interlink does not work with HSMOD.

Here's the link I got mine from...
https://sites.google.com/site/stessential/home/all-software

IG219.ACC needs it too unless it is ran along with Interlink
You set it up in the AUTO folder,
also in the AUTO folder you may want to put (included) KRX.PRG or KX.PRG these
cut off the KEY click sound and KEY repeat when a key is held down these can
effect the IGDEV program's TAP A TUNE function.  RX.PRG just cuts off repeat.

WHAT'S NEW? 
  After working on this Retro project for 3+ years in what spare
time I could manage I created a IG terminal and Drawing program smash
up for developing IG scripts then ASCII uploading them. I also updated the
ACC & EMU versions. **I'd like to note that the "I" command did NOT do a 
restorative resolution switch.  I went back as far as IG210 and checked the
source code the older manual says it does a RES switch but it did NOT.  It did
everything else but not RES switch.  I added a I 5 option just for that,
seems like a good idea.  I recently discovered that the VDI Compatible
Resolution Switch by Steve Cole and Lawrence Gold if executed before setting
the color palette will mess with VT52 text color, so ALWAYS do a resolution
switch FIRST then set the palette.  Like G#I>5:I 0: otherwise you won't get the
colors you expect.  That was probably why I removed the RES switch from the
Init 0 and 1 commands to start with.  I knew it was a problem just didn't 
know why at the time.

***  IG219's  'G'rab command aka BitBlit is fixed so when IG switches from
medium resolution to LOW it doesn't ask GEM how many bit planes but checks
the resolution itself and sets the number of bit planes available so all BitBlit
commands should work after a res switch not just SCREEN to SCREEN. This was a
problem in IG218.  I also added a new BitBlit command Memory to Memory, lets you
do hidden Blits then pop them up.  No clipping so stay within the X,Y bounds.

IG219 BIGgest addition would be the the NEW f and z commands.  PolyFill the
f command draws a filled polygon with up to 128 sides. PolyLine the
z command draws a connected line with a minimum of 2 end points and
maximum 128 end points. Like the Line and Drawto IG commands but less IG script.

IG219 has a new X 10 command it sets the begining point for the  Drawto
command. Just a feature, not that critical, because the Line or Plot command
already set this as it should.  I also added to the R and I commands options
to SET the default VDI color palette and resolution. The IGDEV program has
added support for these additions.

I also added a full blown text editor ME.TTP,  IGDEV passes the draw buffer
to it as file so there is a decent text editor if you need to hand edit your IG
script. It writes a file called BUFF.IG then passes that to ME.TTP,  BUFF.IG is
wiped out every time it does that, but it might save you if you forgot to save
your IG script at exit, at least from that hand edit point.  The IGDEV program
uses the out lined cross hair now.  If you press the CONTROL key you get a 
drawing grid, multiple presses changes grid size.  LEFT SHIFT key prints
X,Y coordinates, mutiple presses changes position where X,Y is printed.
The draw grid and X,Y coordinates may appear on top off some of your drawing
but it is not permanate. 

IG218 has editable fill and line patterns, a new
timing command that uses Vsync, internal double stepping for XORing
with BitBlit, the Spray Paint command has color rotation, the random
constant has two ranges r and R, the input command now uses all
mouse pointers not just a polymarker.  I changed the IG default color
palette and tried to make resolution swapping better.  I added a new
option for the N command you can jump forward in the buffer, this allows
you to jump to several short chip tunes as needed.  There is new X 9 
command that loads and executes IG graphic commands in the IG MIDI buffer.
In the IGDEV10.PRG just HIT the F1 key to Draw and make Music.  The IGS
Editor Kevin Moody & Anthony Rau did not support Low Resolution limiting it
to 4 colors.  I really wanted it to support Low Resolution 16 color mode.
When I wrote BIG Paint(DOS), Condor PAINT(DOS), Vectasketch and
Sketchpad(JAVA applets) they all had many colors. IG needed that too.
Bugs?  Few and far between I hope but nobody is perfect.  I will fix them 
if I can.  Most of time the Drawer is doing exactly what you tell it to,
it's command driven not a pixel bit painter. YOU have to THINK about what
you do and do it in the proper order.
 

Included Files:
--------------

STSELECT.PRG Put in your AUTO folder 1st lets you select witch AUTO folder
			 and DESK ACCessory programs you want to run. written by
			 J. Weaver Jr  a must have utility.  Thank you Mr. Weaver

IGDEV12.PRG The IG219 draw program hit F1 to draw, comes up in dumb terminal
			but smart graphics mode.

DRAWTIPS.TXT Limited Help file on using IG Drawing program.

IG219.ACC	The IG219.ACC desk Accessory progam use Interlink
			or other termial program you like that sets up a big
			serial buffered port.

IG219L.ACC  The IG219L.ACC LIGHT version desk Accessory progam use
			Interlink other termial program you like that sets up a big
			serial buffered port.  IG219L.ACC has no file support
			and uses less memory.

IGS219.EMU	This loads into the INTERLINK terminal Hit F5 or select
			Style/Features EMULATION ?????? BUTTON to Load.

IG219.TXT	Lists of the IG commands and syntax.

GIST2IG2.PRG This utility program takes sound effects made with The GIST.PRG
			 that you save out as FILENAME.C and turns that into a loadable
			 IG format sound effect that can load into any of the 20 sound
			 effect slots 0-19 they can also be played as note commands.
			 GIST may be found on https://forums.atariage.com  
			 the Atari ST Programming forum also if they ever link to it
			 www.atarimania.com  LeeActor.com website the orginal programmer
			 of GIST worth a visit.

MS2IG.PRG	This a program by Walter Holding he released into the Public
			Domain that I modified.  Thank you Mr. Holding  It takes Activision
			Music Studio MIDI files and turns them into streamable BYTE files
			for the N command MIDI buffer.  It only works for MIDI not the
			sound chip.  I may write another for MIDI to sound chip conversion
			in 2023 sometime. Activision Music Studio can be found on
			www.atarimania.com  I also included MS2IG.BAS if you want to try
			making a MIDI to IG note converter yourself.  It's in a older
			version of GFA Basic. There are a couple of .SNG files to test with.
			I was going to do it in C since I found some C source in a book for
			doing most of this already in MegaMax C.

N_UTILB.PRG This takes song files made with the TAP A TUNE selection in the
			IGDEV10.PRG's DRAW section and turns them into BYTE streamable
			format for the 10K MIDI buffer.

KRX.PRG 	AUTO folder PROGAMS cuts off key click and key repeat
KX.PRG		cuts off key click only
RX.PRG		cuts off repeat only
			The key click and repeat can mess with the TAP A TUNE in the
			IGDEV10's DRAW F1 function.
			May be usful in other programs too.  I usually just leave the
			key click sound off all the time.

The .C files are sound effect files created with GIST.  The GIST2IG2.PRG
will convert them to IG format.  NEW_SNDS.TXT talks about this also.

The .GR1 and .IG files are IG graphic script examples.  They are old examples
and probably mostly created by hand.

This was all written with Laser C,  MegaMax C, and GFA Basic on the original
Atari STf  I bought in the 1980's with TOS 1.0  The only mods it has is a
dual TOS, flip a switch it goes from TOS 1.0 to TOS 1.04 and the TT Touch for
the keyboard.  I also used the UltraSatan II with ICD Pro 655a driver with
TOS 1.0 for developing the software.  For moving the programs to a .ST
simulated floppy TOS 1.04 and Peter Putnik's HD driver.  I have a NETUSB too
which is great for moving files in ZIPs ARCs and LZHs to from a PC.
I tried to address everthing thing I could think of to improve IG and keep it
backwards compatible.  I started working on this late 2019 here it is middle
of 2023.  I had some fun writing it, other times it was just hard.  
I hope you enjoy it.
 

