
  This is the Version 2.1 Release of the Mark Johnson C Compiler.

  Because of lack of space, the Emacs editor (UE.TTP) mentioned in
the doc is not included.  Use your own favorite editor instead (as long 
as it can save plain ascii text), or use one of the several Emacs editors 
on other AccuSoft PD disks.

  Here is a brief explanation of Moshe Braner's AUTODISK (861223): 

   AUTODISK - program to copy floppy disk to RAM disk upon system
                boot, and also set the system clock.

   This program is to be placed in the \AUTO folder on the boot disk,
   AFTER the RAMdisk program.  (It assumes the reset-immune RAM disk is
   already installed.)  After asking the user for the current time and
   date, and setting the ST's two clocks accordingly, this program copies
   the whole floppy disk data, FATs, directory and all, onto the RAMdisk.

   Works only on Normal Format floppy disks (not on Hard Disks or Twisted
   Formats).
