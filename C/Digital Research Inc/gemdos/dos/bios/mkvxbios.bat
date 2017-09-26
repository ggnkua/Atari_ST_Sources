rem =========================================================================
rem "                       Make VME Hard Disk Bios from Scratch
rem "                                    1.1
rem =========================================================================
del *.o
rem FLOPPY DRIVE DEFINE FILE
c bdefdrv defdrv=0
copy bdefdrv.o bdefd0.osv
rem HARD   DRIVE DEFINE FILE
c bdefdrv defdrv=2 
copy bdefdrv.o bdefd2.osv
mkvbios
