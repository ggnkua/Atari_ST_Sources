;
; TESERAE by Steven Bland (ASC)
;
; Dis-assembled, Depacked and Cheat Mode added by: MUG U.K(tm)
;

IWOZERE	BRA	INTRO
	DC.B      'This version of TESERAE was dis-assembled, depacked and '
	DC.B      'then a Level Change option was added !!  All this work was '
	DC.B      'done by: MUG U.K',191,' (of The Source) on the 8th August 1992 - '
	DC.B      'which is the same day I bought ST Format with this game on it !!  '
	DC.B      'Please spread this trainer version around the world !!  '
	EVEN

INTRO	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,old_sp
	
	bclr	#0,$484.w

	moveq	#1,d0
	bsr	music
	move.l	#music+8,$4d2.w

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	lea	oldrez+2,a0
	move.w	d0,a0

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	movem.l	empty,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$666,d6		Fade background to black
.loop1	move.w	d6,$ffff8240.w
	bsr	delay
	sub.w	#$111,d6
	bpl.s	.loop1

	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#$111,d6		Fade text to white
.loop2	move.w	d6,$ffff825e.w
	bsr	delay
	add.w	#$111,d6
	cmp.w	#$888,d6
	bne.s	.loop2

k_loop	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.l	$4d2.w
	moveq	#0,d0
          bsr	music
	bset	#0,$484.w

oldrez	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		; user mode
	addq.l	#6,sp

	BRA	BEGIN

delay	moveq	#7,d7		Delay used in fading colours
.1	move.w	#$25,-(a7)	Wait for VBL
	trap	#14
	addq.l	#2,a7
	dbf	d7,.1
	rts

empty	ds.w	16
	even
;
; Variables and stuff
;

text	dc.b	27,"E"	; CLS
	dc.b	27,"f"	; Hide cursor
;
; Text Message goes here
;
	;	 0123456789012345678901234567890123456789 ; 40 chars

	dc.b	"****************************************",13,10
	dc.b	"*               TESERAE+               *",13,10
	dc.b	"*               --------               *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"*              Trained by              *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"*       MUG U.K  (of The Source)       *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"* During the game, press the '+' & '-' *",13,10
	dc.b	"* keys to increase or decrease the     *",13,10
	dc.b	"* current level !!  I've also fixed a  *",13,10
	dc.b	"* bug in that the speed of the blocks  *",13,10
	dc.b	"* from the previous game was not reset *",13,10
	dc.b	"* to that of Level 1 !!                *",13,10
	dc.b	"*                                      *",13,10
	dc.b	"****************************************",13,10,10
	dc.b	"Quick Greets To:  Rest of The Source,",13,10
	dc.b	"Special FX, Animal Mine (Penguin), PHF,",13,10
	dc.b	"MSD/POV and Pele of The Lemmings !!",13,10
	dc.b	0
	even

music	incbin	'd:\musichak.mug\j_buggin\tao_digi.snd\zoolook.mus'
	even

old_vbl	ds.l	1
old_sp	ds.l	1


BEGIN             DC.W      $A00A 
                  MOVE.W    #2,-(A7) 	;PHYSBASE 
                  TRAP      #$E 
                  ADDQ.W    #2,A7 
                  MOVE.L    D0,SCREENBASE 
                  MOVE.W    #4,-(A7) 	;GETREZ 
                  TRAP      #$E 
                  ADDQ.W    #2,A7 
                  MOVE.W    D0,OLDREZ 
                  MOVE.W    #0,-(A7)
                  MOVE.L    #$FFFFFFFF,-(A7)
                  MOVE.L    #$FFFFFFFF,-(A7)
                  MOVE.W    #5,-(A7) 	;SETSCREEN
                  TRAP      #$E 
                  ADDA.L    #$C,A7
                  CLR.L     -(A7) 
                  MOVE.W    #$20,-(A7) 	;SUPER
                  TRAP      #1
                  ADDQ.W    #6,A7 
                  MOVE.L    D0,SAVESP 
                  MOVEA.L   #$FFFF8240,A0 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  CLR.L     (A0)+ 
                  MOVE.L    $42E.L,D0 
                  SUBI.L    #$64,D0 
                  MOVEA.L   D0,A7 
                  SUBI.L    #$190,D0
                  SUBI.L    #$AFC8,D0 
                  ANDI.L    #$FFFFFF00,D0 
                  MOVE.L    D0,INVIS
                  SUBI.L    #$AFC8,D0 
                  ANDI.L    #$FFFFFF00,D0 
                  MOVE.L    D0,VISSCRN
                  ADDI.L    #$18,D0 
                  MOVE.L    D0,SPRI1
                  MOVE.L    D0,SPRI2
                  BSR       SWAPSCRN
;                  LEA       MUSIX,A0
;                  BSR       DEPACK
                  LEA       FONT,A0 
                  BSR       DEPACK
                  LEA       PICCY1,A0 
                  BSR       DEPACK
                  BSR       PRESHIFT
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  MOVE.W    #$2647,D7 
L0000:            CLR.L     (A1)+ 
                  CLR.L     (A0)+ 
                  DBF       D7,L0000
                  MOVE      #$2700,SR 
                  MOVE.B    #2,$FFFF820A.L
                  MOVE.B    $FFFFFA07.W,SVEIERA 
                  MOVE.B    $FFFFFA09.W,SVEIERB 
                  MOVE.B    $FFFFFA17.W,SVEVR 
                  BCLR      #4,$FFFFFA09.W
                  BCLR      #5,$FFFFFA09.W
                  BCLR      #3,$FFFFFA17.W
                  CLR.B     $FFFFFA1B.W 
                  BSET      #0,$FFFFFA07.W
                  BSET      #0,$FFFFFA13.W
                  MOVE.L    $118.W,SVE118 
                  MOVE.L    #RTE,$118.W 
                  MOVE.L    $70.W,SVE70 
                  MOVE.L    #VBL2,$70.W 
                  MOVEQ     #1,D0 
                  BSR       MUSIX 
                  MOVE      #$2300,SR 
CODEGO:           MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  MOVE.W    #$2647,D7 
L0002:            CLR.L     (A1)+ 
                  CLR.L     (A0)+ 
                  DBF       D7,L0002
                  MOVE.W    #1,BLKOUT 
                  MOVE.L    #VBL2,$70.W 
                  LEA       PICCY3,A0 
                  MOVEA.L   INVIS,A1
                  SUBA.L    #$22,A1 
                  BSR       DECRUN
                  MOVEA.L   INVIS,A0
                  ADDA.L    #$7D00,A0 
                  MOVE.L    #$27,D7 
L0003:            CLR.L     (A0)+ 
                  DBF       D7,L0003
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  MOVE.W    #$2647,D7 
L0004:            MOVE.L    (A0)+,(A1)+ 
                  DBF       D7,L0004
                  CLR.W     BLKOUT
                  MOVE.L    #INTROTEX,A5BAK4
                  MOVE.W    #0,TEXTX
                  MOVE.W    #$CD,TEXTY
                  MOVE.W    #$A,COUNTER2
                  MOVE.L    HISCORE,D0
                  LEA       HIBUF,A0
                  MOVE.L    #$20202020,(A0)+
                  MOVE.B    #$20,5(A0)
                  ADDQ.L    #1,A0 
                  MOVE.L    #$10,D2 
L0005:            CMP.L     #$A,D0
                  BLT.B     L0006 
                  DIVS      #$A,D0
                  MOVE.L    D0,D1 
                  ANDI.L    #$FFFF,D1 
                  LSR.L     D2,D0 
                  ADDI.L    #$30,D0 
                  MOVE.B    D0,-(A0)
                  MOVE.L    D1,D0 
                  BRA.B     L0005 
L0006:            ADDI.L    #$30,D0 
                  MOVE.B    D0,-(A0)
SYNC2:            CMPI.B    #1,VBLDONE
                  BNE.B     SYNC2 
                  MOVE.B    #0,VBLDONE
                  BSR       SWAPSCRN
                  JSR       TEXTDIS 
                  LEA       L0114,A0
                  CMPI.W    #0,GLINT
                  BNE.B     L0008 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$2EE,GLINT 
L0008:            SUBQ.W    #1,GLINT
                  CLR.L     D0
                  MOVE.W    GLINT,D0
                  CMP.W     #$12,D0 
                  BNE.B     L0009 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$FFF,(A0)
L0009:            CMP.W     #$F,D0
                  BNE.B     L000A 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$FFF,2(A0) 
L000A:            CMP.W     #$C,D0
                  BNE.B     L000B 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$FFF,4(A0) 
L000B:            CMP.W     #9,D0 
                  BNE.B     L000C 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$FFF,6(A0) 
L000C:            CMP.W     #6,D0 
                  BNE.B     L000D 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$FFF,8(A0) 
L000D:            CMP.W     #3,D0 
                  BNE.B     L000E 
                  CLR.L     (A0)
                  CLR.L     4(A0) 
                  CLR.L     8(A0) 
                  MOVE.W    #$FFF,10(A0)
L000E:            CLR.B     VBLDONE 
                  CMPI.B    #$39,$FFFFFC02.W
                  BNE       SYNC2 
                  MOVE.W    #1,BLKOUT 
                  MOVE.L    #VBL,$70.W
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  MOVE.W    #$2647,D7 
L000F:            CLR.L     (A1)+ 
                  CLR.L     (A0)+ 
                  DBF       D7,L000F
                  MOVE.L    #XSPDAT,A5BAK1
                  MOVE.L    #YSPDAT,A5BAK2
                  MOVE.L    #TEXT,TEXTPOS 
                  MOVE.L    #DATALINE,A5BAK 
                  LEA       PICCY2,A0 
                  MOVEA.L   INVIS,A1
                  SUBA.L    #$22,A1 
                  BSR       DECRUN
                  MOVEA.L   INVIS,A0
                  ADDA.L    #$7D00,A0 
                  MOVE.L    #$27,D7 
L0010:            CLR.L     (A0)+ 
                  DBF       D7,L0010
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  MOVE.W    #$2647,D7 
L0011:            MOVE.L    (A0)+,(A1)+ 
                  DBF       D7,L0011
                  MOVE.W    #$11,-(A7) 	;RANDOM 
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  ANDI.L    #7,D0 
                  LEA       OBJECT,A1 
                  MOVE.L    NEXTSHAPE,D0
                  LSL.L     #4,D0 
                  ADDA.L    D0,A1 
                  CLR.L     D0
                  CLR.L     D1
                  MOVE.W    #$1E78,D1 
                  MOVEA.L   INVIS,A0
                  ADDA.L    D1,A0 
                  MOVE.L    A1,-(A7)
                  BSR       QWIKKY
                  MOVEA.L   (A7)+,A1
                  MOVEA.L   VISSCRN,A0
                  ADDA.L    D1,A0 
                  BSR       QWIKKY
                  MOVE.W    #$11,-(A7) 	;RANDOM 
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  ANDI.L    #7,D0 
                  LEA       OBJECT,A0 
                  LSL.L     #4,D0 
                  ADDA.L    D0,A0 
                  LEA       OBJRM,A1
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.W    #1,LEVEL
                  BSR       SETLEV
                  CLR.L     SCORE 
                  CLR.L     LEVELOK 
                  BSR       DISSCORE
                  CLR.W     URDEAD
                  CLR.W     YPOS
                  MOVE.W    #5,XPOS 
                  LEA       BOARD,A0
                  MOVE.L    #$13,D7 
L0012:            MOVE.L    #$1000000,(A0)+ 
                  MOVE.L    #0,(A0)+
                  MOVE.L    #1,(A0)+
                  DBF       D7,L0012
                  CLR.W     BLKOUT
SYNC1:            CMPI.B    #1,VBLDONE
                  BNE.B     SYNC1 
                  MOVE.B    #0,VBLDONE
                  BSR       SWAPSCRN
                  CMPI.W    #1,URDEAD 
                  BNE.B     L0014 
                  CMPI.B    #$39,$FFFFFC02.W
                  BEQ       RESET
                  BRA       SLIDE
;
; Reset the speed counter from the previous game !!
;

RESET             LEA       L001E(PC),A0
                  MOVE.W    #$1F,(A0)
                  BRA       CODEGO
 
L0014:            CMPI.W    #0,TETCNT 
                  BEQ       L001B 
                  SUBQ.W    #1,TETCNT 
                  CMPI.W    #8,TETCNT 
                  BNE.B     L0015 
                  MOVE.W    #$666,L0112 
L0015:            CMPI.W    #7,TETCNT 
                  BNE.B     L0016 
                  MOVE.W    #$555,L0112 
L0016:            CMPI.W    #6,TETCNT 
                  BNE.B     L0017 
                  MOVE.W    #$444,L0112 
L0017:            CMPI.W    #5,TETCNT 
                  BNE.B     L0018 
                  MOVE.W    #$343,L0112 
L0018:            CMPI.W    #4,TETCNT 
                  BNE.B     L0019 
                  MOVE.W    #$242,L0112 
L0019:            CMPI.W    #3,TETCNT 
                  BNE.B     L001A 
                  MOVE.W    #$141,L0112 
L001A:            CMPI.W    #2,TETCNT 
                  BNE.B     L001B 
                  MOVE.W    #$40,L0112
L001B:            CMPI.W    #0,PAUSEW 
                  BEQ.B     L001C 
                  SUBQ.W    #1,PAUSEW 
                  BRA.B     L001D 
L001C:            CMPI.B    #$19,$FFFFFC02.W
                  BEQ       GOPAUSE 
L001D:            CMPI.W    #1,PAUSEON
                  BEQ       SLIDE 
                  ADDQ.W    #1,COUNTER
                  ANDI.W    #$1F,COUNTER
L001E             EQU       *-6 
                  TST.W     COUNTER 
                  BNE       NOMOVE
                  CLR.W     PRESS2
                  LEA       BOARD,A0
                  MOVE.W    YPOS,D0 
                  ADDQ.W    #1,D0 
                  MULU      #$C,D0
                  ADDA.W    D0,A0 
                  ADDA.W    XPOS,A0 
                  LEA       OBJRM,A1
                  MOVEQ     #3,D7 
L001F:            MOVEQ     #3,D6 
L0020:            CMPI.B    #1,(A0)+
                  BNE.B     L0021 
                  CMPI.B    #1,(A1) 
                  BEQ       FIXOBJECT 
L0021:            ADDQ.L    #1,A1 
                  DBF       D6,L0020
                  ADDA.W    #8,A0 
                  DBF       D7,L001F
                  ADDQ.W    #1,YPOS 
NOMOVE:           BSR       DISOBJ
                  MOVE.B    $FFFFFC02.W,D0
                  CMPI.W    #1,PRESS2 
                  BEQ.B     L0023 
                  CMP.W     #$50,D0 
                  BNE.B     L0023 
                  LEA       L001E(PC),A0
                  MOVE.W    (A0),D1 
                  SUBI.W    #4,D1 
                  MOVE.W    D1,COUNTER
                  MOVE.W    #1,PRESS2 
L0023:            CMP.B     PRESS1,D0 
                  BEQ.B     AUTOREP 
                  MOVE.B    D0,PRESS1 
                  MOVE.W    #$A,COUNTER3
                  CMP.B     #$4D,D0 
                  BEQ       GORIGHT 
                  CMP.B     #$4B,D0 
                  BEQ       GOLEFT
                  CMP.B     #$39,D0 	;#'9'
                  BEQ       GOROTATE
;
; Here's the cheat mode - press '+' to increase the current level
;
                  CMP.B     #$4E,D0	;'+' for increase level
                  BNE.B     NOT_PLUS
                  CMP.W     #5,LEVEL	; Already on sixth level ??
                  BGT.B     NOT_PLUS
                  ADDQ.W    #1,LEVEL
                  BSR       SETLEV
                  BRA.B     CONTINUE

NOT_PLUS          CMP.B     #$4A,D0
                  BNE.B     CONTINUE
                  CMP.W     #1,LEVEL
                  BLE.B     CONTINUE
                  SUBQ.W    #1,LEVEL
                  BSR       SETLEV

CONTINUE          BRA       SLIDE 

AUTOREP:          SUBQ.W    #1,COUNTER3 
                  CMPI.W    #0,COUNTER3 
                  BNE.B     SLIDE 
                  MOVE.W    #$A,COUNTER3
                  CMP.B     #$4D,D0 
                  BEQ       GORIGHT 
                  CMP.B     #$4B,D0 
                  BEQ       GOLEFT
SLIDE:            BSR       STARS 
                  BSR       SCROLLER
                  BSR       BYTEBEND
                  CLR.B     VBLDONE 
                  CMPI.B    #$62,$FFFFFC02.W
                  BNE       SYNC1 
                  MOVE      #$2700,SR 
                  BSR       CLRHBL
                  MOVE.B    SVEIERA,$FFFFFA07.W 
                  MOVE.B    SVEIERB,$FFFFFA09.W 
                  MOVE.B    SVEIMRA,$FFFFFA13.W 
                  MOVE.B    SVEVR,$FFFFFA17.W 
                  MOVE.B    SVETBCR,$FFFFFA1B.W 
                  MOVE.B    SVETBDR,$FFFFFA21.W 
                  MOVE.L    SVE118,$118.W 
                  MOVE.L    SVE70,$70.W 
                  MOVE.L    #$8080000,$FFFF8800.W 
                  MOVE.L    #$9090000,$FFFF8800.W 
                  MOVE.L    #$A0A0000,$FFFF8800.W 
                  MOVE      #$2300,SR 
                  MOVE.L    SAVESP,-(A7)
                  MOVE.W    #$20,-(A7) 	;SUPER
                  TRAP      #1
                  ADDQ.W    #6,A7 
                  MOVE.W    OLDREZ,-(A7)
                  MOVE.L    SCREENBASE,-(A7)
                  MOVE.L    SCREENBASE,-(A7)
                  MOVE.W    #5,-(A7) 	;SETSCREEN
                  TRAP      #$E 
                  ADDA.L    #$C,A7
                  PEA       GEMPAL
                  MOVE.W    #6,-(A7) 	;SETPALLETE 
                  TRAP      #$E 
                  ADDQ.W    #6,A7 
                  CLR.W     -(A7) 	;PTERM0
                  TRAP      #1
GOPAUSE:          CMPI.W    #1,PAUSEON
                  BEQ.B     L0027 
                  MOVE.W    #1,PAUSEON
                  MOVE.W    #$32,PAUSEW 
                  BRA       SLIDE 
L0027:            CLR.W     PAUSEON 
                  MOVE.W    #$32,PAUSEW 
                  BRA       SLIDE 
GOROTATE:         LEA       OBJRM,A0
                  LEA       ROTRM,A1
                  MOVE.B    (A0)+,12(A1)
                  MOVE.B    (A0)+,8(A1) 
                  MOVE.B    (A0)+,4(A1) 
                  MOVE.B    (A0)+,(A1)
                  MOVE.B    (A0)+,13(A1)
                  MOVE.B    (A0)+,9(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,1(A1) 
                  MOVE.B    (A0)+,14(A1)
                  MOVE.B    (A0)+,10(A1)
                  MOVE.B    (A0)+,6(A1) 
                  MOVE.B    (A0)+,2(A1) 
                  MOVE.B    (A0)+,15(A1)
                  MOVE.B    (A0)+,11(A1)
                  MOVE.B    (A0)+,7(A1) 
                  MOVE.B    (A0)+,3(A1) 
                  LEA       BOARD,A0
                  LEA       ROTRM,A1
                  CLR.L     D0
                  MOVE.W    YPOS,D0 
                  MULU      #$C,D0
                  ADDA.L    D0,A0 
                  ADDA.W    XPOS,A0 
                  MOVEQ     #3,D7 
L0029:            MOVEQ     #3,D6 
L002A:            CMPI.B    #1,(A0)+
                  BNE.B     L002B 
                  CMPI.B    #1,(A1) 
                  BEQ       SLIDE 
L002B:            ADDQ.L    #1,A1 
                  DBF       D6,L002A
                  ADDA.W    #8,A0 
                  DBF       D7,L0029
                  LEA       ROTRM,A0
                  LEA       OBJRM,A1
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  BRA       SLIDE 
GORIGHT:          LEA       BOARD,A0
                  LEA       OBJRM,A1
                  CLR.L     D0
                  MOVE.W    YPOS,D0 
                  MULU      #$C,D0
                  ADDA.L    D0,A0 
                  ADDA.W    XPOS,A0 
                  ADDQ.W    #1,A0 
                  MOVEQ     #3,D7 
L002D:            MOVEQ     #3,D6 
L002E:            CMPI.B    #1,(A0)+
                  BNE.B     L002F 
                  CMPI.B    #1,(A1) 
                  BEQ       SLIDE 
L002F:            ADDQ.L    #1,A1 
                  DBF       D6,L002E
                  ADDA.W    #8,A0 
                  DBF       D7,L002D
                  ADDQ.W    #1,XPOS 
                  BRA       SLIDE 
GOLEFT:           LEA       BOARD,A0
                  LEA       OBJRM,A1
                  CLR.L     D0
                  MOVE.W    YPOS,D0 
                  MULU      #$C,D0
                  ADDA.L    D0,A0 
                  ADDA.W    XPOS,A0 
                  SUBQ.W    #1,A0 
                  MOVEQ     #3,D7 
L0031:            MOVEQ     #3,D6 
L0032:            CMPI.B    #1,(A0)+
                  BNE.B     L0033 
                  CMPI.B    #1,(A1) 
                  BEQ       SLIDE 
L0033:            ADDQ.L    #1,A1 
                  DBF       D6,L0032
                  ADDA.W    #8,A0 
                  DBF       D7,L0031
                  SUBQ.W    #1,XPOS 
                  BRA       SLIDE 
FIXOBJECT:        CMPI.W    #0,YPOS 
                  BNE.B     L0036 
                  MOVE.W    #1,URDEAD 
                  MOVE.L    HISCORE,D0
                  CMP.L     SCORE,D0
                  BGE.B     L0035 
                  MOVE.L    SCORE,HISCORE 
L0035:            BRA       SLIDE 
L0036:            BSR       DISOBJ
                  LEA       BOARD,A0
                  LEA       OBJRM,A1
                  CLR.L     D0
                  MOVE.W    YPOS,D0 
                  MULU      #$C,D0
                  ADDA.L    D0,A0 
                  ADDA.W    XPOS,A0 
                  MOVEQ     #3,D7 
L0037:            MOVEQ     #3,D6 
L0038:            CMPI.B    #1,(A1)+
                  BNE.B     L0039 
                  MOVE.B    #1,(A0) 
L0039:            ADDQ.L    #1,A0 
                  DBF       D6,L0038
                  ADDQ.L    #8,A0 
                  DBF       D7,L0037
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  CLR.L     D0
                  MOVE.W    YPOS,D0 
                  ADDI.W    #2,D0 
                  MULU      #$500,D0
                  ADDA.L    D0,A0 
                  ADDA.L    D0,A1 
                  MOVE.W    XPOS,D0 
                  ADDI.W    #$C,D0
                  ANDI.L    #$FE,D0 
                  LSL.L     #2,D0 
                  ADDA.L    D0,A0 
                  ADDA.L    D0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  CLR.W     (A0)
                  OR.W      D0,2(A0)
                  OR.W      D0,2(A1)
                  MOVE.W    8(A0),D0
                  CLR.W     8(A0) 
                  OR.W      D0,10(A0) 
                  OR.W      D0,10(A1) 
                  MOVE.W    16(A0),D0 
                  CLR.W     16(A0)
                  OR.W      D0,18(A0) 
                  OR.W      D0,18(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  CLR.W     GOTATET 
                  BSR       LINEDONE
                  BSR       LINEDONE
                  BSR       LINEDONE
                  BSR       LINEDONE
                  CMPI.W    #4,GOTATET
                  BNE.B     L003A 
                  MOVE.W    #$777,L0112 
                  MOVE.W    #$19,TETCNT 
                  ADDI.L    #$50,SCORE
                  ADDI.L    #$50,LEVELOK
L003A:            BSR       DISSCORE
                  MOVE.W    #$11,-(A7) 	;RANDOM 
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  ANDI.L    #7,D0 
                  CLR.L     D1
                  CLR.L     D2
                  MOVE.L    NEXTSHAPE,D1
                  MOVE.L    D0,NEXTSHAPE
                  MOVE.L    D1,CURRSHAPE
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  ADDA.W    #$1E78,A0 
                  ADDA.W    #$1E78,A1 
                  CLR.W     (A0)
                  CLR.W     (A1)
                  CLR.W     8(A0) 
                  CLR.W     8(A1) 
                  CLR.W     160(A0) 
                  CLR.W     160(A1) 
                  CLR.W     168(A0) 
                  CLR.W     168(A1) 
                  CLR.W     320(A0) 
                  CLR.W     320(A1) 
                  CLR.W     328(A0) 
                  CLR.W     328(A1) 
                  CLR.W     480(A0) 
                  CLR.W     480(A1) 
                  CLR.W     488(A0) 
                  CLR.W     488(A1) 
                  CLR.W     640(A0) 
                  CLR.W     640(A1) 
                  CLR.W     648(A0) 
                  CLR.W     648(A1) 
                  CLR.W     800(A0) 
                  CLR.W     800(A1) 
                  CLR.W     808(A0) 
                  CLR.W     808(A1) 
                  CLR.W     960(A0) 
                  CLR.W     960(A1) 
                  CLR.W     968(A0) 
                  CLR.W     968(A1) 
                  CLR.W     1120(A0)
                  CLR.W     1120(A1)
                  CLR.W     1128(A0)
                  CLR.W     1128(A1)
                  CLR.W     1280(A0)
                  CLR.W     1280(A1)
                  CLR.W     1288(A0)
                  CLR.W     1288(A1)
                  CLR.W     1440(A0)
                  CLR.W     1440(A1)
                  CLR.W     1448(A0)
                  CLR.W     1448(A1)
                  CLR.W     1600(A0)
                  CLR.W     1600(A1)
                  CLR.W     1608(A0)
                  CLR.W     1608(A1)
                  CLR.W     1760(A0)
                  CLR.W     1760(A1)
                  CLR.W     1768(A0)
                  CLR.W     1768(A1)
                  CLR.W     1920(A0)
                  CLR.W     1920(A1)
                  CLR.W     1928(A0)
                  CLR.W     1928(A1)
                  CLR.W     2080(A0)
                  CLR.W     2080(A1)
                  CLR.W     2088(A0)
                  CLR.W     2088(A1)
                  CLR.W     2240(A0)
                  CLR.W     2240(A1)
                  CLR.W     2248(A0)
                  CLR.W     2248(A1)
                  CLR.W     2400(A0)
                  CLR.W     2400(A1)
                  CLR.W     2408(A0)
                  CLR.W     2408(A1)
                  CLR.W     2560(A0)
                  CLR.W     2560(A1)
                  CLR.W     2568(A0)
                  CLR.W     2568(A1)
                  CLR.W     2720(A0)
                  CLR.W     2720(A1)
                  CLR.W     2728(A0)
                  CLR.W     2728(A1)
                  CLR.W     2880(A0)
                  CLR.W     2880(A1)
                  CLR.W     2888(A0)
                  CLR.W     2888(A1)
                  CLR.W     3040(A0)
                  CLR.W     3040(A1)
                  CLR.W     3048(A0)
                  CLR.W     3048(A1)
                  CLR.W     3200(A0)
                  CLR.W     3200(A1)
                  CLR.W     3208(A0)
                  CLR.W     3208(A1)
                  CLR.W     3360(A0)
                  CLR.W     3360(A1)
                  CLR.W     3368(A0)
                  CLR.W     3368(A1)
                  CLR.W     3520(A0)
                  CLR.W     3520(A1)
                  CLR.W     3528(A0)
                  CLR.W     3528(A1)
                  CLR.W     3680(A0)
                  CLR.W     3680(A1)
                  CLR.W     3688(A0)
                  CLR.W     3688(A1)
                  CLR.W     3840(A0)
                  CLR.W     3840(A1)
                  CLR.W     3848(A0)
                  CLR.W     3848(A1)
                  CLR.W     4000(A0)
                  CLR.W     4000(A1)
                  CLR.W     4008(A0)
                  CLR.W     4008(A1)
                  CLR.W     4160(A0)
                  CLR.W     4160(A1)
                  CLR.W     4168(A0)
                  CLR.W     4168(A1)
                  CLR.W     4320(A0)
                  CLR.W     4320(A1)
                  CLR.W     4328(A0)
                  CLR.W     4328(A1)
                  CLR.W     4480(A0)
                  CLR.W     4480(A1)
                  CLR.W     4488(A0)
                  CLR.W     4488(A1)
                  CLR.W     4640(A0)
                  CLR.W     4640(A1)
                  CLR.W     4648(A0)
                  CLR.W     4648(A1)
                  CLR.W     4800(A0)
                  CLR.W     4800(A1)
                  CLR.W     4808(A0)
                  CLR.W     4808(A1)
                  CLR.W     4960(A0)
                  CLR.W     4960(A1)
                  CLR.W     4968(A0)
                  CLR.W     4968(A1)
                  LEA       OBJECT,A1 
                  MOVE.L    NEXTSHAPE,D0
                  LSL.L     #4,D0 
                  ADDA.L    D0,A1 
                  CLR.L     D0
                  CLR.L     D1
                  MOVE.W    #$1E78,D1 
                  MOVEA.L   INVIS,A0
                  ADDA.L    D1,A0 
                  MOVE.L    A1,-(A7)
                  BSR       QWIKKY
                  MOVEA.L   (A7)+,A1
                  MOVEA.L   VISSCRN,A0
                  ADDA.L    D1,A0 
                  BSR       QWIKKY
                  CLR.W     YPOS
                  MOVE.W    #5,XPOS 
                  LEA       OBJECT,A0 
                  MOVE.L    CURRSHAPE,D0
                  LSL.L     #4,D0 
                  ADDA.L    D0,A0 
                  LEA       OBJRM,A1
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  MOVE.L    (A0)+,(A1)+ 
                  BRA       NOMOVE
LINEDONE:         MOVE.W    YPOS,D1 
                  MOVEQ     #3,D7 
L003C:            MOVE.W    D1,D0 
                  ADDI.W    #1,D1 
                  CMP.W     #$15,D1 
                  BEQ.B     L003F 
                  MULU      #$C,D0
                  LEA       BOARD,A0
                  ADDA.W    D0,A0 
                  MOVE.L    #$B,D6
L003D:            CMPI.B    #1,(A0)+
                  BNE.B     L003E 
                  DBF       D6,L003D
                  BRA       ISLINE
L003E:            DBF       D7,L003C
L003F:            RTS 
ISLINE:           MOVE.W    #5,D7 
                  MULU      LEVEL,D7
                  ADDI.L    #$A,D7
                  ADD.L     D7,SCORE
                  ADD.L     D7,LEVELOK
                  ADDQ.W    #1,GOTATET
                  SUBQ.W    #1,D1 
                  MOVE.W    D1,XPOS 
                  SUBQ.W    #1,D1 
                  CLR.L     D7
                  MOVE.W    D1,D7 
                  MULU      #$C,D1
                  LEA       BOARD,A0
                  ADDA.W    D1,A0 
L0041:            MOVE.L    (A0),12(A0) 
                  MOVE.L    4(A0),16(A0)
                  MOVE.L    8(A0),20(A0)
                  SUBA.L    #$C,A0
                  DBF       D7,L0041
                  CLR.L     D0
                  CLR.L     D1
                  MOVE.W    XPOS,D1 
                  MOVE.W    D1,D0 
                  MOVE.L    #$A00,D2
                  ADDI.L    #$32,D2 
                  MULU      #$500,D0
                  ADD.L     D0,D2 
                  SUBI.L    #$A0,D2 
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  ADDA.L    D2,A0 
                  ADDA.L    D2,A1 
                  LSL.L     #3,D1 
                  SUBQ.L    #8,D1 
L0042:            MOVE.B    1(A0),1281(A0)
                  MOVE.B    1(A1),1281(A1)
                  MOVE.W    8(A0),1288(A0)
                  MOVE.W    8(A1),1288(A1)
                  MOVE.W    16(A0),1296(A0) 
                  MOVE.W    16(A1),1296(A1) 
                  MOVE.W    24(A0),1304(A0) 
                  MOVE.W    24(A1),1304(A1) 
                  MOVE.W    32(A0),1312(A0) 
                  MOVE.W    32(A1),1312(A1) 
                  MOVE.B    40(A0),1320(A0) 
                  MOVE.B    40(A1),1320(A1) 
                  SUBA.L    #$A0,A0 
                  SUBA.L    #$A0,A1 
                  DBF       D1,L0042
                  RTS 
DISSCORE:         MOVE.L    SCORE,D0
                  LEA       SCOREB,A0 
                  MOVE.L    #$20202020,(A0)+
                  MOVE.W    #$2020,(A0)+
                  CLR.W     (A0)
                  MOVE.L    #$10,D2 
L0044:            CMP.L     #$A,D0
                  BLT.B     L0045 
                  DIVS      #$A,D0
                  MOVE.L    D0,D1 
                  ANDI.L    #$FFFF,D1 
                  LSR.L     D2,D0 
                  ADDI.L    #$30,D0 
                  MOVE.B    D0,-(A0)
                  MOVE.L    D1,D0 
                  BRA.B     L0044 
L0045:            ADDI.L    #$30,D0 
                  MOVE.B    D0,-(A0)
                  LEA       L00F0,A1
                  MOVEA.L   INVIS,A2
                  MOVEA.L   VISSCRN,A3
                  ADDA.L    #$45D0,A2 
                  ADDA.L    #$45D0,A3 
                  MOVE.L    #4,D7 
LOOP1:            LEA       SMFONT,A0 
                  CLR.L     D0
                  MOVE.B    (A1)+,D0
                  LSL.L     #5,D0 
                  ADDA.L    D0,A0 
                  MOVE.W    (A0),(A2) 
                  MOVE.W    (A0)+,(A3)
                  MOVE.W    (A0),160(A2)
                  MOVE.W    (A0)+,160(A3) 
                  MOVE.W    (A0),320(A2)
                  MOVE.W    (A0)+,320(A3) 
                  MOVE.W    (A0),480(A2)
                  MOVE.W    (A0)+,480(A3) 
                  MOVE.W    (A0),640(A2)
                  MOVE.W    (A0)+,640(A3) 
                  MOVE.W    (A0),800(A2)
                  MOVE.W    (A0)+,800(A3) 
                  MOVE.W    (A0),960(A2)
                  MOVE.W    (A0)+,960(A3) 
                  MOVE.W    (A0),1120(A2) 
                  MOVE.W    (A0)+,1120(A3)
                  MOVE.W    (A0),1280(A2) 
                  MOVE.W    (A0)+,1280(A3)
                  MOVE.W    (A0),1440(A2) 
                  MOVE.W    (A0)+,1440(A3)
                  MOVE.W    (A0),1600(A2) 
                  MOVE.W    (A0)+,1600(A3)
                  MOVE.W    (A0),1760(A2) 
                  MOVE.W    (A0)+,1760(A3)
                  MOVE.W    (A0),1920(A2) 
                  MOVE.W    (A0)+,1920(A3)
                  MOVE.W    (A0),2080(A2) 
                  MOVE.W    (A0)+,2080(A3)
                  MOVE.W    (A0),2240(A2) 
                  MOVE.W    (A0)+,2240(A3)
                  MOVE.W    (A0),2400(A2) 
                  MOVE.W    (A0)+,2400(A3)
                  ADDQ.L    #8,A2 
                  ADDQ.L    #8,A3 
                  DBF       D7,LOOP1
                  CMPI.L    #$3E8,LEVELOK 
                  BGE.B     L0047 
                  BRA.B     LRET
L0047:            CLR.L     LEVELOK 
                  ADDQ.W    #1,LEVEL
                  CMPI.W    #7,LEVEL
                  BNE.B     SETLEV
                  MOVE.W    #6,LEVEL
SETLEV:           LEA       L001E(PC),A0
                  CMPI.W    #2,LEVEL
                  BNE.B     L0049 
                  MOVE.W    #$1F,(A0) 
L0049:            CMPI.W    #3,LEVEL
                  BNE.B     L004A 
                  MOVE.W    #$F,(A0)
L004A:            CMPI.W    #4,LEVEL
                  BNE.B     L004B 
                  MOVE.W    #7,(A0) 
L004B:            CMPI.W    #5,LEVEL
                  BNE.B     L004C 
                  MOVE.W    #3,(A0) 
L004C:            CMPI.W    #6,LEVEL
                  BNE.B     LRET
                  MOVE.W    #1,(A0) 
LRET:             MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  ADDA.L    #$2DB0,A0 
                  ADDA.L    #$2DB0,A1 
                  LEA       L013C,A2
                  CLR.L     D0
                  MOVE.W    LEVEL,D0
                  LSL.L     #5,D0 
                  ADDA.L    D0,A2 
                  MOVE.W    (A2),(A0) 
                  MOVE.W    (A2)+,(A1)
                  MOVE.W    (A2),160(A0)
                  MOVE.W    (A2)+,160(A1) 
                  MOVE.W    (A2),320(A0)
                  MOVE.W    (A2)+,320(A1) 
                  MOVE.W    (A2),480(A0)
                  MOVE.W    (A2)+,480(A1) 
                  MOVE.W    (A2),640(A0)
                  MOVE.W    (A2)+,640(A1) 
                  MOVE.W    (A2),800(A0)
                  MOVE.W    (A2)+,800(A1) 
                  MOVE.W    (A2),960(A0)
                  MOVE.W    (A2)+,960(A1) 
                  MOVE.W    (A2),1120(A0) 
                  MOVE.W    (A2)+,1120(A1)
                  MOVE.W    (A2),1280(A0) 
                  MOVE.W    (A2)+,1280(A1)
                  MOVE.W    (A2),1440(A0) 
                  MOVE.W    (A2)+,1440(A1)
                  MOVE.W    (A2),1600(A0) 
                  MOVE.W    (A2)+,1600(A1)
                  MOVE.W    (A2),1760(A0) 
                  MOVE.W    (A2)+,1760(A1)
                  MOVE.W    (A2),1920(A0) 
                  MOVE.W    (A2)+,1920(A1)
                  MOVE.W    (A2),2080(A0) 
                  MOVE.W    (A2)+,2080(A1)
                  MOVE.W    (A2),2240(A0) 
                  MOVE.W    (A2)+,2240(A1)
                  MOVE.W    (A2),2400(A0) 
                  MOVE.W    (A2)+,2400(A1)
                  RTS 
DISOBJ:           MOVEA.L   SPRI2,A0
                  CLR.W     (A0)
                  CLR.W     8(A0) 
                  CLR.W     16(A0)
                  CLR.W     160(A0) 
                  CLR.W     168(A0) 
                  CLR.W     176(A0) 
                  CLR.W     320(A0) 
                  CLR.W     328(A0) 
                  CLR.W     336(A0) 
                  CLR.W     480(A0) 
                  CLR.W     488(A0) 
                  CLR.W     496(A0) 
                  CLR.W     640(A0) 
                  CLR.W     648(A0) 
                  CLR.W     656(A0) 
                  CLR.W     800(A0) 
                  CLR.W     808(A0) 
                  CLR.W     816(A0) 
                  CLR.W     960(A0) 
                  CLR.W     968(A0) 
                  CLR.W     976(A0) 
                  CLR.W     1120(A0)
                  CLR.W     1128(A0)
                  CLR.W     1136(A0)
                  CLR.W     1280(A0)
                  CLR.W     1288(A0)
                  CLR.W     1296(A0)
                  CLR.W     1440(A0)
                  CLR.W     1448(A0)
                  CLR.W     1456(A0)
                  CLR.W     1600(A0)
                  CLR.W     1608(A0)
                  CLR.W     1616(A0)
                  CLR.W     1760(A0)
                  CLR.W     1768(A0)
                  CLR.W     1776(A0)
                  CLR.W     1920(A0)
                  CLR.W     1928(A0)
                  CLR.W     1936(A0)
                  CLR.W     2080(A0)
                  CLR.W     2088(A0)
                  CLR.W     2096(A0)
                  CLR.W     2240(A0)
                  CLR.W     2248(A0)
                  CLR.W     2256(A0)
                  CLR.W     2400(A0)
                  CLR.W     2408(A0)
                  CLR.W     2416(A0)
                  CLR.W     2560(A0)
                  CLR.W     2568(A0)
                  CLR.W     2576(A0)
                  CLR.W     2720(A0)
                  CLR.W     2728(A0)
                  CLR.W     2736(A0)
                  CLR.W     2880(A0)
                  CLR.W     2888(A0)
                  CLR.W     2896(A0)
                  CLR.W     3040(A0)
                  CLR.W     3048(A0)
                  CLR.W     3056(A0)
                  CLR.W     3200(A0)
                  CLR.W     3208(A0)
                  CLR.W     3216(A0)
                  CLR.W     3360(A0)
                  CLR.W     3368(A0)
                  CLR.W     3376(A0)
                  CLR.W     3520(A0)
                  CLR.W     3528(A0)
                  CLR.W     3536(A0)
                  CLR.W     3680(A0)
                  CLR.W     3688(A0)
                  CLR.W     3696(A0)
                  CLR.W     3840(A0)
                  CLR.W     3848(A0)
                  CLR.W     3856(A0)
                  CLR.W     4000(A0)
                  CLR.W     4008(A0)
                  CLR.W     4016(A0)
                  CLR.W     4160(A0)
                  CLR.W     4168(A0)
                  CLR.W     4176(A0)
                  CLR.W     4320(A0)
                  CLR.W     4328(A0)
                  CLR.W     4336(A0)
                  CLR.W     4480(A0)
                  CLR.W     4488(A0)
                  CLR.W     4496(A0)
                  CLR.W     4640(A0)
                  CLR.W     4648(A0)
                  CLR.W     4656(A0)
                  CLR.W     4800(A0)
                  CLR.W     4808(A0)
                  CLR.W     4816(A0)
                  CLR.W     4960(A0)
                  CLR.W     4968(A0)
                  CLR.W     4976(A0)
                  MOVE.L    SPRI1,SPRI2 
                  MOVEA.L   INVIS,A0
                  LEA       OBJRM,A1
                  CLR.L     D0
                  MOVE.W    YPOS,D0 
                  ADDI.W    #2,D0 
                  MULU      #$500,D0
                  ADDA.L    D0,A0 
                  MOVE.W    XPOS,D0 
                  ADDI.W    #$C,D0
                  ANDI.L    #$FE,D0 
                  LSL.L     #2,D0 
                  ADDA.L    D0,A0 
                  MOVE.L    A0,SPRI1
                  MOVE.W    XPOS,D7 
                  ADDI.W    #$C,D7
                  ANDI.W    #1,D7 
                  TST.B     D7
                  BNE       DISOFF
QWIKKY:           MOVEQ     #3,D7 
DISLP1:           MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0051 
                  MOVE.B    #$FF,(A0) 
                  MOVE.B    #$FF,160(A0)
                  MOVE.B    #$FF,320(A0)
                  MOVE.B    #$FF,480(A0)
                  MOVE.B    #$FF,640(A0)
                  MOVE.B    #$FF,800(A0)
                  MOVE.B    #$FF,960(A0)
                  MOVE.B    #$FF,1120(A0) 
L0051:            MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0052 
                  MOVE.B    #$FF,1(A0)
                  MOVE.B    #$FF,161(A0)
                  MOVE.B    #$FF,321(A0)
                  MOVE.B    #$FF,481(A0)
                  MOVE.B    #$FF,641(A0)
                  MOVE.B    #$FF,801(A0)
                  MOVE.B    #$FF,961(A0)
                  MOVE.B    #$FF,1121(A0) 
L0052:            MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0053 
                  MOVE.B    #$FF,8(A0)
                  MOVE.B    #$FF,168(A0)
                  MOVE.B    #$FF,328(A0)
                  MOVE.B    #$FF,488(A0)
                  MOVE.B    #$FF,648(A0)
                  MOVE.B    #$FF,808(A0)
                  MOVE.B    #$FF,968(A0)
                  MOVE.B    #$FF,1128(A0) 
L0053:            MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0054 
                  MOVE.B    #$FF,9(A0)
                  MOVE.B    #$FF,169(A0)
                  MOVE.B    #$FF,329(A0)
                  MOVE.B    #$FF,489(A0)
                  MOVE.B    #$FF,649(A0)
                  MOVE.B    #$FF,809(A0)
                  MOVE.B    #$FF,969(A0)
                  MOVE.B    #$FF,1129(A0) 
L0054:            ADDA.L    #$500,A0
                  DBF       D7,DISLP1 
                  RTS 
DISOFF:           MOVEQ     #3,D7 
DISLP2:           MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0057 
                  MOVE.B    #$FF,1(A0)
                  MOVE.B    #$FF,161(A0)
                  MOVE.B    #$FF,321(A0)
                  MOVE.B    #$FF,481(A0)
                  MOVE.B    #$FF,641(A0)
                  MOVE.B    #$FF,801(A0)
                  MOVE.B    #$FF,961(A0)
                  MOVE.B    #$FF,1121(A0) 
L0057:            MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0058 
                  MOVE.B    #$FF,8(A0)
                  MOVE.B    #$FF,168(A0)
                  MOVE.B    #$FF,328(A0)
                  MOVE.B    #$FF,488(A0)
                  MOVE.B    #$FF,648(A0)
                  MOVE.B    #$FF,808(A0)
                  MOVE.B    #$FF,968(A0)
                  MOVE.B    #$FF,1128(A0) 
L0058:            MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L0059 
                  MOVE.B    #$FF,9(A0)
                  MOVE.B    #$FF,169(A0)
                  MOVE.B    #$FF,329(A0)
                  MOVE.B    #$FF,489(A0)
                  MOVE.B    #$FF,649(A0)
                  MOVE.B    #$FF,809(A0)
                  MOVE.B    #$FF,969(A0)
                  MOVE.B    #$FF,1129(A0) 
L0059:            MOVE.B    (A1)+,D0
                  TST.B     D0
                  BEQ.B     L005A 
                  MOVE.B    #$FF,16(A0) 
                  MOVE.B    #$FF,176(A0)
                  MOVE.B    #$FF,336(A0)
                  MOVE.B    #$FF,496(A0)
                  MOVE.B    #$FF,656(A0)
                  MOVE.B    #$FF,816(A0)
                  MOVE.B    #$FF,976(A0)
                  MOVE.B    #$FF,1136(A0) 
L005A:            ADDA.L    #$500,A0
                  DBF       D7,DISLP2 
                  RTS 
TEXTDIS:          LEA       CURSBUFF,A0 
                  CMPI.L    #0,(A0) 
                  BEQ       CURS1 
                  MOVEA.L   (A0)+,A1
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
                  MOVE.L    (A0)+,(A1)
                  ADDA.L    #$A0,A1 
CURS1:            CMPI.W    #0,TEXSCRL
                  BEQ       CURS2 
                  SUBQ.W    #1,TEXSCRL
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  ADDA.L    #$7F80,A0 
                  ADDA.L    #$7F80,A1 
                  MOVE.L    #$21,D7 
COPLP:            MOVE.W    160(A0),(A0)
                  MOVE.W    160(A0),(A1)
                  MOVE.W    168(A0),8(A0) 
                  MOVE.W    168(A0),8(A1) 
                  MOVE.W    176(A0),16(A0)
                  MOVE.W    176(A0),16(A1)
                  MOVE.W    184(A0),24(A0)
                  MOVE.W    184(A0),24(A1)
                  MOVE.W    192(A0),32(A0)
                  MOVE.W    192(A0),32(A1)
                  MOVE.W    200(A0),40(A0)
                  MOVE.W    200(A0),40(A1)
                  MOVE.W    208(A0),48(A0)
                  MOVE.W    208(A0),48(A1)
                  MOVE.W    216(A0),56(A0)
                  MOVE.W    216(A0),56(A1)
                  MOVE.W    224(A0),64(A0)
                  MOVE.W    224(A0),64(A1)
                  MOVE.W    232(A0),72(A0)
                  MOVE.W    232(A0),72(A1)
                  MOVE.W    240(A0),80(A0)
                  MOVE.W    240(A0),80(A1)
                  MOVE.W    248(A0),88(A0)
                  MOVE.W    248(A0),88(A1)
                  MOVE.W    256(A0),96(A0)
                  MOVE.W    256(A0),96(A1)
                  MOVE.W    264(A0),104(A0) 
                  MOVE.W    264(A0),104(A1) 
                  MOVE.W    272(A0),112(A0) 
                  MOVE.W    272(A0),112(A1) 
                  MOVE.W    280(A0),120(A0) 
                  MOVE.W    280(A0),120(A1) 
                  MOVE.W    288(A0),128(A0) 
                  MOVE.W    288(A0),128(A1) 
                  MOVE.W    296(A0),136(A0) 
                  MOVE.W    296(A0),136(A1) 
                  MOVE.W    304(A0),144(A0) 
                  MOVE.W    304(A0),144(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  DBF       D7,COPLP
                  CMPI.W    #0,TEXSCRL
                  BNE.B     CURS2 
                  CLR.W     TEXTX 
                  MOVE.W    #$CD,TEXTY
CURS2:            SUBI.W    #1,COUNTER2 
                  CMPI.W    #0,COUNTER2 
                  BNE       CURSROUT
                  MOVE.W    #$A,COUNTER2
                  MOVEA.L   A5BAK4,A5 
                  CLR.L     D0
                  CMPI.B    #0,(A5) 
                  BNE.B     L005F 
                  MOVE.L    #INTROTEX,A5BAK4
                  BRA       CURSROUT
L005F:            MOVE.B    (A5)+,D0
                  MOVE.L    A5,A5BAK4 
                  CMP.B     #$A,D0
                  BNE.B     N.1 
                  MOVE.W    TEXTY,D0
                  ADDI.W    #$11,D0 
                  CMP.W     #$F0,D0 
                  BLT       L0060 
                  CLR.W     D0
L0060:            MOVE.W    D0,TEXTY
                  BRA       CURSROUT
N.1:              CMP.B     #$D,D0
                  BNE.B     N.2 
                  MOVE.W    #0,TEXTX
                  BRA       CURSROUT
N.2:              CMP.B     #$B,D0
                  BNE.B     N.3 
                  MOVE.W    #$32,COUNTER2 
                  BRA       CURSROUT
N.3:              CMP.B     #$C,D0
                  BNE.B     N.4 
                  MOVE.W    #$3C,COUNTER2 
                  MOVE.W    #$2D,TEXSCRL
N.4:              LEA       SMFONT,A5 
                  LSL.L     #5,D0 
                  ADDA.L    D0,A5 
                  MOVEA.L   VISSCRN,A0
                  MOVEA.L   INVIS,A1
                  MOVE.W    TEXTY,D0
                  MULU      #$A0,D0 
                  ADDA.L    D0,A0 
                  ADDA.L    D0,A1 
                  CLR.L     D0
                  MOVE.W    TEXTX,D0
                  LSL.W     #3,D0 
                  ADDI.W    #1,TEXTX
                  CMPI.W    #$14,TEXTX
                  BNE.B     L0065 
                  CLR.W     TEXTX 
L0065:            ADDA.L    D0,A0 
                  ADDA.L    D0,A1 
                  CLR.L     D0
                  CLR.L     D1
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A5)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  AND.W     D1,(A1) 
                  AND.W     D1,2(A1)
                  AND.W     D1,4(A1)
                  AND.W     D1,6(A1)
                  OR.W      D0,(A1) 
                  ADDA.L    #$A0,A1 
                  BRA       CURSROUT
CURSROUT:         MOVEA.L   VISSCRN,A0
                  MOVE.W    TEXTY,D0
                  MULU      #$A0,D0 
                  ADDA.L    D0,A0 
                  MOVE.W    TEXTX,D0
                  LSL.W     #3,D0 
                  ADDA.W    D0,A0 
                  MOVE.L    A0,-(A7)
                  LEA       CURSBUFF,A1 
                  MOVE.L    A0,(A1)+
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A0),(A1)+
                  ADDA.L    #$A0,A0 
                  MOVEA.L   (A7)+,A0
                  SUBI.W    #1,FLASHER
                  CMPI.W    #0,FLASHER
                  BNE.B     L0067 
                  MOVE.W    #8,FLASHER
L0067:            CMPI.W    #4,FLASHER
                  BLT       DISRTS
                  LEA       CURSOR,A1 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
                  MOVE.W    (A1)+,D0
                  MOVE.W    D0,D1 
                  NOT.W     D1
                  AND.W     D1,(A0) 
                  AND.W     D1,2(A0)
                  AND.W     D1,4(A0)
                  AND.W     D1,6(A0)
                  OR.W      D0,(A0) 
                  ADDA.L    #$A0,A0 
DISRTS:           RTS 
STARS:            MOVEA.L   A5BAK1,A5 
                  CMPI.W    #$FFFF,424(A5)
                  BNE.B     L006A 
                  LEA       XSPDAT,A5 
L006A:            ADDQ.L    #2,A5 
                  MOVE.L    A5,A5BAK1 
                  SUBQ.L    #2,A5 
                  MOVEA.L   A5BAK2,A4 
                  CMPI.W    #$FFFF,282(A4)
                  BNE.B     L006B 
                  LEA       YSPDAT,A4 
L006B:            ADDQ.L    #4,A4 
                  MOVE.L    A4,A5BAK2 
                  SUBQ.L    #4,A4 
                  ADDQ.W    #1,PICWAIT
                  CMPI.W    #$7D0,PICWAIT 
                  BNE.B     STAR2 
                  CLR.W     PICWAIT 
                  ADDQ.W    #1,PICNUM 
                  CMPI.W    #8,PICNUM 
                  BNE.B     STAR2 
                  CLR.W     PICNUM
STAR2:            CLR.L     D0
                  MOVE.W    PICNUM,D0 
                  LSL.L     #1,D0 
                  LEA       PICCOL,A0 
                  ADDA.L    D0,A0 
                  MOVE.W    (A0),L0110
                  BSR       ANIMAT
                  LEA       STARBUFF,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A0),D0 
                  SWAP      D0
                  MOVE.W    8(A0),D0
                  MOVE.W    (A5),D1 
                  ANDI.L    #$1F,D1 
                  ROR.L     D1,D0 
                  MOVE.W    D0,8(A1)
                  SWAP      D0
                  MOVE.W    D0,(A1) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.W    (A4),D1 
                  ANDI.L    #$1F,D1 
                  MULU      #$A0,D1 
                  LEA       STARBUFF,A0 
                  MOVE.W    #$1F,D7 
STAR.1:           MOVE.W    (A0),D6 
                  MOVE.W    8(A0),D5
                  ADDA.L    #$A0,A0 
                  MOVE.L    (A5),D0 
                  ANDI.L    #$1F,D0 
                  MOVEA.L   INVIS,A1
                  ADDA.L    D1,A1 
                  ADDQ.L    #4,A1 
                  MOVE.W    #5,D0 
STAR.2:           MOVE.W    D6,(A1) 
                  MOVE.W    D5,8(A1)
                  MOVE.W    D6,16(A1) 
                  MOVE.W    D5,24(A1) 
                  MOVE.W    D6,32(A1) 
                  MOVE.W    D5,40(A1) 
                  MOVE.W    D6,48(A1) 
                  MOVE.W    D5,56(A1) 
                  MOVE.W    D6,64(A1) 
                  MOVE.W    D5,72(A1) 
                  MOVE.W    D6,80(A1) 
                  MOVE.W    D5,88(A1) 
                  MOVE.W    D6,96(A1) 
                  MOVE.W    D5,104(A1)
                  MOVE.W    D6,112(A1)
                  MOVE.W    D5,120(A1)
                  MOVE.W    D6,128(A1)
                  MOVE.W    D5,136(A1)
                  MOVE.W    D6,144(A1)
                  MOVE.W    D5,152(A1)
                  ADDA.L    #$1400,A1 
                  DBF       D0,STAR.2 
                  ADDI.L    #$A0,D1 
                  CMP.L     #$1400,D1 
                  BNE.B     STAR.3
                  CLR.L     D1
STAR.3:           DBF       D7,STAR.1 
                  RTS 
ANIMAT:           CMPI.W    #0,ANIMWAIT 
                  BEQ.B     NEWFRAME
                  ADDQ.W    #1,ANIMWAIT 
                  ANDI.W    #7,ANIMWAIT 
                  MOVEA.L   ANIMCURR,A0 
                  RTS 
NEWFRAME:         ADDQ.W    #1,ANIMWAIT 
                  MOVE.W    ANIMNUM,D0
                  ADD.W     ANIMDIR,D0
                  CMP.W     #7,D0 
                  BNE.B     L0072 
                  MOVE.W    #$FFFF,ANIMDIR
                  CMPI.W    #7,PICNUM 
                  BNE.B     L0072 
                  MOVE.W    #0,ANIMNUM
                  CLR.L     D0
L0072:            CMP.W     #0,D0 
                  BNE.B     L0073 
                  MOVE.W    #1,ANIMDIR
L0073:            LEA       PICCY1+34,A0	; L0141
                  CLR.L     D6
                  MOVE.W    PICNUM,D6 
                  MOVE.L    D6,D5 
                  ANDI.L    #4,D6 
                  MULU      #$500,D6
                  ADDA.L    D6,A0 
                  ANDI.L    #3,D5 
                  LSL.L     #1,D5 
                  ADDA.L    D5,A0 
                  MOVE.W    D0,ANIMNUM
                  LSL.L     #4,D0 
                  ADDA.L    D0,A0 
                  MOVE.L    A0,ANIMCURR 
                  RTS 
SCROLLER:         MOVE.W    #$20,D6 
L0075:            MOVEA.L   INVIS,A0
                  ADDA.L    #$8020,A0 
                  MOVE.L    D6,D5 
                  MULU      #$A0,D5 
                  ADDA.L    D5,A0 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  ADDQ.W    #2,A0 
                  MOVE.W    8(A0),(A0)+ 
                  MOVE.L    8(A0),(A0)+ 
                  DBF       D6,L0075
                  MOVEA.L   INVIS,A0
                  MOVEA.L   VISSCRN,A1
                  ADDA.L    #$80B8,A0 
                  ADDA.L    #$80B8,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  MOVE.B    3(A1),2(A0) 
                  MOVE.B    5(A1),4(A0) 
                  MOVE.B    7(A1),6(A0) 
                  ADDA.L    #$A0,A0 
                  ADDA.L    #$A0,A1 
                  CMPI.W    #0,LETTPOS
                  BEQ       NEXTLETTER
LETT.1:           MOVEA.L   CURRLET,A0
                  MOVEA.L   INVIS,A1
                  ADDA.L    #$80B8,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  ADDQ.L    #1,A0 
                  MOVE.B    (A0)+,3(A1) 
                  MOVE.B    (A0)+,5(A1) 
                  MOVE.B    (A0)+,7(A1) 
                  ADDA.L    #$A0,A1 
                  MOVE.L    A0,CURRLET
                  ADDI.W    #1,LETTPOS
                  CMPI.W    #4,LETTPOS
                  BNE.B     L0077 
                  CLR.W     LETTPOS 
L0077:            RTS 
NEXTLETTER:       CLR.L     D1
                  MOVEA.L   TEXTPOS,A0
                  MOVE.B    (A0)+,D1
                  MOVE.L    A0,TEXTPOS
                  CMP.B     #$FF,D1 
                  BNE.B     LETT.2
                  MOVE.L    #TEXT,TEXTPOS 
                  BRA.B     NEXTLETTER
LETT.2:           BSR.B     SPECIALLETT 
                  SUBI.L    #$41,D1 
                  CMP.L     #0,D1 
                  BMI.B     NEXTLETTER
                  MULU      #$200,D1
                  LEA       FONT,A1 
                  ADDA.L    D1,A1 
                  MOVE.L    A1,CURRLET
                  BRA       LETT.1
SPECIALLETT:      CMP.L     #$20,D1 
                  BEQ       L.SPACE 
                  CMP.L     #$2B,D1 
                  BEQ       L.PLUS
                  CMP.L     #$21,D1 
                  BEQ       L.EX
                  CMP.L     #$3F,D1 
                  BEQ       L.QUE 
                  CMP.L     #$2E,D1 
                  BEQ       L.DOT 
                  CMP.L     #$2C,D1 
                  BEQ       L.COMMA 
                  CMP.L     #$28,D1 
                  BEQ       L.OBRAK 
                  CMP.L     #$29,D1 
                  BEQ       L.CBRAK 
                  CMP.L     #$27,D1 
                  BEQ       L.APP 
                  CMP.L     #$3A,D1 
                  BEQ       L.COLON 
                  CMP.L     #$3B,D1 
                  BEQ       L.SEMI
                  CMP.L     #$22,D1 
                  BEQ       L.QUOTE 
                  CMP.L     #$2D,D1 
                  BEQ       L.MINUS 
                  CMP.L     #$30,D1 
                  BGE       L.NUM 
L.RTS:            RTS 
L.NUM:            CMP.L     #$39,D1 
                  BGT.B     L.RTS 
                  SUBI.L    #$30,D1 
                  ADDI.L    #$69,D1 
                  RTS 
L.COLON:          MOVE.L    #$64,D1 
                  RTS 
L.SEMI:           MOVE.L    #$65,D1 
                  RTS 
L.QUOTE:          MOVE.L    #$5D,D1 
                  RTS 
L.MINUS:          MOVE.L    #$5E,D1 
                  RTS 
L.SPACE:          MOVE.L    #$68,D1 
                  RTS 
L.PLUS:           MOVE.L    #$66,D1 
                  RTS 
L.EX:             MOVE.L    #$5F,D1 
                  RTS 
L.QUE:            MOVE.L    #$60,D1 
                  RTS 
L.DOT:            MOVE.L    #$5B,D1 
                  RTS 
L.COMMA:          MOVE.L    #$5C,D1 
                  RTS 
L.OBRAK:          MOVE.L    #$61,D1 
                  RTS 
L.CBRAK:          MOVE.L    #$62,D1 
                  RTS 
L.APP:            MOVE.L    #$63,D1 
                  RTS 
PRESHIFT:         MOVE.W    #$F,D6
                  LEA       L0145,A3
                  LEA       L0144,A2
PRE:              MOVE.L    #$4FF,D7
PRE1:             MOVE.L    (A2)+,(A3)+ 
                  DBF       D7,PRE1 
                  MOVEA.L   A3,A0 
                  SUBA.L    #$1400,A0 
                  MOVEA.L   A0,A4 
                  BSR       SHIFT1
                  MOVEA.L   A4,A0 
                  ADDQ.W    #2,A0 
                  BSR       SHIFT1
                  MOVEA.L   A4,A0 
                  ADDQ.W    #4,A0 
                  BSR       SHIFT1
                  MOVEA.L   A4,A0 
                  ADDQ.W    #6,A0 
                  BSR       SHIFT1
                  DBF       D6,PRE
                  RTS 
SHIFT1:           MOVEQ     #$1F,D7 
SHIFTY:           ROXL      120(A0) 
                  ROXL      112(A0) 
                  ROXL      104(A0) 
                  ROXL      96(A0)
                  ROXL      88(A0)
                  ROXL      80(A0)
                  ROXL      72(A0)
                  ROXL      64(A0)
                  ROXL      56(A0)
                  ROXL      48(A0)
                  ROXL      40(A0)
                  ROXL      32(A0)
                  ROXL      24(A0)
                  ROXL      16(A0)
                  ROXL      8(A0) 
                  ROXL      (A0)
                  ADDA.L    #$A0,A0 
                  DBF       D7,SHIFTY 
                  RTS 
BYTEBEND:         MOVEA.L   A5BAK,A5
                  CMPI.B    #$FF,52(A5) 
                  BNE.B     W.CONT2 
                  LEA       DATALINE,A5 
W.CONT2:          ADDQ.L    #1,A5 
                  MOVE.L    A5,A5BAK
                  SUBQ.L    #1,A5 
                  MOVE.L    #$1F,D7 
                  CLR.L     D2
CLOOP:            CLR.L     D0
                  LEA       L0146,A1
                  MOVE.B    (A5)+,D0
                  ANDI.B    #$F,D0
                  MULU      #$1400,D0 
                  SUBA.L    D0,A1 
                  ADDA.L    D2,A1 
                  MOVEA.L   INVIS,A0
                  ADDA.L    #$7DC0,A0 
                  ADDA.L    D2,A0 
                  ADDI.L    #$A0,D2 
                  MOVE.W    (A1),(A0) 
                  MOVE.W    8(A1),8(A0) 
                  MOVE.W    16(A1),16(A0) 
                  MOVE.W    24(A1),24(A0) 
                  MOVE.W    32(A1),32(A0) 
                  MOVE.W    40(A1),40(A0) 
                  MOVE.W    48(A1),48(A0) 
                  MOVE.W    56(A1),56(A0) 
                  MOVE.W    64(A1),64(A0) 
                  MOVE.W    72(A1),72(A0) 
                  MOVE.W    80(A1),80(A0) 
                  MOVE.W    88(A1),88(A0) 
                  DBF       D7,CLOOP
                  RTS 
SWAPSCRN:         MOVE.L    VISSCRN,D0
                  MOVE.L    INVIS,VISSCRN 
                  MOVE.L    D0,INVIS
                  LSR.W     #8,D0 
                  MOVE.L    D0,$FFFF8200.W
                  RTS 
VBL:              MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVE.B    #1,VBLDONE
                  BSR       MUSIX+8
                  CMPI.W    #1,BLKOUT 
                  BNE.B     L0094 
                  MOVEM.L   PALBLK,D0-D7
                  MOVEM.L   D0-D7,$FFFF8240.W 
                  BRA.B     L0096 
L0094:            MOVE.L    #HBLA,$120.W
                  MOVE.B    #1,$FFFFFA21.W
L0095             EQU       *-2 
                  MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    #TBLRST,A6BAK 
                  MOVEM.L   STEPAL,D0-D7
                  MOVEM.L   D0-D7,$FFFF8240.W 
L0096:            MOVEM.L   (A7)+,A0-A6/D0-D7 
RTE:              RTE 
VBL2:             MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVE.B    #1,VBLDONE
                  BSR       MUSIX+8
                  CMPI.W    #1,BLKOUT 
                  BNE.B     L0099 
                  MOVEM.L   PALBLK,D0-D7
                  MOVEM.L   D0-D7,$FFFF8240.W 
                  BRA.B     L009A 
L0099:            MOVE.L    #FHBLA,$120.W 
                  MOVE.B    #1,$FFFFFA21.W
                  MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    #TBLRST2,A6BAK
                  MOVEM.L   PAL4,D0-D7
                  MOVEM.L   D0-D7,$FFFF8240.W 
L009A:            MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTE 
HBLA:             MOVE.L    A6,-(A7)
                  MOVEA.L   A6BAK,A6
                  MOVE.W    (A6),$FFFF8244.W
                  MOVE.W    (A6)+,$FFFF824C.W 
                  BPL.B     HBLA1 
                  CLR.B     $FFFFFA1B.W 
                  MOVE.W    (A6)+,$FFFFFA20.W 
                  BNE.B     HBLA1 
                  MOVE.B    #4,$FFFFFA21.W
                  MOVE.L    #NOBORDER,$120.W
HBLA1:            MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    A6,A6BAK
                  MOVEA.L   (A7)+,A6
                  RTE 
NOBORDER:         MOVEM.L   A6/A0/D0,-(A7)
                  MOVEA.L   A6BAK,A6
                  MOVEQ     #0,D0 
                  CLR.B     $FFFFFA1B.W 
HBLE1:            MOVE.B    $FFFF8209.L,D0
                  CMP.B     #$E0,D0 
                  BLS.B     HBLE1 
                  LEA       L0095(PC),A0
                  JMP       0(A0,D0.W)
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
L009F:            NOP 
                  NOP 
                  NOP 
                  NOP 
                  MOVE.W    (A6)+,$FFFF8240.W 
                  MOVE.B    #0,$FFFF820A.W
                  NOP 
                  NOP 
                  NOP 
                  MOVE.B    #2,$FFFF820A.W
                  MOVE.L    #LHBLA,$120.W 
                  MOVE.B    #8,$FFFFFA1B.W
                  MOVEM.L   D0-D7,-(A7) 
                  MOVEM.L   PAL3,D0-D7
                  MOVEM.L   D0-D7,$FFFF8240.W 
                  MOVEM.L   (A7)+,D0-D7 
                  MOVE.L    A6,A6BAK
                  MOVEM.L   (A7)+,A6/A0/D0
                  RTE 
LHBLA:            MOVE.L    A6,-(A7)
                  MOVEA.L   A6BAK,A6
                  MOVE.W    (A6)+,$FFFF8240.L 
                  BPL.B     LHBLA1
                  CLR.B     $FFFFFA1B.W 
                  MOVE.W    (A6)+,$FFFFFA20.W 
                  BNE.B     LHBLA1
                  MOVE.B    #4,$FFFFFA21.W
                  MOVE.L    #LOI,$120.W 
LHBLA1:           MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    A6,A6BAK
                  MOVEA.L   (A7)+,A6
                  RTE 
FHBLA:            MOVE.L    A6,-(A7)
                  MOVEA.L   A6BAK,A6
                  MOVE.W    (A6)+,$FFFF8240.W 
                  BPL.B     FHBLA1
                  CLR.B     $FFFFFA1B.W 
                  MOVE.W    (A6)+,$FFFFFA20.W 
                  BNE.B     FHBLA1
                  MOVE.B    #4,$FFFFFA21.W
                  MOVE.L    #NOBORDER1,$120.W 
FHBLA1:           MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    A6,A6BAK
                  MOVEA.L   (A7)+,A6
                  RTE 
NOBORDER1:        MOVEM.L   A6/A0/D0,-(A7)
                  MOVEA.L   A6BAK,A6
                  MOVEQ     #0,D0 
                  CLR.B     $FFFFFA1B.W 
HBLF1:            MOVE.B    $FFFF8209.L,D0
                  CMP.B     #$E0,D0 
                  BLS.B     HBLF1 
                  LEA       L009F(PC),A0
                  JMP       0(A0,D0.W)
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  NOP 
                  MOVE.W    (A6)+,$FFFF8240.W 
                  MOVE.B    #0,$FFFF820A.W
                  NOP 
                  NOP 
                  NOP 
                  MOVE.B    #2,$FFFF820A.W
                  MOVE.L    #LHBLF,$120.W 
                  MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    A6,A6BAK
                  MOVEM.L   (A7)+,A6/A0/D0
                  RTE 
LHBLF:            MOVE.L    A6,-(A7)
                  MOVEA.L   A6BAK,A6
                  MOVE.W    (A6)+,$FFFF8242.W 
                  BPL.B     LHBLF1
                  CLR.B     $FFFFFA1B.W 
                  MOVE.W    (A6)+,$FFFFFA20.W 
                  BNE.B     LHBLF1
                  MOVE.B    #4,$FFFFFA21.W
                  MOVE.L    #LOI,$120.W 
LHBLF1:           MOVE.B    #8,$FFFFFA1B.W
                  MOVE.L    A6,A6BAK
                  MOVEA.L   (A7)+,A6
                  RTE 
LOI:              CLR.B     $FFFFFA1B.W 
                  RTE 
CLRHBL:           MOVE.W    #8,-(A7)
                  MOVE.W    #$1A,-(A7) 	;JDISINT
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  RTS 
DEPACK:           MOVEM.L   D0-D7,-(A7) 
                  MOVEM.L   A0-A6,-(A7) 
                  CMPI.L    #$49636521,(A0)+
                  BNE.B     ICE2_07 
                  MOVE.L    (A0)+,D0
                  LEA       -8(A0,D0.L),A5
                  MOVE.L    (A0)+,(A7)
                  LEA       108(A0),A4
                  MOVEA.L   A4,A6 
                  ADDA.L    (A7),A6 
                  MOVEA.L   A6,A3 
                  MOVEA.L   A6,A1 
                  LEA       DECRUN(PC),A2 
                  MOVEQ     #$77,D0 
ICE2_00:          MOVE.B    -(A1),-(A2) 
                  DBF       D0,ICE2_00
                  BSR       ICE2_0C 
                  BSR.B     ICE2_08 
                  BSR       ICE2_10 
                  BCC.B     ICE2_04 
                  MOVEA.L   A3,A1 
                  MOVE.W    #$F9F,D7
ICE2_01:          MOVEQ     #3,D6 
ICE2_02:          MOVE.W    -(A1),D4
                  MOVEQ     #3,D5 
ICE2_03:          ADD.W     D4,D4 
                  ADDX.W    D0,D0 
                  ADD.W     D4,D4 
                  ADDX.W    D1,D1 
                  ADD.W     D4,D4 
                  ADDX.W    D2,D2 
                  ADD.W     D4,D4 
                  ADDX.W    D3,D3 
                  DBF       D5,ICE2_03
                  DBF       D6,ICE2_02
                  MOVEM.W   D0-D3,(A1)
                  DBF       D7,ICE2_01
ICE2_04:          MOVE.L    (A7),D0 
                  LEA       -120(A4),A1 
ICE2_05:          MOVE.B    (A4)+,(A1)+ 
                  DBF       D0,ICE2_05
                  SUBI.L    #$10000,D0
                  BPL.B     ICE2_05 
                  MOVEQ     #$77,D0 
                  LEA       DECRUN(PC),A2 
ICE2_06:          MOVE.B    -(A2),-(A3) 
                  DBF       D0,ICE2_06
ICE2_07:          MOVEM.L   (A7)+,D0-D7 
                  MOVEM.L   (A7)+,A0-A6 
                  RTS 
ICE2_08:          BSR.B     ICE2_10 
                  BCC.B     ICE2_0B 
                  MOVEQ     #0,D1 
                  BSR.B     ICE2_10 
                  BCC.B     ICE2_0A 
                  LEA       ICE2_1E(PC),A1
                  MOVEQ     #4,D3 
ICE2_09:          MOVE.L    -(A1),D0
                  BSR.B     ICE2_13 
                  SWAP      D0
                  CMP.W     D0,D1 
                  DBNE      D3,ICE2_09
                  ADD.L     20(A1),D1 
ICE2_0A:          MOVE.B    -(A5),-(A6) 
                  DBF       D1,ICE2_0A
ICE2_0B:          CMPA.L    A4,A6 
                  BGT.B     ICE2_16 
                  RTS 
ICE2_0C:          MOVEQ     #3,D0 
ICE2_0D:          MOVE.B    -(A5),D7
                  ROR.L     #8,D7 
                  DBF       D0,ICE2_0D
                  RTS 
ICE2_0E:          MOVE.W    A5,D7 
                  BTST      #0,D7 
                  BNE.B     ICE2_0F 
                  MOVE.L    -(A5),D7
                  ADDX.L    D7,D7 
                  BRA.B     ICE2_15 
ICE2_0F:          MOVE.L    -5(A5),D7 
                  LSL.L     #8,D7 
                  MOVE.B    -(A5),D7
                  SUBQ.L    #3,A5 
                  ADD.L     D7,D7 
                  BSET      #0,D7 
                  BRA.B     ICE2_15 
ICE2_10:          ADD.L     D7,D7 
                  BEQ.B     ICE2_11 
                  RTS 
ICE2_11:          MOVE.W    A5,D7 
                  BTST      #0,D7 
                  BNE.B     ICE2_12 
                  MOVE.L    -(A5),D7
                  ADDX.L    D7,D7 
                  RTS 
ICE2_12:          MOVE.L    -5(A5),D7 
                  LSL.L     #8,D7 
                  MOVE.B    -(A5),D7
                  SUBQ.L    #3,A5 
                  ADD.L     D7,D7 
                  BSET      #0,D7 
                  RTS 
ICE2_13:          MOVEQ     #0,D1 
ICE2_14:          ADD.L     D7,D7 
                  BEQ.B     ICE2_0E 
ICE2_15:          ADDX.W    D1,D1 
                  DBF       D0,ICE2_14
                  RTS 
ICE2_16:          LEA       ICE2_1F(PC),A1
                  MOVEQ     #3,D2 
ICE2_17:          BSR.B     ICE2_10 
                  DBCC      D2,ICE2_17
                  MOVEQ     #0,D4 
                  MOVEQ     #0,D1 
                  MOVE.B    1(A1,D2.W),D0 
                  EXT.W     D0
                  BMI.B     ICE2_18 
                  BSR.B     ICE2_13 
ICE2_18:          MOVE.B    6(A1,D2.W),D4 
                  ADD.W     D1,D4 
                  BEQ.B     ICE2_1A 
                  LEA       ICE2_20(PC),A1
                  MOVEQ     #1,D2 
ICE2_19:          BSR.B     ICE2_10 
                  DBCC      D2,ICE2_19
                  MOVEQ     #0,D1 
                  MOVE.B    1(A1,D2.W),D0 
                  EXT.W     D0
                  BSR.B     ICE2_13 
                  ADD.W     D2,D2 
                  ADD.W     6(A1,D2.W),D1 
                  BRA.B     ICE2_1C 
ICE2_1A:          MOVEQ     #0,D1 
                  MOVEQ     #5,D0 
                  MOVEQ     #0,D2 
                  BSR.B     ICE2_10 
                  BCC.B     ICE2_1B 
                  MOVEQ     #8,D0 
                  MOVEQ     #$40,D2 
ICE2_1B:          BSR.B     ICE2_13 
                  ADD.W     D2,D1 
ICE2_1C:          LEA       2(A6,D4.W),A1 
                  ADDA.W    D1,A1 
                  MOVE.B    -(A1),-(A6) 
ICE2_1D:          MOVE.B    -(A1),-(A6) 
                  DBF       D4,ICE2_1D
                  BRA       ICE2_08 
                  DC.B      $7F,$FF,$00,$0E,$00,$FF,$00,$07 
                  DC.B      $00,$07,$00,$02,$00,$03,$00,$01 
                  DC.B      $00,$03,$00,$01 
ICE2_1E:          DC.B      $00,$00,$01,$0D,$00,$00,$00,$0E 
                  DC.B      $00,$00,$00,$07,$00,$00,$00,$04 
                  DC.B      $00,$00,$00,$01 
ICE2_1F:          DC.B      $09,$01,$00,$FF,$FF,$08,$04,$02 
                  DC.B      $01,$00 
ICE2_20:          DC.B      $0B,$04,$07,$00,$01,' ',$00,$00 
                  DC.B      $00,' ',$00,$00,$00,$00,$00,$00 
                  DCB.W     57,0
DECRUN:           MOVEM.L   A0-A6/D0-D7,-(A7) 
                  CMPI.L    #$49636521,(A0)+
                  BNE.B     ICE_03
                  MOVE.L    (A0)+,D0
                  LEA       -8(A0,D0.L),A5
                  MOVE.L    (A0)+,(A7)
                  MOVEA.L   A1,A4 
                  MOVEA.L   A1,A6 
                  ADDA.L    (A7),A6 
                  MOVEA.L   A6,A3 
                  BSR.B     ICE_08
                  BSR.B     ICE_04
                  BSR       ICE_0C
                  BCC.B     ICE_03
                  MOVE.W    #$F9F,D7
ICE_00:           MOVEQ     #3,D6 
ICE_01:           MOVE.W    -(A3),D4
                  MOVEQ     #3,D5 
ICE_02:           ADD.W     D4,D4 
                  ADDX.W    D0,D0 
                  ADD.W     D4,D4 
                  ADDX.W    D1,D1 
                  ADD.W     D4,D4 
                  ADDX.W    D2,D2 
                  ADD.W     D4,D4 
                  ADDX.W    D3,D3 
                  DBF       D5,ICE_02 
                  DBF       D6,ICE_01 
                  MOVEM.W   D0-D3,(A3)
                  DBF       D7,ICE_00 
ICE_03:           MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
ICE_04:           BSR.B     ICE_0C
                  BCC.B     ICE_07
                  MOVEQ     #0,D1 
                  BSR.B     ICE_0C
                  BCC.B     ICE_06
                  LEA       ICE_1A(PC),A1 
                  MOVEQ     #4,D3 
ICE_05:           MOVE.L    -(A1),D0
                  BSR.B     ICE_0F
                  SWAP      D0
                  CMP.W     D0,D1 
                  DBNE      D3,ICE_05 
                  ADD.L     20(A1),D1 
ICE_06:           MOVE.B    -(A5),-(A6) 
                  DBF       D1,ICE_06 
ICE_07:           CMPA.L    A4,A6 
                  BGT.B     ICE_12
                  RTS 
ICE_08:           MOVEQ     #3,D0 
ICE_09:           MOVE.B    -(A5),D7
                  ROR.L     #8,D7 
                  DBF       D0,ICE_09 
                  RTS 
ICE_0A:           MOVE.W    A5,D7 
                  BTST      #0,D7 
                  BNE.B     ICE_0B
                  MOVE.L    -(A5),D7
                  ADDX.L    D7,D7 
                  BRA.B     ICE_11
ICE_0B:           MOVE.L    -5(A5),D7 
                  LSL.L     #8,D7 
                  MOVE.B    -(A5),D7
                  SUBQ.L    #3,A5 
                  ADD.L     D7,D7 
                  BSET      #0,D7 
                  BRA.B     ICE_11
ICE_0C:           ADD.L     D7,D7 
                  BEQ.B     ICE_0D
                  RTS 
ICE_0D:           MOVE.W    A5,D7 
                  BTST      #0,D7 
                  BNE.B     ICE_0E
                  MOVE.L    -(A5),D7
                  ADDX.L    D7,D7 
                  RTS 
ICE_0E:           MOVE.L    -5(A5),D7 
                  LSL.L     #8,D7 
                  MOVE.B    -(A5),D7
                  SUBQ.L    #3,A5 
                  ADD.L     D7,D7 
                  BSET      #0,D7 
                  RTS 
ICE_0F:           MOVEQ     #0,D1 
ICE_10:           ADD.L     D7,D7 
                  BEQ.B     ICE_0A
ICE_11:           ADDX.W    D1,D1 
                  DBF       D0,ICE_10 
                  RTS 
ICE_12:           LEA       ICE_1B(PC),A1 
                  MOVEQ     #3,D2 
ICE_13:           BSR.B     ICE_0C
                  DBCC      D2,ICE_13 
                  MOVEQ     #0,D4 
                  MOVEQ     #0,D1 
                  MOVE.B    1(A1,D2.W),D0 
                  EXT.W     D0
                  BMI.B     ICE_14
                  BSR.B     ICE_0F
ICE_14:           MOVE.B    6(A1,D2.W),D4 
                  ADD.W     D1,D4 
                  BEQ.B     ICE_16
                  LEA       ICE_1C(PC),A1 
                  MOVEQ     #1,D2 
ICE_15:           BSR.B     ICE_0C
                  DBCC      D2,ICE_15 
                  MOVEQ     #0,D1 
                  MOVE.B    1(A1,D2.W),D0 
                  EXT.W     D0
                  BSR.B     ICE_0F
                  ADD.W     D2,D2 
                  ADD.W     6(A1,D2.W),D1 
                  BRA.B     ICE_18
ICE_16:           MOVEQ     #0,D1 
                  MOVEQ     #5,D0 
                  MOVEQ     #0,D2 
                  BSR.B     ICE_0C
                  BCC.B     ICE_17
                  MOVEQ     #8,D0 
                  MOVEQ     #$40,D2 
ICE_17:           BSR.B     ICE_0F
                  ADD.W     D2,D1 
ICE_18:           LEA       2(A6,D4.W),A1 
                  ADDA.W    D1,A1 
                  MOVE.B    -(A1),-(A6) 
ICE_19:           MOVE.B    -(A1),-(A6) 
                  DBF       D4,ICE_19 
                  BRA       ICE_04
                  DC.B      $7F,$FF,$00,$0E,$00,$FF,$00,$07 
                  DC.B      $00,$07,$00,$02,$00,$03,$00,$01 
                  DC.B      $00,$03,$00,$01 
ICE_1A:           DC.B      $00,$00,$01,$0D,$00,$00,$00,$0E 
                  DC.B      $00,$00,$00,$07,$00,$00,$00,$04 
                  DC.B      $00,$00,$00,$01 
ICE_1B:           DC.B      $09,$01,$00,$FF,$FF,$08,$04,$02 
                  DC.B      $01,$00 
ICE_1C:           DC.B      $0B,$04,$07,$00,$01,' ',$00,$00 
                  DC.B      $00,' ' 
	EVEN




 DATA

LEVEL:            DC.W      1 
LEVELOK:          DCB.W     2,0 
TETCNT:           DC.B      $00,$00 
GOTATET:          DC.B      $00,$00 
SCORE:            DC.L      1 
SCOREB:           DC.B      0 
L00F0:            DC.L      0
HISCORE:          DC.W      3 
SPRI1:            DC.L      1
SPRI2:            DC.L      1
XPOS:             DC.W      5 
YPOS:             DC.W      0
PICNUM:           DC.W      0 
PICWAIT:          DC.W      0 
NEXTSHAPE:        DC.L      1
CURRSHAPE:        DC.L      1
URDEAD:           DC.W      0
GLINT:            DC.W      0 
ROTRM:            DC.W      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0000,$0000,$0000,$0000,$0001 
BOARD:            DC.W      $0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000 
                  DC.W      $0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000 
                  DC.W      $0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001 
                  DC.W      $0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000 
                  DC.W      $0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000 
                  DC.W      $0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0001 
                  DC.W      $0101,$0101,$0101,$0101,$0101,$0101 
OBJRM:            DC.W      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 
OBJECT:           DC.W      $0000,$0000,$0001,$0000,$0101,$0100,$0000,$0000,$0000,$0000,$0000,$0100,$0101,$0100,$0000,$0000,$0000,$0000,$0001,$0100 
                  DC.W      $0001,$0000,$0001,$0000,$0000,$0000,$0001,$0100,$0001,$0100,$0000,$0000,$0000,$0000,$0101,$0101,$0000,$0000,$0000,$0000 
                  DC.W      $0000,$0000,$0001,$0100,$0101,$0000,$0000,$0000,$0000,$0000,$0101,$0000,$0001,$0100,$0000,$0000,$0000,$0000,$0000,$0100 
                  DC.W      $0101,$0100,$0000,$0000 
TBLRST:           DC.W      $F000,$0001,$F700,$0028,$F700,$0006,$0710,$0720,$0730,$0740,$0750,$0760,$0770,$0670,$0570,$0470,$0370,$0270,$0170,$0070 
                  DC.W      $0071,$0072,$0073,$0074,$0075,$0076,$0077,$0077,$F000,$000F,$F000,$0000,$0000,$F001,$0002,$0002,$0003,$0004,$0005,$0006 
                  DC.W      $0007,$0006,$0005,$0004,$0003,$0002,$0001,$F000,$0000 
TBLRST2:          DC.W      $F000,$00C2,$F000,$0000,$0000,$F216,$0002,$0316,$0416,$0517,$0617,$0716,$0715,$0714,$0713,$0712,$0722,$0731,$0741,$0731 
                  DC.W      $0721,$0722,$0723,$0724,$F000,$0000 
SVE70:            DC.L      1
SVE118:           DC.L      2 
SVEIERB:          DC.B      0 
SVETBDR:          DC.B      0 
SVEIERA:          DC.B      0 
SVEIMRA:          DC.B      0 
SVETBCR:          DC.B      0 
SVEVR:            DC.B      0 
SAVESP:           DC.L      1
VBLDONE:          DC.W      0
MUSIX:            INCBIN    'MUSIX2.DAT'
GEMPAL:           DC.W      $0777,$0700,$0070,$0000,$0111,$0222,$0333,$0444,$0555,$0000,$0001,$0010,$0100,$0200,$0020,$0002 
STEPAL:           DC.W      $0000,$0777,$0AAA,$0070 
L0110:            DC.W      $0330,$0777,$0AAA,$0070,$0777,$0444,$0334,$0555,$0777,$0444,$0334,$0555 
PAL3:             DC.W      $0000 
L0112:            DC.W      $0040,$0300,$0300,$0400,$0400,$0510,$0510,$0520,$0520,$0630,$0630,$0640,$0640,$0750,$0750 
PAL4:             DC.W      $0000,$0FFF,$0EEE,$0EEE,$0DDD,$0CCC,$0FF0,$0FD3,$0FE2,$003F 
L0114:            DCB.W     6,0 
PICCOL:           DC.B      $05,$00,$00,'@',$03,'3',$00,$05 
                  DC.B      $03,'0',$03,$03,$00,'D',$04,'"' 
PALBLK:           DCB.W     16,0
BLKOUT:           DC.B      $00,$00 
PRESS1:           DC.B      $00,$00 
PRESS2:           DC.B      $00,$00 
VISSCRN:          DCB.W     2,0 
INVIS:            DCB.W     2,0 
SCREENBASE:       DCB.W     2,0 
OLDREZ:           DCB.W     17,0
CURRLET:          DCB.W     2,0 
LETTPOS:          DC.B      $00,$00 
TEXTPOS:          DCB.W     4,0 
                  DC.B      $99,' ' 
COUNTER:          DC.B      $00,$00 
COUNTER2:         DC.B      $00,$0A 
COUNTER3:         DC.B      $00,$0A 
TEXSCRL:          DC.B      $00,$00 
FLASHER:          DC.B      $00,$08 
A5BAK:            DC.L      1 
A5BAK1:           DC.L      1 
A5BAK2:           DC.L      1 
A5BAK4:           DC.L      1 
A6BAK:            DC.L      1
ANIMCURR:         DC.L      1 
ANIMWAIT:         DC.B      $00,$00 
ANIMDIR:          DC.B      $00,$01 
ANIMNUM:          DC.B      $00,$00 
PAUSEON:          DC.B      $00,$00 
PAUSEW:           DC.B      $00,$00 
TEXTX:            DC.B      $00,$00 
TEXTY:            DC.B      $00,$CD 
XSPDAT:           DC.W      $00A0,$00A4,$00A8,$00AC,$00B1,$00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D2,$00D6,$00DA,$00DE,$00E2,$00E5,$00E9,$00EC 
                  DC.W      $00F0,$00F3,$00F7,$00FA,$00FD,$0100,$0103,$0105,$0108,$010A,$010D,$010F,$0111,$0113,$0115,$0117,$0119,$011A,$011C,$011D 
                  DC.W      $011E,$011F,$0120,$0120,$0121,$0121,$0121,$0121,$0121,$0121,$0121,$0120,$0120,$011F,$011E,$011D,$011C,$011B,$0119,$0117 
                  DC.W      $0116,$0114,$0112,$0110,$010D,$010B,$0109,$0106,$0103,$0100,$00FE,$00FA,$00F7,$00F4,$00F1,$00ED,$00EA,$00E6,$00E3,$00DF 
                  DC.W      $00DB,$00D7,$00D3,$00CF,$00CB,$00C7,$00C3,$00BF,$00BA,$00B6,$00B2,$00AE,$00A9,$00A5,$00A1,$009C,$0098,$0094,$008F,$008B 
                  DC.W      $0087,$0082,$007E,$007A,$0076,$0072,$006E,$006A,$0066,$0062,$005E,$005B,$0057,$0053,$0050,$004D,$0049,$0046,$0043,$0040 
                  DC.W      $003D,$003A,$0038,$0035,$0033,$0030,$002E,$002C,$002A,$0028,$0027,$0025,$0024,$0023,$0021,$0020,$0020,$001F,$001E,$001E 
                  DC.W      $001E,$001E,$001E,$001E,$001E,$001E,$001F,$0020,$0021,$0022,$0023,$0024,$0026,$0027,$0029,$002B,$002D,$002F,$0031,$0033 
                  DC.W      $0036,$0038,$003B,$003E,$0041,$0044,$0047,$004A,$004D,$0051,$0054,$0058,$005C,$005F,$0063,$0067,$006B,$006F,$0073,$0077 
                  DC.W      $007B,$007F,$0084,$0088,$008C,$0090,$0095,$0099,$009D,$00A2,$00A6,$00AA,$00AF,$00B3,$00B7,$00BB,$00C0,$00C4,$00C8,$00CC 
                  DC.W      $00D0,$00D4,$00D8,$00DC,$00E0,$00E3,$00E7,$00EB,$00EE,$00F2,$00F5,$00F8,$00FB,$00FE,$0101,$0104,$0107,$0109,$010C,$010E 
                  DC.W      $0110,$0112,$0114,$0116,$0118,$0119,$011B,$011C,$011D,$011E,$011F,$0120,$0121,$0121,$0121,$0121,$0121,$0121,$0121,$0121 
                  DC.W      $0120,$011F,$011F,$011E,$011C,$011B,$011A,$0118,$0117,$0115,$0113,$0111,$010F,$010C,$010A,$0107,$0105,$0102,$00FF,$00FC 
                  DC.W      $00F9,$00F6,$00F2,$00EF,$00EC,$00E8,$00E4,$00E1,$00DD,$00D9,$00D5,$00D1,$00CD,$00C9,$00C5,$00C1,$00BC,$00B8,$00B4,$00B0 
                  DC.W      $00AB,$00A7,$00A3,$009E,$009A,$0096,$0091,$008D,$0089,$0085,$0080,$007C,$0078,$0074,$0070,$006C,$0068,$0064,$0060,$005C 
                  DC.W      $0059,$0055,$0052,$004E,$004B,$0048,$0045,$0041,$003F,$003C,$0039,$0036,$0034,$0032,$002F,$002D,$002B,$0029,$0028,$0026 
                  DC.W      $0024,$0023,$0022,$0021,$0020,$001F,$001F,$001E,$001E,$001E,$001E,$001E,$001E,$001E,$001F,$001F,$0020,$0021,$0022,$0023 
                  DC.W      $0025,$0026,$0028,$002A,$002C,$002E,$0030,$0032,$0035,$0037,$003A,$003C,$003F,$0042,$0045,$0049,$004C,$004F,$0053,$0056 
                  DC.W      $005A,$005D,$0061,$0065,$0069,$006D,$0071,$0075,$0079,$007D,$0081,$0086,$008A,$008E,$0093,$0097,$009B,$00A0,$00A4,$00A8 
                  DC.W      $00AD,$00B1,$00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D2,$00D6,$00DA,$00DE,$00E2,$00E5,$00E9,$00EC,$00F0,$00F3,$00F7 
                  DC.W      $00FA,$FFFF,$FFFF 
YSPDAT:           DC.W      $0078,$0079,$007B,$007D,$007E,$0080,$0082,$0083,$0085,$0087,$0088,$008A,$008C,$008D,$008F,$0090,$0092,$0094,$0095,$0096 
                  DC.W      $0098,$0099,$009B,$009C,$009D,$009F,$00A0,$00A1,$00A3,$00A4,$00A5,$00A6,$00A7,$00A8,$00A9,$00AA,$00AB,$00AC,$00AD,$00AD 
                  DC.W      $00AE,$00AF,$00AF,$00B0,$00B1,$00B1,$00B2,$00B2,$00B2,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3 
                  DC.W      $00B3,$00B3,$00B2,$00B2,$00B2,$00B1,$00B1,$00B0,$00AF,$00AF,$00AE,$00AD,$00AD,$00AC,$00AB,$00AA,$00A9,$00A8,$00A7,$00A6 
                  DC.W      $00A5,$00A4,$00A2,$00A1,$00A0,$009F,$009D,$009C,$009B,$0099,$0098,$0096,$0095,$0093,$0092,$0090,$008F,$008D,$008C,$008A 
                  DC.W      $0088,$0087,$0085,$0083,$0082,$0080,$007E,$007D,$007B,$0079,$0077,$0076,$0074,$0072,$0071,$006F,$006D,$006C,$006A,$0068 
                  DC.W      $0067,$0065,$0063,$0062,$0060,$005E,$005D,$005B,$005A,$0058,$0057,$0056,$0054,$0053,$0051,$0050,$004F,$004E,$004C,$004B 
                  DC.W      $004A,$0049,$0048,$0047,$0046,$0045,$0044,$0043,$0042,$0042,$0041,$0040,$0040,$003F,$003E,$003E,$003D,$003D,$003D,$003C 
                  DC.W      $003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003D,$003D,$003E,$003E,$003E,$003F,$0040,$0040 
                  DC.W      $0041,$0042,$0042,$0043,$0044,$0045,$0046,$0047,$0048,$0049,$004A,$004B,$004D,$004E,$004F,$0050,$0052,$0053,$0054,$0056 
                  DC.W      $0057,$0059,$005A,$005C,$005D,$005F,$0060,$0062,$0063,$0065,$0067,$0068,$006A,$006C,$006D,$006F,$0071,$0073,$0074,$0076 
                  DC.W      $0078,$0079,$007B,$007D,$007E,$0080,$0082,$0084,$0085,$0087,$0089,$008A,$008C,$008D,$008F,$0091,$0092,$0094,$0095,$0097 
                  DC.W      $0098,$009A,$009B,$009C,$009E,$009F,$00A0,$00A1,$00A3,$00A4,$00A5,$00A6,$00A7,$00A8,$00A9,$00AA,$00AB,$00AC,$00AD,$00AD 
                  DC.W      $00AE,$00AF,$00AF,$00B0,$00B1,$00B1,$00B2,$00B2,$00B2,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3 
                  DC.W      $00B3,$00B3,$00B2,$00B2,$00B1,$00B1,$00B1,$00B0,$00AF,$00AF,$00AE,$00AD,$00AC,$00AC,$00AB,$00AA,$00A9,$00A8,$00A7,$00A6 
                  DC.W      $00A5,$00A4,$00A2,$00A1,$00A0,$009F,$009D,$009C,$009B,$0099,$0098,$0096,$0095,$0093,$0092,$0090,$008F,$008D,$008B,$008A 
                  DC.W      $0088,$0087,$0085,$0083,$0082,$0080,$007E,$007C,$007B,$0079,$0077,$0076,$0074,$0072,$0070,$006F,$006D,$006B,$006A,$0068 
                  DC.W      $0066,$0065,$0063,$0062,$0060,$005E,$005D,$005B,$005A,$0058,$0057,$0055,$0054,$0053,$0051,$0050,$004F,$004E,$004C,$004B 
                  DC.W      $004A,$0049,$0048,$0047,$0046,$0045,$0044,$0043,$0042,$0042,$0041,$0040,$003F,$003F,$003E,$003E,$003D,$003D,$003D,$003C 
                  DC.W      $003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C,$003D,$003D,$003E,$003E,$003F,$003F,$0040,$0040 
                  DC.W      $0041,$0042,$0043,$0043,$0044,$0045,$0046,$0047,$0048,$0049,$004A,$004B,$004D,$004E,$004F,$0050,$0052,$0053,$0054,$0056 
                  DC.W      $0057,$0059,$005A,$005C,$005D,$005F,$0060,$0062,$0064,$0065,$0067,$0069,$006A,$006C,$006E,$006F,$0071,$0073,$0074,$0076 
                  DC.W      $0078,$007A,$007B,$007D,$007F,$0080,$0082,$0084,$0085,$0087,$0089,$008A,$008C,$008E,$008F,$0091,$0092,$0094,$0095,$0097 
                  DC.W      $0098,$009A,$009B,$009C,$009E,$009F,$00A0,$00A2,$00A3,$00A4,$00A5,$00A6,$00A7,$00A8,$00A9,$00AA,$00AB,$00AC,$00AD,$00AD 
                  DC.W      $00AE,$00AF,$00B0,$00B0,$00B1,$00B1,$00B2,$00B2,$00B2,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3 
                  DC.W      $00B3,$00B3,$00B2,$00B2,$00B1,$00B1,$00B0,$00B0,$00AF,$00AF,$00AE,$00AD,$00AC,$00AC,$00AB,$00AA,$00A9,$00A8,$00A7,$00A6 
                  DC.W      $00A5,$00A3,$00A2,$00A1,$00A0,$009F,$009D,$009C,$009A,$0099,$0098,$0096,$0095,$0093,$0092,$0090,$008F,$008D,$008B,$008A 
                  DC.W      $0088,$0086,$0085,$0083,$0081,$0080,$007E,$007C,$007B,$0079,$0077,$0075,$0074,$0072,$0070,$006F,$006D,$006B,$006A,$0068 
                  DC.W      $0066,$0065,$0063,$0061,$0060,$005E,$005D,$005B,$005A,$0058,$0057,$0055,$0054,$0053,$0051,$0050,$004F,$004D,$004C,$004B 
                  DC.W      $004A,$0049,$0048,$0047,$0046,$0045,$0044,$0043,$0042,$0041,$0041,$0040,$003F,$003F,$003E,$003E,$003D,$003D,$003D,$003C 
                  DC.W      $003C,$FFFF,$FFFF 
DATALINE:         DC.L      $08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808 
                  DC.L      $08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808 
                  DC.L      $08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808 
                  DC.L      $08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808 
                  DC.L      $08080808,$08080808,$08080808,$08080808,$08080808,$08080809,$0A0A0B0B,$0C0C0D0D,$0E0E0E0E,$0E0F0E0E 
                  DC.L      $0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706,$05050404,$03030202,$01010101,$01010101,$01010102,$02030304 
                  DC.L      $04050506,$07070809,$0A0A0B0B,$0C0C0D0D,$0E0E0E0E,$0E0F0E0E,$0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706 
                  DC.L      $05050404,$03030202,$01010101,$01010101,$01010102,$02030304,$04050506,$07070809,$0A0A0B0B,$0C0C0D0D 
                  DC.L      $0E0E0E0E,$0E0F0E0E,$0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706,$05050404,$03030202,$01010101,$01010101 
                  DC.L      $01010102,$02030304,$04050506,$07070809,$0A0A0B0B,$0C0C0D0D,$0E0E0E0E,$0E0F0E0E,$0E0E0E0D,$0D0C0C0B 
                  DC.L      $0B0A0A09,$08080706,$05050404,$03030202,$01010101,$01010101,$01010102,$02030304,$04050506,$07070809 
                  DC.L      $0A0A0B0B,$0C0C0D0D,$0E0E0E0E,$0E0F0E0E,$0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706,$05050404,$03030202 
                  DC.L      $01010101,$01010101,$01010102,$02030304,$04050506,$07070809,$0A0A0B0B,$0C0C0D0D,$0E0E0E0E,$0E0F0E0E 
                  DC.L      $0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706,$05050404,$03030202,$01010101,$01010101,$01010102,$02030304 
                  DC.L      $04050506,$07070809,$0A0A0B0B,$0C0C0D0D,$0E0E0E0E,$0E0F0E0E,$0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706 
                  DC.L      $05050404,$03030202,$01010101,$01010101,$01010102,$02030304,$04050506,$07070809,$0A0A0B0B,$0C0C0D0D 
                  DC.L      $0E0E0E0E,$0E0F0E0E,$0E0E0E0D,$0D0C0C0B,$0B0A0A09,$08080706,$05050404,$03030202,$01010101,$01010101 
                  DC.L      $01010102,$02030304,$04050506,$07070808,$0809090A,$0A0B0B0B,$0C0C0C0D,$0D0D0E0E,$0E0E0E0E,$0E0E0F0E 
                  DC.L      $0E0E0E0E,$0E0E0E0D,$0D0D0C0C,$0C0B0B0B,$0A0A0909,$08080807,$07060605,$05040404,$03030302,$02020101 
                  DC.L      $01010101,$01010101,$01010101,$01010102,$02020303,$03040404,$05050606,$07070708,$0809090A,$0A0B0B0B 
                  DC.L      $0C0C0C0D,$0D0D0E0E,$0E0E0E0E,$0E0E0F0E,$0E0E0E0E,$0E0E0E0D,$0D0D0C0C,$0C0B0B0B,$0A0A0909,$08080807 
                  DC.L      $07060605,$05040404,$03030302,$02020101,$01010101,$01010101,$01010101,$01010102,$02020303,$03040404 
                  DC.L      $05050606,$07070708,$0809090A,$0A0B0B0B,$0C0C0C0D,$0D0D0E0E,$0E0E0E0E,$0E0E0F0E,$0E0E0E0E,$0E0E0E0D 
                  DC.L      $0D0D0C0C,$0C0B0B0B,$0A0A0909,$08080807,$07060605,$05040404,$03030302,$02020101,$01010101,$01010101 
                  DC.L      $01010101,$01010102,$02020303,$03040404,$05050606,$07070708,$0809090A,$0A0B0B0B,$0C0C0C0D,$0D0D0E0E 
                  DC.L      $0E0E0E0E,$0E0E0F0E,$0E0E0E0E,$0E0E0E0D,$0D0D0C0C,$0C0B0B0B,$0A0A0909,$08080807,$07060605,$05040404 
                  DC.L      $03030302,$02020101,$01010101,$01010101,$01010101,$01010102,$02020303,$03040404,$05050606,$07070708 
                  DC.L      $0809090A,$0A0B0B0B,$0C0C0C0D,$0D0D0E0E,$0E0E0E0E,$0E0E0F0E,$0E0E0E0E,$0E0E0E0D,$0D0D0C0C,$0C0B0B0B 
                  DC.L      $0A0A0909,$08080807,$07060605,$05040404,$03030302,$02020101,$01010101,$01010101,$01010101,$01010102 
                  DC.L      $02020303,$03040404,$05050606,$07070708,$0809090A,$0A0B0B0B,$0C0C0C0D,$0D0D0E0E,$0E0E0E0E,$0E0E0F0E 
                  DC.L      $0E0E0E0E,$0E0E0E0D,$0D0D0C0C,$0C0B0B0B,$0A0A0909,$08090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504 
                  DC.L      $03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102 
                  DC.L      $03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B 
                  DC.L      $0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D 
                  DC.L      $0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504 
                  DC.L      $03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102 
                  DC.L      $03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B 
                  DC.L      $0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D 
                  DC.L      $0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504 
                  DC.L      $03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102 
                  DC.L      $03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B 
                  DC.L      $0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D 
                  DC.L      $0C0B0A09,$08060504,$03020101,$01010102,$03040506,$07090A0B,$0C0D0E0E,$0F0E0E0D,$0C0B0A09,$08060504 
                  DC.L      $03020101,$01010102,$03040506,$07080808,$08080808,$08080808,$08080808,$08080808,$08080808,$08080808 
                  DC.L      $08080808,$08080808,$08080808,$08080808,$08080808,$08080808 
                  DC.B      $FF,$FF 
TEXT:             DC.B      '                          THE ALBANIAN S'
                  DC.B      'AUSAGE CORPORATION ARE VERY PROUD TO PRE'
                  DC.B      'SENT              TESERAE             WE'
                  DC.B      'LL,   WHAT D',$27,'YA THINK THEN??            '
                  DC.B      '        THIS SCROLL TEXT IS MAINLY FOR T'
                  DC.B      'HE BENEFIT OF ANYONE WHO IS  :    A WATC'
                  DC.B      'HING SOMEONE ELSE PLAY, BUT ARE READING '
                  DC.B      'THIS INSTEAD,       OR IF YOU ARE PLAYIN'
                  DC.B      'G BUT HAVE A FACE SHAPED LIKE CROC',$27,'S AND'
                  DC.B      ' CAN THEREFORE SEE THE TOP AND BOTTOM OF'
                  DC.B      ' THE SCREEN,  NOT TO MEMTION THE REST OF'
                  DC.B      ' THE ROOM ( SIMILTANIOUSLY ) OR IF YOU A'
                  DC.B      'RE USING MY INCREDIBLE PAUSE FACILITY   '
                  DC.B      '  ( THAT CROC IS NOT IMPRESSED WITH, HE '
                  DC.B      'RECKONS THAT IT SHOULDN',$27,'T TAKE HALF AN H'
                  DC.B      'OUR TO PROGRAM A SIMPLE PAUSE BUTTON, MA'
                  DC.B      'YBE HE',$27,'S RIGHT, BUT THEN AGAIN I',$27,'M A THI'
                  DC.B      'CKY    ( COMPARED TO HIS SUPERIOR INTELL'
                  DC.B      'IGENCE ) (??)  )             ACTUALLY,  '
                  DC.B      'I TAKE THAT BACK,     CROC',$27,'S A  -REAL-  '
                  DC.B      'THICKY!!!                 CROC WISHES TO'
                  DC.B      ' ',$27,'INTERJECT',$27,' AS HE WOULD PUT IT ( IF HE '
                  DC.B      'KNEW WHAT IT MEANT! )   ( AREN',$27,'T A GIT!!'
                  DC.B      ' )       OK HERE HE IS...    YOU',$27,'LL KNOW'
                  DC.B      ' WHEN I',$27,'M TYPING AGAIN BECAUSE THE SPELL'
                  DC.B      'ING ERRORS WILL CEESE  (  HA, HA VERY FU'
                  DC.B      'NNY.. )   :    HULLO THE CROC AT THE KEY'
                  DC.B      'BOARD...       NOW HOW MUCH SPACE DO YOU'
                  DC.B      ' RECKON STE',$27,'S HARD DISKS GOT ',$27,'COS BY THE'
                  DC.B      ' TIME I',$27,'VE FINISHED IT IS GOING TO BE VA'
                  DC.B      'STLY REDUCED.....       OOOOWH  WHERE SH'
                  DC.B      'ALL I BEGIN??????               GUESS WH'
                  DC.B      'AT...    SINCE I TYPED THOSE LAST WORDS '
                  DC.B      'THERE HAS BEEN A LITTLE GAP FOR TRAGIC E'
                  DC.B      'VENTS SO I',$27,'VE FORGOT WHY I SAID ',$27,'GUESS W'
                  DC.B      'HAT',$27,'         IT TURNS OUT THAT STE HERE '
                  DC.B      'HAS JUST SAVED OVER HIS LUVLY SPLINE    '
                  DC.B      ' (  A VERY LOVELY SPLINE, WITH MUSIC, RA'
                  DC.B      'STERS, NO BORDER, AND A DAMN SCROLL TEXT'
                  DC.B      '!!   - STE )  THANKS FOR THAT LITTLE INT'
                  DC.B      'ERUPTION NOW WHERE WAS I?????      OH YE'
                  DC.B      'AR I WAS ABOUT TO SLAG OFF STE ENORMOUSL'
                  DC.B      'Y BUT I DON',$27,'T HAVE THE HEART.....       '
                  DC.B      ' OR MAYBE I DO.....     HA HA  OOWH.... '
                  DC.B      '   I CAN',$27,'T THINK OF ANYTHING TO SAY WHIC'
                  DC.B      'H IS A BIT STRANGE FOR ME BUT THERE YOU '
                  DC.B      'GO.................                ANOTH'
                  DC.B      'ER 2 HOUR INTERUPTION WHILST ME AND CROC'
                  DC.B      ' QUICKLY DROVE AROUND TO EEYONNE',$27,'S HOUSE'
                  DC.B      ', WE QUICKLY GOT AN UNCOMPACTED COPY OF '
                  DC.B      'THE PROGRAM AND DROVE BACK EVEN FASTER T'
                  DC.B      'O TRY AND TURN IT BACK INTO SOURCE CODE '
                  DC.B      'ONCE AGAIN, AFTER A WHILE I HAD GIVEN UP'
                  DC.B      ' AND JUST RE-WROTE IT......          WHA'
                  DC.B      'T A BUMMER,         TAKE THIS ADVICE    '
                  DC.B      '          NEVER ERASE YOUR OWN SOURCE CO'
                  DC.B      'DE,  BUT YOU CAN, OF COURSE ERASE CROCS.'
                  DC.B      '.....           DON',$27,'T YOU RECKON IT',$27,'D BE'
                  DC.B      ' FUNNY IF I ERASED CROC ',$27,'SPLINE',$27,' SOURCE '
                  DC.B      'CODE WHICH HE',$27,'S TRYING TO WRITE??       '
                  DC.B      '         YES!             SO DO I!!!!   '
                  DC.B      '          ERRR.......      ONE SLIGHT HI'
                  DC.B      'TCH......        CROC IS SITTING NEXT TO'
                  DC.B      ' ME WITH A VERY LARGE HAMMER....        '
                  DC.B      ' NO, AARRRRRGHHHHHH!!!!        NOT MY HA'
                  DC.B      'RD DISK!!!        ANYTHING!!       MY HE'
                  DC.B      'AD!!       MY NECK!!     ANYTHING BUT MY'
                  DC.B      ' PRECIOUS HARD DISK!!            I THINK'
                  DC.B      ' HE',$27,'LL LET ME OFF THE HOOK  ( WITH ONLY '
                  DC.B      'A SMALL BEATING!! )....               AN'
                  DC.B      'YWAY THIS ISN',$27,'T GETTING THE BABY BATHED,'
                  DC.B      ' IS IT??          NO...          FIRSTLY'
                  DC.B      ' A FEW THINGYS ABOUT THIS PROGRAM....   '
                  DC.B      '      ALL CODE BY STE B, ALL GRAFIX BY T'
                  DC.B      'HE OUTRUNNER, EXCEPT THE FONT, WHICH WAS'
                  DC.B      ' BY SPAZ!!   ( HELLO!!  ( HOPE YOU DON',$27,'T'
                  DC.B      ' MIND!! ) )            WHEN I FIRST SAW '
                  DC.B      'THE GRAFIX I HAD TO POLITELY ASK WHAT TH'
                  DC.B      'E LARGE BLOB IN THE BOTTOM RIGHT HAND CO'
                  DC.B      'RNER WAS ALL ABOUT,      SOME WHAT ANGUI'
                  DC.B      'SHED THE OUTRUNNER ( NICK ) EXPLAINED TH'
                  DC.B      'AT IF I DIDN',$27,'T STOP ASKING STUPID QUESTI'
                  DC.B      'ONS I WOULD GET KICKED...          SO I '
                  DC.B      'NOW KNOW THAT IT',$27,'S MODERN ART, SILLY..  '
                  DC.B      '    IT',$27,'S SET IN ANCIENT GREECE,(?)  AND '
                  DC.B      'AS BILL AND TED WOULD PUT IT, IT HAS ',$27,'MA'
                  DC.B      'NY STEPS AND COLUMNS AND IS MOST TRANQUI'
                  DC.B      'LL!!',$27,'      WICKED!!        ACTUALLY NICK'
                  DC.B      ' DID AN AMAZING JOB CONSIDERING THE LIMI'
                  DC.B      'TATIONS I GAVE HIM.       FOR INSTANCE T'
                  DC.B      'HE ',$27,'  OH MY GOD I',$27,'M DRUNK AND STARING AT'
                  DC.B      ' A PIECE OF WALL PAPER',$27,'  EFFECT   ( WHIC'
                  DC.B      'H YOU',$27,'VE PROBABLY NOTICED! ) TAKES UP A '
                  DC.B      'LOT OF COLOURS.....      3 CHEERS FOR NI'
                  DC.B      'CK!!     HIP HIP HORRAAAYYYY!!!   ( WELL'
                  DC.B      ' MAYBE ONLY ONE! ).....             HAVE'
                  DC.B      ' YOU NOTICED THAT AS THE PIECES GET HIGH'
                  DC.B      'ER THEY CHANGE COLOUR TOWARDS RED?     I'
                  DC.B      ' HOPE SO,   IT',$27,'S VERY COOL...           '
                  DC.B      '            I EXPECT THAT YOUR WONDERING'
                  DC.B      ' WHAT ON EARTH A ',$27,'TESERAE',$27,' IS, WELL DOWN'
                  DC.B      ' HERE AT THE ALBANIAN SAUSAGE CORP WE AR'
                  DC.B      'E CULTURED, OH YES...           A TESERA'
                  DC.B      'E IS INFACT A PIECE OF A MOSIAC..       '
                  DC.B      '            NOW THAT I',$27,'M FEELING BETTER '
                  DC.B      'AFTER MY SPLINE SOURCE WENT OUT OF THE W'
                  DC.B      'INDOW AND CAME BACK IN AGAIN I THINK CRO'
                  DC.B      'C WANTS TO INSULT ME PROPERLY, BECAUSE H'
                  DC.B      'E JUST COULD DO IT WHEN I WAS DEPRESSED.'
                  DC.B      '......         OH CROC!!!               '
                  DC.B      '         YEAH?                    AREN',$27,'T'
                  DC.B      ' YOU GOING TO INSULT ME??             HA'
                  DC.B      'R, HAR HE CAN',$27,'T THINK OF ANYTHING TO INS'
                  DC.B      'ULT ME ABOUT!!!     HAR HAR HAR!!!    ( '
                  DC.B      'APART FROM HIS SPELLING -CROC)          '
                  DC.B      '                   I DON',$27,'T KNOW WHY BUT '
                  DC.B      'CROC INSISTS THAT HE CAN PLAY THIS GAME '
                  DC.B      'BETTER THAN ME!!!     ( I CAN PLAY IT BE'
                  DC.B      'TTER THAN YOU - BACKWARDS!!  - CROC )   '
                  DC.B      '          BUT I RECKON HE',$27,'S A LAMER WHO '
                  DC.B      'CAN',$27,'T GET ONTO LEVEL 4!!!          I BET'
                  DC.B      ' YOU CAN',$27,'T GET ONTO LEVEL 6 ANYONE IN TH'
                  DC.B      'E UNIVERSE!!                  OK NOW FOR'
                  DC.B      ' THE VERY MUCH SHORTENED HI LIST, ONLY S'
                  DC.B      'HORTENED TO THE GREAT ONES, DEMI-GODS AN'
                  DC.B      'D HOODLUMS IN MY LIFE..           HERE W'
                  DC.B      'E GO ( IN NO PARTICULAR ORDER ) :  HI TO'
                  DC.B      ' CROC, OUTRUNNER, EEYONNE OF MARS, MARK '
                  DC.B      ' ( OWNER OF TASC BBS - 0625 614698, FRI '
                  DC.B      'TO SAT, 10PM TO 8AM ), ME OLD MATE BRIAN'
                  DC.B      '   ( FROM THE BEST BAND IN THE WORLD, WI'
                  DC.B      'TH MYSELF           THE       S C A N N '
                  DC.B      'E R S    ), MUG UK, , BIRDY, TRANCE, R. '
                  DC.B      'DOBBIE, TOM, KATIE, STIG, PHILIP, KERRY,'
                  DC.B      ' HELEN, LIZ, LARRY, MARK D, DARYL, JOHN,'
                  DC.B      ' NICK, ROB, GEOFF AND EVERYONE ELSE IN T'
                  DC.B      'HE WHOLE WIDE UNIVERSE  ( INCLUDING YOU!'
                  DC.B      '! )               I HATE ',$27,'HI',$27,' LISTS, BEC'
                  DC.B      'AUSE YOU ALWAYS FORGET SOMEONE, WHO FEEL'
                  DC.B      ' REALLY LEFT OUT, SO IF I INADVERTANTLY '
                  DC.B      'LEFT YOU OUT    HI!!!                   '
                  DC.B      '                CROC BOASTS THAT HIS IS '
                  DC.B      'BIGGER THAN MINE..........       AND NO '
                  DC.B      'MATTER HOW MANY HE HAS,    HIS IS ALWAYS'
                  DC.B      ' BIGGER AND MORE INTERESTING THAN MINE..'
                  DC.B      '....             LITTLE DEVIL,  HE CAN',$27,'T'
                  DC.B      ' HALF WRITE SCROLL TEXTS!! (??)      ( T'
                  DC.B      'HE ONLY THING IS I FILL MINE WITH MORE S'
                  DC.B      'H.. - CROC )    SORRY THAT LAST BIT WAS '
                  DC.B      'CENSORED,    NO SWEARING OF ANY TYPE, OR'
                  DC.B      ' DESCRIPTION......     BUT CROC, JUST TH'
                  DC.B      'INK OF ALL THE IMPRESSIONABLY YOUNG KIDD'
                  DC.B      'IES AT HOME,  WHO AFTER READING THIS TEX'
                  DC.B      'T BECOME UPSET AT YOUR COURSE LANGUAGE A'
                  DC.B      'ND GO OUT AND MURDER SOMEONE..........  '
                  DC.B      '               SWEARING IS THE ROOT OF A'
                  DC.B      'LL EVIL...         IT CORRUPTS YOUNG INN'
                  DC.B      'OCENT MINDS....         YOU SHOULD BE AS'
                  DC.B      'HAMED OF YOUR SELF...           ( BOLLOC'
                  DC.B      'KS,   CROC AND STE )      OKEY DOKEY, I '
                  DC.B      'THINK MY SINGING CAREER IS OVER, AS IS T'
                  DC.B      'HIS SCROLL TEXT AND THE DAY, GOOD NIGHT '
                  DC.B      'FROM STE, CROC AND THE REST OF THE ALBAN'
                  DC.B      'IAN SAUSAGE CORPORATION - LONG LIVE ALBA'
                  DC.B      'NIA!!                                   '
                  DC.B      '                        LET',$27,'S WRAP......'
                  DC.B      '................                        '
                  DC.B      '                       ',$FF 
INTROTEX:         DC.B      '    WELCOME  TO',$0A,$0D,'      TESERAE      ',$0B,$0B,$0C,$0B 
                  DC.B      '   WRITTEN BY THE  ',$0B,$0C,' ALBANIAN  SAUSAGE',$0A
                  DC.B      $0D,'    CORPORATION    ',$0B,$0B,$0C,$0B,' USE CURSOR KEYS'
                  DC.B      ' +',$0A,$0D,' SPACE BAR TO PLAY ',$0B,$0B,$0C,'  P TO PAUSE A' 
                  DC.B      'ND ',$0A,$0D,'   HELP TO EXIT    ',$0B,$0B,$0C,'  PRESS SPACE' 
                  DC.B      ' TO  ',$0A,$0D,'       PLAY        ',$0B,$0B,$0C,' CODE BY   ' 
                  DC.B      ': STE B',$0A,$0D,' GRAFIX BY : NICK  ',$0B,$0B,$0C,'   CURREN' 
                  DC.B      'T HIGH   ',$0A,$0D,'  SCORE :  ' 
HIBUF:            DC.B      '       ',$0B,$0B,$0C,$0C,'    WRITTEN FOR',$0A,$0D,'     ST FORM'
                  DC.B      'AT     ',$0B,$0B,$0C,$00,$00 
CURSOR:           DC.W      $7FFE,$FFFF,$FFFF,$FFFF
                  DC.W      $FFFF,$FFFF,$FFFF,$FFFF
                  DC.W      $FFFF,$FFFF,$FFFF,$FFFF 
                  DC.W      $FFFF,$FFFF,$FFFF,$7FFE 

FONT:             INCBIN    'FONT.PAK'
                  EVEN
SMFONT:           INCBIN    'SMFONT.PAK'
                  EVEN
L013C:            INCBIN    'L013C.PAK'
                  EVEN
PICCY3:           INCBIN    'PICCY3.PAK'
                  EVEN
PICCY2:           INCBIN    'PICCY2.PAK'
                  EVEN
PICCY1:           INCBIN    'PICCY1.PAK'
                  EVEN

 BSS
                  DS.B      10340 
L0144:            DS.B      5120
L0145:            DS.B      71680 
L0146:            DS.B      32740 
STARBUFF:         DS.B      5120
CURSBUFF:         DS.B      256 
