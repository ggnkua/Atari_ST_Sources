oAESis: A free multitasking application environment running under 
MiNT.

Copyright 1995,1996 Christer Gustavsson.

The oAESis source code and binaries are provided free of charge, as is. 
No warranties are given for oAESis. You may use it on your own risk. 
Redistribution of oAESis for profit, or use of it in any product, requires 
a license from the authors.
---------------------------------------------------------------------------- 

Version 0.5, January 31st 1996.

Finally a binary version of oAESis is available! It is, however, not 
completely compatible with MultiTOS yet since some calls are missing and 
others not complete. Some programs can be used with oAESis 0.5: Pure C 
(when it actually starts, that is), QED (I'm writing this text with it 
running under oAESis :-)) and lines.prg (!) to mention a few.

Version 0.6, March 3rd 1996.

Pure C now runs like a charm! I found the deadlock bug in the menu_bar
implementation that made the system hang now and then. More programs
can be run: Diamond Edge, Everest, Talking Clock, Calappt, Toswin, CAB,
xcontrol (as an application. Hi Craig :-).) and Gemini.

Version 0.61

Configuration file parser added. The syntax of oaesis.cnf is the same as
gem.cnf. A lot of the menu handling have been moved to evnthndl.c to speed
things up.

Version 0.62, March 24th 1996.

More applications run; Thing etc. Added debug option to configuration file;
By default debug messages are printed to /dev/stderr, but with the command:
DEBUG = <device> the output can be redirected. If you want to use modem2 as
your debug device just write DEBUG = /dev/modem2 in oaesis.cnf.

Version 0.7, April 22nd 1996.

Some memory bugs corrected => better stability. Programs like Superbase
personal II, Interface II (finally), Qed 3.60, Mgif 5.01, BootConf 1.20,
BootXS, STZip, ESSCode, DevPac, Lattice C, Atari Works, ST-Guide, STello,
GemBench, LZHshell and Xedit run now.
Accessories are now started at boot time.

Version 0.71, April 28th 1996.

MasterBrowse and Yukon works.
Fixed bug in Rdwrs_rel_sem() that caused freezing problems.
Change of window colours when topping/bottoming hopefully works
correctly now.
Changed behaviour of form_dial() to make "dirty" written programs work
a little better.

Version 0.72, May 1st 1996

Prgflags now works.
Fixed so that sliders are only redrawn if they were actually changed.
This makes things look and feel smoother. I also ditched the DrawWind
process, and and and... it turned out to be a real hit! oAESis + NVDI
feels really good. It's a pity I can't boot oAESis with NVDI on my
VGA monitor :-/. The WM_REDRAW message sending has been looked over and
improved to minimize the number of messages sent.
New in oaesis.cnf is AE_REALMOVE and AE_REALSIZE. These AES variables
tell oAESis whether to allow realtime resizing and moving of windows.
See the oaesis.cnf example file for more info. Planned is AE_REALSCROLL
to allow realtime scrolling of windows.

Version 0.73, May 8th 1996

Added code for realtime scrolling of windows (jps). AE_REALSLIDE in
oaesis.cnf is used for this purpose. Added clip test to draw_object()
in objc.c => much quicker redraws in, for instance, Thing.

Version 0.74, May 19th 1996

Changed objc_draw() so that Papyrus works.
Added CTRL + ALT + TAB application switching.
Iconification of windows and applications (CTRL-click) supported.
Added application name on window mover.

Version 0.75

Wind_update(BEG_UPDATE) problem solved => Ecopy works better.
Semaphore and pipe names changed to allow oAESis to run under
oAESis => Development of oAESis is now possible under oAESis!
v_opnwk() under NVDI doesn't seem to save the registers it should =>
the VDI handle address was overwritten. The option -R on global.c
seems to solve the problem temporarily.

Version 0.76

If you manually edit the path in the fileselector and press RETURN the
list is updated instead of returning from the call.
The option AE_APPL_WIND in oaesis.cnf is used to turn the application
name on window movers on/off.


Installation.

oAESis can be started from the desktop simply by double clicking on 
oaesis.prg, or from mint.cnf. To use the latter you should add the 
following to your mint.cnf (assuming oaesis.prg is in the root of your 
c:-drive):

INIT=c:\oaesis.prg -physical


Distribution.

The latest version of oAESis can always be found at the following 
www address:

http://www.dtek.chalmers.se/~d2cg/oaesis/

If you don't have access to www but to ftp you could try:
ftp://ftp.dd.chalmers.se/pub/lars/nocrew/
---
Christer Gustavsson (d2cg@dtek.chalmers.se)

