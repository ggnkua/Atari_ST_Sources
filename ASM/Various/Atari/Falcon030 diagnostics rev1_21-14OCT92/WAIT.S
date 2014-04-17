        .text
        .extern wait, wait100,wait400,wait25,wait10
*       Apr 17, 92   Save and restore SPControl to caller, TLE
*       May 14, 92   Measured wait time for 16 and 8 mhz                     

wait:   move.l  d0,-(a7)
*  wait for 16 mhz CPU clock
        move.l  #1382,d0        ; 2.5 ms +   
;        btst.b  #0,SPControl
;        bne.s   wait1           ; bra if 16 MHZ                 

;wait_8: 
;*  wait for 8 mhz CPU clock
;        move.l  #691,d0         ; 2.5 ms +  

wait1:  
        nop
        subq.l  #1,d0
        bne.s   wait1
        move.l  (a7)+,d0
        rts     

wait25:  
        move.l    #25,d0      ;
.1:     bsr       wait       
        dbra      d0,.1
        rts

wait10:  
        move.l    #11,d0      
        btst.b    #0,SPControl
        bne.s     .2            ; bra if 16 MHZ                 
        move.l    #10,d0      

.2:     bsr       wait       
        dbra      d0,.2
        rts

wait100:  move.l    d0,-(a7)            ; wait for 250 ms
          move.l    #98,d0              ; for 16 mhz 00 00 00
;         btst.b    #0,SPControl
;         bne.s     wait10a             ;                 
;         move.l    #98,d0              ; for 8 mhz (00 00)  

wait10a:  bsr       wait                ; 
          dbra      d0,wait10a
          move.l    (a7)+,d0
          rts

wait400:  move.l    d0,-(a7)
          move.l    #3,d0               ; wait 1000 mS
wait40a:  bsr       wait100
          dbra      d0,wait40a
          move.l    (a7)+,d0
          rts

wait5sec:
          move.l    #$a00000,d0       ; maybe six seconds
.1:       sub.l     #1,d0
          bne.s     .1
          rts



