To compile any of the programs included on this disk, you will need
the following program files from the developer's toolkit:

cp68.prg
c068.prg
c168.prg
as68.prg
link68.prg
relmod.prg

To use the batch files included in each folder, you will need these
programs as well:

batch.prg
rm.prg
wait.prg

In each program's folder you will find one or possibly two .BAT
files.  If every necessary file is on the default drive, each
program can be compiled and linked by running batch.prg with
this .BAT file as the parameter.

Although not every program requires these header files to compile,
following is an exhaustive list of every system header file used
by every program included on this disk.  By "system header file"
we mean header files provided with the developer's toolkit, and not
any header files a programmer may have created for the specific
program.

portab.h       - definitions intended to assist in writing portable code
machine.h      - intended to assist in porting between 8086 and 68000
gembind.h      - GEM procedure bindings and other likely GEM things
gemdefs.h      - just other likely GEM things
obdefs.h       - GEM object definitions
osbind.h       - definitions useful for using osbind.o
vdibind.h      - extern declarations for GEM VDI procedure calls
taddr.h        - another way to get to the GEM object structure

See the particular program's listing to determine what specific
system header files it will need on the compile disk.

Although not every program requires these link files (by which we
mean object and library files necessary to link) following is an
exhaustive list of every link file necessary to produce any program
included on this disk:

accstart.o     - accessory program startup
apstart.o      - application program startup
osbind.o       - calls for Atari TOS and bios traps
libf           - floating point library
vdibind        - GEM VDI call bindings
aesbind        - GEM AES call bindings

See the batch files for a list of the specific link files necessary
for a particular program.

Note that some of these programs use separate resource files.  In
some cases, the resource file C sources are included.  In all cases,
at least the .RSC file itself is included.

Creating a .RSC file from the sources is a difficult thing to do.
We suggest you use DRI's resource editor (on the sources, of course)
if you want to change any of these separate resources.

All of these programs work with Alcyon C, the compiler provided with
the programmer's toolkit.  Many of them were developed using
Megamax C.  Most if not all of them will port directly to Megamax.

