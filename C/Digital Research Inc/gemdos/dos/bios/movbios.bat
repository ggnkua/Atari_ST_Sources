rem "========================================================================
rem "                   MOVE VME BIOS TO OBJECT DIRECTORY
rem "                             as object files
rem "========================================================================
copy *.o  \gemdos\obj
copy *.osv \gemdos\obj
copy *.arc \gemdos\obj
ren \gemdos\obj\startup.osv \gemdos\obj\startup.o
