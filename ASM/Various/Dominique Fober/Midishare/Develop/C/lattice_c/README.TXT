Read Me for MidiShare files for Lattice C V5.60 on the Atari
============================================================

The msh_unit.h file defines the MidiShare functions for Lattice C V5.60 
on the Atari. It is typically placed in the \lc\header folder.

lib_lc.lib may be placed with your other libraries. It provides a single
function Midishare(), which returns TRUE if MidiShare is installed, FALSE
if not. To conform with the other MidiShare implementations, it should
be renamed LIBMIDI.LIB.

If you recompile lib_lc.c for any reason, then ensure that stack checking 
is turned off, or you won't even be able to enter the function because it
makes a call in Supervisor mode!

All other MidiShare functions are defined in msh_unit.h using the inline 
pragma. Hence all functions are declared as assembler.

(Note that the Lattice documentation doesn't make very clear that the inline
pragma will only allow the 'short' cast to be used. All other types default 
to their natural length, typically long. If you try to use any other cast, 
such as (long) or (void *), then errors are generated.)

These files will only work with Lattice C V5.60 and upwards, because ANSI
prototyping is important to them, and the inline pragma is required.

MidiShare demands that all parameters are passed in traditional C manner, 
i.e. on the stack. It also demands that shorts are passed as shorts.

By default, Lattice C does pass parameters on the stack, but casts every
type to long (at least). Hence it is necessary to set a couple of flags in 
the project file: -aw forces type based stack alignment. This is required
because the 'short' prototypes will be ignored without it. -aw might be 
sufficient for some programs, but functions that receive data from MidiShare
reach into buffers defined in MidiShare data space, so -b0 must also be
set, which defaults 'far' data. It does not seem necessary or wise to
default 'far' code also. These options are set under the 
Options:Compiler:Object menu.

-rs can also be used to guarantee stack parameters. This is set under 
Options:Compiler:General.

See the tutorial.prj file for an example of setting these flags.

A define is provided in msh_unit.h of 'cdecl', which is from Turbo C, and 
defined as '__stdargs'. This forces standard stack argument passing, and it
is good documentation practice to use this for Alarm functions.

On a technical note, it might seem that rather than default all data to far 
pointers, then careful declarations would overcome this. I have tried this
and failed! If you get it to work then let me know!

The biggest problem with developing MidiShare applications under Lattice C
as supplied by HiSoft is the MON debugger. This is normally a fine debugger,
but MidiShare is called via TRAP #5 (there is an alternative that is not
used here via TRAP #6). MON is hard coded to only allow TRAP 1, 13, and 14
which are the standard Atari traps. Hence MidiShare code will fail as soon
as calls are made to MidiShare. There is no work-round for this. Perhaps
if we all complain to HiSoft loudly enough...

On a better note, MidiShare runs happily alongside MagiC and NVDI.


My special thanks to Dominique Fober of GRAME for his assistance in this 
project.

Enjoy MidiShare!!!!

( () |_ | |\| whyles
whylesc@btlip03.bt.co.uk
49 Exeter Road, Felixstowe, Suffolk, IP11 9AT, UK

01jun95
