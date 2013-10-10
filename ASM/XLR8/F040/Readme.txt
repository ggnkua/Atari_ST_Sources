TOS 404 is an Atari Falcon 030 emulation project. It is started
by Frans van Nispen (xlr8@tref.nl) and it is now available at
TOPP - The Orphaned Projects Page (http://topp.atari-users.net)


The files:

bios.asm		The bios, xbios and gemdos routines
blitter.asm		Emulates the Falcon Blitter
dsp_host.asm	The interface with the DSP
F030.asm		The start file. It runs the debugger which starts
				emulation by pressing F5.
FALCON.TOS		The tos image of the Falcon TOS. This file may only
				be used if you actualy have a Falcon yourself, as
				it is copyrighted by Atari.
gfx.inc			Some macro's to be used in gfx coding.
hardware.asm	The actual emulator which gets started by F5 and
				can be left by ~. F4 shows the current screenshot.
io.asm			The central emulation of all hardware. All IC's get
				included from there.
keyboard.asm	The ACIA's. Not finished. Now you need to press 1 when
				the desktop arrives to start the keyboard emulation.
				For some reason it scrashes otherwise.
l.bat / ll.bat	These are batch-files used to edit and compile
screen.asm		The Video processor emulation. uses MMX !!!!
shifter.asm		The hardware interfacing to the shifter.
shifttab.inc	These two files are conversion tables for 4 bpp and
shifttb2.inv	2bpp to 8bpp.
std.inc			Some standard macro's
vbl.asm			All things to be done on vertical blanking.
vesa2.inc		A Vesa2 interface library.
X.bat			A quick-start batch to test.

All files may be used and modified to your own needs. Only thing I want
in return is credits.

Frans van Nispen,
xlr8@tref.nl,
leden.tref.nl/~xlr00000,
www.Blackend-Software.com
