     The 68000 programmer's introduction to demo techniques

Welcome!   In this series of documents,  I shall be attempting to 
explain some of the aspects that go into demo coding  today.   It 
is by no means complete (800K doesn't hold all that much), but it 
should definately be a good grounding for future work.

Some of the topics explained are:
     Scrolling messages
     Sine-wave wobblers
     Getting rid of borders (top, bottom, left and right!)
     Timers
     Playing samples (STFM and STe)
     Chip music
     Those bars that go up and down to chip music like a stereo
     Moving sprites around
     Sprites which leave an infinite "trail"

and, of course, there is the source code for my FULL-SCREEN demo.  
You  should  be  able  to replicate it  after  reading  just  the 
documents on scroll-lines and chip music,  but I wouldn't attempt 
it unless you are 100% sure that you know everything!


By the way,  I am assuming that you have been coding in 68000 for 
some time.   If you want to learn 68000, this is not the place to 
start.   Maybe you'll see some "learn 68000" docs in the  future, 
depending on the response to these docs.

You must,  of course, have a decent assembler.  I would recommend 
Devpac Version 3,  which I use myself - the ultimate tool!  Also, 
I  would recommend at LEAST 2 meg RAM and a hard disk if you  can 
afford one.  If not, then 2 meg of RAM with an 800K ram-disk will 
do the trick,  but will lead to slow boot-ups (my current system, 
and current nightmare).


THE $70 VECTOR
The  one  thing  you must understand to do  anything  with  these 
source codes is the way that the $70 vector works.   Skip this if 
you know it already.   At $70 there is a longword.  This longword 
is an address.   Every 50th of a second,  this address is  jumped 
to.  The ST uses it to keep counters and things like that.   Most 
of my routines will be hooked up at address $70.

Every 1/50th of a second, when the screen is just beginning to be 
drawn,  the  address  is  jumped to.   It is vital  to  save  any 
registers  that you use in your routine,  or you could crash  the 
computer.   Your  routine  should end not with  "rts",  but  with 
"rte".  It must not take longer than 1/50th of a second.

I put all my routines there because they should execute 50  times 
a second, so it is ideal for timing.


MISCELLANEOUS
None of these programs on disk will work with DCRIGHT,  because I 
disable the mouse,  and then re-enable it when I quit.   I  don't 
know  about any other mouse utilities - if you get a  crash,  try 
disabling  them.   QUICKST  and UIS_III work fine,  and  so  does 
PINHEAD.

These documents have been released into the Public  Domain.   You
may distribute them freely.

James Ingram, 1994


Post Script

In order to cram everything onto the disk, I have had to create 2 
archives.  These are self-extracting.  They are:
     \SCROLLER.001\SCOLLER.RUN
     \CHIP_MUS.005\CHIP_MUS.RUN

They contain the .DOC files and .S files for those  folders.   To 
get at them:
     copy the RUN file onto a blank disk
     rename it with the extension TOS
     run it

It will then decompress onto the blank disk.   You will need some 
of  the files in the INCLUDES directory in order to  compile  the 
source code,  so copy the INCLUDES directory to the blank disk as 
well.

I apologise for this,  but I had to do it to get everything  onto 
the  one disk;  I don't think you'd like it if I missed  anything 
off!

The  archives  were  created  using  the  SPEED  packer  by   the 
Firehawks.   They are smaller and much quicker than  STZip.   Why 
use anything except the SPEED packer???

The PRG files are also packed using the SPEED packer,  but I have 
had  to  write  a  program to patch them so  that  they  can  run 
directly  from the desktop,  so you can't decompress  them  using 
MEGA DEPACK or any other depacking program.  But you can just re-
assemble them from the source files!


ALSO ALSO ALSO ALSO ALSO ALSO ALSO ALSO ALSO ALSO ALSO ALSO ALSO

Also available from James Ingram:


RAM_LOAD
I have the game CIVILISATION.  I also have POPULOUS II.
I have got 2 Meg.

Why don't the programmers cater for me?  On both these games,
most of the needed files can be got from RAM instead of
re-loaded every time.

RAM_LOAD is born.

RAM_LOAD is a RAMDISK program.  But it is also much more.

You can set up a RAMDISK of any size using RAMLOAD.
You can make that RAMDISK reset-proof.
You can boot from the RAMDISK (not the bootsector, though)
You can also make the Atari load files directly from
the RAMDISK, no matter where the program asks for them from.

For example, if the program asks for:
        A:\PICS\JAMES.PI1
and the RAMDISK has a directory called PICS and a file in that
directory called JAMES.PI1, then the file will be loaded from the
RAMDISK automatically.

You can now load the files from the game disk onto the RAMDISK,
and play the game from RAM!

This is true, even for those games which frequently come in the
PD, which you spend 5 minutes copying to a RAMDISK, and run.
They then immeadiately access drive A, because they have been
written to only ever look on drive A.  With RAM_LOAD, they are
fooled into taking them from the RAMDISK!


Even if you have only 1 meg or so, you can create a small RAMDISK
and copy the most-often used files (if memory permits).

So that you don't have to do everything every time, RAM_LOAD contains 
a (fairly) powerful command language, with   over  30   commands, 
including  WHILE REPEAT and IF statements,  and an  ON-LINE  help 
facility!



You will also receive INTERCEPTOR.  This is a program which will
intercept files as they are loaded.  If they are packed using
        SPEED PACKER
        LZH (Jam Packer version)
        ICE (Jam Packer Version)

then they are de-packed in memory and treated as normal files.
There are SIMILAR programs, but INTERCEPTOR will allow you to
load PARTS of a file; you don't have to load it all in one go!
So you can load pictures into DEGELITE, for example, even if they
are packed!  It also works with RSC files!

You do need enough free memory to keep the files you are reading,
though, so 1 meg is recommended (but not essential).  I use RAM_LOAD
with INTERCEPTOR to have all my CIVILISATION files from disks A and B
on a 1 meg RAMDISK.  They are speed packed, but I NEVER have to swap
disks (except at the end of games; every 5 or 6 days)!



