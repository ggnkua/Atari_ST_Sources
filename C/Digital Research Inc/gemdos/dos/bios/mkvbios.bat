rem "===========================================================================
rem "                               Make Vme Bios
rem "                                     1.1
rem "===========================================================================
copy vbios.arc vbios.sav
copy sio.arc sio.sav
mkstamp
c biosc 
c disk
c sioerr
c siomain
c sioque
c ikb
c kbq
c vt52
c conio
c siochr
c sioint
c siophysc
a ikba
a biosa
a mouse
a siophysa
a startup
ren startup.o startup.osv
ar68 rv sio.arc sio*.o
arvbios

