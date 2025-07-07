CBZONE
======

Version .02 for the Atari.

This is a B*TTL*Z*NE type game originally written in Fortran. At some point
it was converted to C using X-Windows as its output form. The executable in
this archive is a port to the Atari ST of this version, substituting GEM for
the X-Windows.

This is my second release version for the Atari and has several bug fixes
and improvements over the first (9/10/93) release.

Requirements
============

This archive should contain the following necessary file:

CBZONE.PRG
CBZONE.RSC
CBZONE.MOT
CBZONE.HEL
README.ST

ST Hi-Res (640x400) compatible screen display although other even higher
resolutions should also work.

It should run in 512K of RAM, but has not been tested.

It also requires a lot of processor power. At 16Mhz with NVDI its still a
bit sluggish! A maths co-processor chip should make it run faster, but I have
been unable to test this. I also haven't been able to test it on a Falcon or
TT, but see no reason why it should not work (although turning the sound off
(-quiet) might help if it doesn't!).

The generic source code is easily available from many X-Window PD archives.
The ST modified version (which should also still compile to X-Windows) should
be available from the same place as this (CBSRC02.ZIP). If anybody is
thinking of compiling an X Windows Version then I can supply the original
source code I have worked from.

This particular executable was compiled with Lattice C 5.5.2. This compiler
produces smaller (and hopefully faster) code than the GCC which was used
for the first Atari version. This current version also has support for
maths co-processors compiled in.


To Play
=======

Just double click on the cbzone icon. This automatically starts playing an
'original' game - complete with all the features of the arcade one.

Moving the mouse moves the tank. Either of the mouse buttons fire a salvo.

There are also many other options available. To use them install the icon
as a 'GEM takes Parameters' with the program's directory as the default
directory - as opposed to the 'top window' (Not possible on all versions of 
the Desktop).

If your Desktop can't cope with this - then running cbzone from a command
line shell should work as well.
eg

gem cbzone.prg <parameters..>

Assuming your Desktop can cope - when double clicking on the icon, you will
be prompted for some parameters. Some common ones are:

-original		This is the same as no parameters as all
-salvos			How many shot can be fired at once
-tanks			How many tanks at the same time
-missiles		How many missiles at same time
-quiet			Turns the sound off

A new -fast mode has been added. This simplifies the game graphics slightly
giving a 20%-40% speed increase depending on how many objects are on the
screen. Otherwise it is just like the -original parameter (ie nothing). Also
various optimisations have been made anyway so even without the -fast option
the game is faster than the first release.

Also renaming CBZONE.PRG to CBZONEF.PRG will automatically turn on the -fast
mode. (in fact *any* file named CBZONEF.PRG in the same directory will enable
this feature).

For super fast play try:

-tanks 1 -salvos 1 -fast

This is only a practice mode though.

There are many more (untested) parameters listed in the file:

CBZONE.HEL

Note: Any option other than -original (or -fast) puts the game into
practice mode.

Note: The part in CBZONE.HEL about XResources is completly untested.
It may well work however.


CHANGE CONTROL (Atari Version)
==============================

First Version (unumbered) 9/10/93
---------------------------------
Basic GCC compiled port.

Version 0.1 (Unreleased)
------------------------
Several minor bugs fixed.
Basic GCC/Lattice compiled port.

Version 0.2 29/12/93
--------------------
Many minor bugs fixed.
Many internal optimisations made
Spot effect sound added.
Proper highscore dialogue added.
Pause fixed.
Maths Co-processor support added.
Fast mode added (-fast).
-help,-scores,-version now all do something useful.

FINAL NOTE
==========
This is still a rough port of CBZONE. There are still many things which could
be improved. NO WARRENTY IS IMPLIED OR EXPRESSED - however I will continue
to try and tidy up this version.

Also any ideas for improving it will be gladly received. I am mainly
interested in ideas to improve the speed and to make it more compatible with
different specs of machine. However as I did not actually write the game
improvements to the gameplay are probably beyond me :-(

Roland Givan 29/12/93

Email:
rgivan@cix.compulink.co.uk

Snail Mail:
Roland Givan
6 Salmonds Grove
Ingrave
BRENTWOOD
Essex
CM13 3RS
