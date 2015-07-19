;
;TRY-ZIK ....(Code by CRAM from THE SILVERS (C)1990-1991-1992)
;
;
;***********************************************************************
;* COUNT-ZERO (OLD):INIT :player / PLAY : player+6                     *
;* LAP PLAYER:INIT :player /PLAY: player+$22                           *
;* MISFITS SOFTWARE :INIT:player & d0/PLAY:player+4/FIN:player & d0=0  *
;* ACF:INIT:player & d0/PLAY:player+4/END:player                       *
;***********************************************************************
;
; hahaha cette routine est bien pratique mais bon,
; c'est mon premier sources en asm et j'ai jamais optimiser !!!
; alors pardonne moi !!! A+

Y1	set	0	;INIT 1
Y2	set	0	;INIT 2

X 	set	4           ;PLAY

Z	set	0	;END

V	set	1	;Val D0 (INIT)
 	
 	OUTPUT	B:\*.TOS
 
      SECTION TEXT 
Begin:
      PEA	0
      MOVE.W  #$20,-(A7)
      TRAP    #1
      ADDQ.L  #2,A7
      BCLR	#3,$fffffa17.w 
      PEA     L0008(PC) 
      CLR.W   -(A7) 
      MOVE.W  #$19,-(A7)
      TRAP    #$E 
      ADDQ.L  #8,A7 
      PEA     L000A(PC) 
      MOVE.W  #6,-(A7)
      TRAP    #$E 
      ADDQ.L  #6,A7 
      CLR.W   -(A7) 
      PEA     $00078000 
      PEA     $00078000 
      MOVE.W  #5,-(A7)
      TRAP    #$E 
      ADDA.L  #$C,A7
      ANDI.B  #-2,$00000484.L 
      PEA     L000B(PC) 
      MOVE.W  #9,-(A7)
      TRAP    #1
      ADDQ.L  #6,A7 
      
      move.w  #16,$41A.W
      MOVEQ   #V,D0 
      JSR     player+Y1
      MOVEQ   #V,D0 
      JSR     player+Y2

      MOVE.L  #L0001,$4D6

L0000:MOVE.W  #7,-(A7)
      TRAP    #1
      ADDQ.L  #2,A7 
      CMP.B   #$20,D0 
      BEQ.S   END 
      
      sub.w	  #"0",d0
      ble.s	  L0000
      
      cmp.b	  #9,d0	;touche maximal appuyable ici de 1 a 9..
      bgt.s   L0000
      
      jsr	player
       	
       bra.s L0000
      
END:      
      CLR.L   $4D6
      BSET	#3,$fffffa17.w 

	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
      
      PEA     L0009(PC) 
      CLR.W   -(A7) 
      MOVE.W  #$19,-(A7)
      TRAP    #$E 
      ADDQ.L  #8,A7 
      ORI.B   #1,$00000484.L
      CLR.W   -(A7) 
      TRAP    #1
L0001:
      JSR     player+X
      
      LEA     $0007A820,A0
      MOVEQ   #$20,D0 
L0002:CLR.W   (A0)
      CLR.W   8(A0) 
      CLR.W   16(A0)
      CLR.W   24(A0)
      LEA     -320(A0),A0 
      DBF     D0,L0002
      MOVEQ   #0,D0 
      LEA     $0007A820,A0
      MOVE.B  #8,$00FF8800.L
      MOVE.B  $00FF8800.L,D0
      ANDI.B  #$F,D0
      LSL.W   #1,D0 
L0003:MOVE.W  #-1,(A0)
      MOVE.W  #-1,8(A0) 
      MOVE.W  #-1,16(A0)
      MOVE.W  #-1,24(A0)
      LEA     -320(A0),A0 
      DBF     D0,L0003
      LEA     $0007A820,A0
      MOVEQ   #$20,D0 
L0004:CLR.W   34(A0)
      CLR.W   42(A0)
      CLR.W   50(A0)
      CLR.W   58(A0)
      LEA     -320(A0),A0 
      DBF     D0,L0004
      MOVEQ   #0,D0 
      LEA     $0007A820,A0
      MOVE.B  #9,$00FF8800.L
      MOVE.B  $00FF8800.L,D0
      ANDI.B  #$F,D0
      LSL.W   #1,D0 
L0005:MOVE.W  #-1,34(A0)
      MOVE.W  #-1,42(A0)
      MOVE.W  #-1,50(A0)
      MOVE.W  #-1,58(A0)
      LEA     -320(A0),A0 
      DBF     D0,L0005
      LEA     $0007A820,A0
      MOVEQ   #$20,D0 
L0006:CLR.W   68(A0)
      CLR.W   76(A0)
      CLR.W   84(A0)
      CLR.W   92(A0)
      LEA     -320(A0),A0 
      DBF     D0,L0006
      MOVEQ   #0,D0 
      LEA     $0007A820,A0
      MOVE.B  #$A,$00FF8800.L 
      MOVE.B  $00FF8800.L,D0
      ANDI.B  #$F,D0
      LSL.W   #1,D0 
L0007:MOVE.W  #-1,68(A0)
      MOVE.W  #-1,76(A0)
      MOVE.W  #-1,84(A0)
      MOVE.W  #-1,92(A0)
      LEA     -320(A0),A0 
      DBF     D0,L0007
      RTS 
L0008:DC.B   $12
L0009:DC.B   $08
L000A:DS.W    1 
      DC.B   $07,$00,$03,'0',$07,'w',$00,$05
      DC.B   $07,'w',$07,'w',$07,'w',$07,'w'
      DC.B   $07,'w',$07,'w',$07,'w',$07,'w'
      DC.B   $07,'w',$07,'w',$07,'w',$07,'w'
L000B:
      DC.B   "                                     ",13,10
      dc.b	 "             ",$1b,"p"
      DC.B   " MADMAX  000 ",$1b,"q","           ",13,10
      dc.b	 "                                     ",13,10
      dc.b	 "           VU-METRE & RIP ZIK        ",13,10
      dc.b	 "            CRAM/THE SILVERS         ",13,10
      dc.b	13,10
      dc.b	 "              TRY  1 to 9            ",13,10       
      dc.b	0
      even 
player:
	incbin	B:\ACF_001.BIN


