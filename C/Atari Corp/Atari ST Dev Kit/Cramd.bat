cp68 %1.c %1.i
c068 %1.i %1.1 %1.2 %1.3 -f
rm %1.i
c168 %1.1 %1.2 %1.s
rm %1.1
rm %1.2
mac -u -6 %1.s
;***********************************************
;*
;* You can use MADMAC for speedy assembly or
;* you can substitute as68 for more optimized
;* assembly code. Please read the MADMAC
;* and as68 manual for other options and 
;* features. Also recommended is a ramdisk for 
;* the intermediate files of compilation.
;*
;* as68 -l -u %1.s
;*
;***********************************************
rm %1.s
wait.prg
