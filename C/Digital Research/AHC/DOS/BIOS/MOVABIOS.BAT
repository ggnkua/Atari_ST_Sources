rem "========================================================================
rem "                   MOVE VME BIOS TO OBJECT DIRECTORY
rem "                             as an archive
rem "========================================================================
copy vbios.arc   \gemdos\obj
copy *.osv \gemdos\obj
ren \gemdos\obj\startup.osv \gemdos\obj\startup.o
