;
; fÅr MScroll.IS benîtigte Makro-Aufrufe fÅr Betriebssystem-Funktionen
; 30.6.1990 Peter Holzwarth
;

             .MACRO Getrez
             move.w    #4,-(sp)
             trap      #14
             addq.w    #2,sp
             .ENDM 

             .MACRO Iorec devn
             move.w    \1,-(sp)
             move.w    #14,-(sp)
             trap      #14
             addq.w    #4,sp
             .ENDM 

             .MACRO Supexec code
             move.l    \1,-(sp)
             move.w    #38,-(sp)
             trap      #14
             addq.w    #6,sp
             .ENDM 

_vblqueue    = $456
             .END 


