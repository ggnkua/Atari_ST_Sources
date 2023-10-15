	.export fsel_exinput
aes:           
   move.l   #aespb,d1   ;parameterblock nach d1
   move.l   #$c8,d0     ;'magische zahl' fÅr aes 
   trap     #2             
   rts

fsel_exinput:      

   move.l   a0,addrin           ;Pfadnamen und
   move.l   a1,addrin+4         ;Filenamen Åbergeben
   move.l   4(a7),addrin+8      ; ueberschrift
   bsr      aes
   movea.l 8(a7),a1
   move.w  intout+2,(a1) 
   rts 

   data
aespb:   dc.l   ctrl,global,intin,intout,addrin,addrout
ctrl:	dc.w	91,0,2,3,0,0,0,0,0,0,0
       
   bss

global:  ds.w   15
intin:   ds.w   8
ptsin:   ds.w   8
intout:  ds.w   8
ptsout:  ds.w   8
addrin:  ds.l   4
addrout: ds.l   2
        end
