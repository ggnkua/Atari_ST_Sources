          move.l    sp,a5		;release memory
          move.l    4(a5),a5
          move.l    $c(a5),d0
          addi.l    #$100,d0
          move.l    d0,-(sp)
          move.l    a5,-(sp)
          move.w    #0,-(sp)
          move.w    #$4a,-(sp)
          trap      #1
          adda.l    #$c,sp
          clr.l     -(sp)		;supervisor state
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    $84.w,OLD_TRAP1+2	;store & change TRAP #1 vector
          move.l    #MY_TRAP1,$84.w
          move.l    d0,-(sp)  		;user state
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          pea       DUMMY_VAL(pc)    ;load & execute program
          pea       DUMMY_VAL(pc)
          pea       FILE_NAME(pc)
          move.w    #0,-(sp)
          move.w    #$4b,-(sp)
          trap      #1
END_OF_PRG:         
          lea.l     16(sp),sp
          clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    OLD_TRAP1+2,$84.w
          move.l    d0,-(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1

FILE_NAME:	dc.b	'delight.rsc',0
even

MY_TRAP1:
          btst      #5,(sp)
          bne.s     NO_SUPERVISOR
          move.l    usp,a0
          bra.s     CHK_FUNCTION
NO_SUPERVISOR:      
          move.l   sp,a0
          addq.l    #6,a0
CHK_FUNCTION:       
          cmpi.w    #$3f,(a0) ; read
          beq.s     FUNC_3F
OLD_TRAP1:          
          jmp       0

FUNC_3F:  
          move.l    8(a0),LOAD_ADDR     ; Puffer
          move.l    2(sp),RET_ADDR5+2   ; Returnadresse
          move.l    #READ,2(sp)
	  bra.s	    OLD_TRAP1

READ:     
          tst.w     2(sp)
          bmi       RET_ADDR5		; device handle->do nothing
          movem.l   d0-d7/a0-a6,-(sp)
          move.l    d0,PACKED_LENGTH
          move.l    d0,ACTUAL_LENGTH_2
          btst      #0,d0
          bne       END_READ		; bytes read odd->not crunched
          move.l    LOAD_ADDR,a0	; Puffer
          move.l    a0,d7
          btst      #0,d7
          bne       END_READ
          adda.l    d0,a0
          move.l    -(a0),d0		; check if crunched file
          cmpi.l    #'JEK!',d0
          beq.s     UNPACK
          bra       END_READ
UNPACK:   
          move.l    -(a0),ACTUAL_LENGTH_2
          move.w    sr,d1
          btst      #$d,d1
          bne.s     SUPERVISOR
          clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          lea.l     SYSTEM_STACK,a6
          move.l    d0,(a6)
          move.w    #1,SV_FLAG
SUPERVISOR:         
          move.w    $ff8240,OLD_COLOR
          subq.l    #4,PACKED_LENGTH
          move.l   LOAD_ADDR,a0
          adda.l    PACKED_LENGTH,a0
          move.l   LOAD_ADDR,a1
          move.l   -(a0),a2
          adda.l    a1,a2
          move.l    -(a0),d5
          move.l    -(a0),d0
          eor.l     d0,d5
L541F8:   lsr.l     #1,d0
          bne.s     L54200
          bsr       L542BE
L54200:   bcs.s     L54242
          moveq   #8,d1
          moveq   #1,d3
          lsr.l     #1,d0
          bne.s     L5420E
          bsr       L542BE
L5420E:   bcs.s     L5426E
          moveq   #3,d1
          clr.w     d4
L54214:   bsr       L542CA
          move.w    d2,d3
          add.w     d4,d3
L5421C:   moveq   #7,d1
L5421E:   lsr.l     #1,d0
          bne.s     L54226
          bsr       L542BE
L54226:   roxl.l    #1,d2
          dbra      d1,L5421E
          move.b    d2,-(a2)
          eori.w    #$370,MY_COLOR
          move.w    MY_COLOR,$ff8240
          dbra      d3,L5421C
          bra.s     L5427C
L5423C:   moveq     #8,d1
          moveq     #8,d4
          bra.s     L54214
L54242:   moveq     #2,d1
          bsr.s     L542CA
          cmpi.b    #2,d2
          blt.s     L54264
          cmpi.b    #3,d2
          beq.s     L5423C
          moveq     #8,d1
          bsr.s     L542CA
          move.w    d2,d3
          move.w    #$c,d1
          bra.s     L5426E
L54264:   move.w    #9,d1
          add.w     d2,d1
          addq.w    #2,d2
          move.w    d2,d3
L5426E:   bsr.s     L542CA
L54272:   subq.l    #1,a2
          move.b    0(a2,d2.w),(a2)
          dbra      d3,L54272
L5427C:   cmpa.l    a2,a1
          blt       L541F8
          move.w    OLD_COLOR,$ff8240
          cmpi.w    #1,SV_FLAG
          bne.s     END_READ
          move.l    SYSTEM_STACK,-(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
END_READ: 
          move.w    #0,SV_FLAG
          movem.l   (sp)+,d0-d7/a0-a6
          move.l    ACTUAL_LENGTH_2,d0
RET_ADDR5:          
          jmp       0
L542BE:   move.l    -(a0),d0
          eor.l     d0,d5
          move.w    #$10,ccr
          roxr.l    #1,d0
          rts       
L542CA:   subq.w    #1,d1
          clr.w     d2
L542CE:   lsr.l     #1,d0
          bne.s     L542DC
          move.l    -(a0),d0
          eor.l     d0,d5
          move.w    #$10,ccr
          roxr.l    #1,d0
L542DC:   roxl.l    #1,d2
          dbra      d1,L542CE
          rts       

ACTUAL_LENGTH_2:    
           dc.l 0
LOAD_ADDR:          
           dc.l 0
SV_FLAG:  
           dc.w 0
SYSTEM_STACK:       
           dc.l 0
PACKED_LENGTH:      
           dc.l 0
OLD_COLOR:          
           dc.w 0
MY_COLOR: 
           dc.w $777
DUMMY_VAL:          
           dc.w 0

