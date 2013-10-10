; SIMPLE TRAP #1 FILE DEPACKER FOR JAM PACKER V3.0/4.0 LZH COMPRESSION.
; WILL ONLY WORK ON FILES WHICH ARE COMPLETELY READ BY ONE CALL TO
; FREAD (TRAP #1 #$3F).

savebuf		=	$200
YES		equ	1
NO		equ	0
LSEEKROUTINE	EQU 	YES	;WHEN PROG USES LSEEK TO DETERMINE FILE LENGTH
SFIRSTROUTINE	EQU	YES	;WHEN PROG USES SFIRST TO DETERMINE FILE LENGTH

BEGINNING:
 BRA.S	START
fname: dc.b 'PLAYER.PRG',$00
 EVEN

START:
 MOVEA.L A7,A5 
 LEA BEGINNING(PC),A7
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$100,D0

 MOVE.L  D0,-(A7)
 MOVE.L  A5,-(A7)
 MOVE.W  #$0000,-(A7)
 MOVE.W  #$004A,-(A7)
 TRAP    #1
 ADDA.L  #$0000000C,A7

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,d7

 MOVE.L	#$1600,-(SP)
 MOVE.W #$48,-(SP)
 TRAP #1		;RESERVE SOME SPACE FOR LZH DEPACK TABLES
 ADDQ.L #6,SP
 MOVE.L D0,BUFPOS

 move.l $84.W,oldtrap1vector
 move.l #trapit,$84.W

 move.l d7,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

 MOVE.L #NULL,-(SP)
 MOVE.L #NULL,-(SP)
 PEA	fname(PC)
 MOVE.W #0,-(SP)
 MOVE.W #$4B,-(SP)
 TRAP	#1
 add.l #14,sp

;ENSURE THAT YOU CAN QUIT OUT OF PROGRAMS WITHOUT A CRASH
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

 move.l oldtrap1vector(pc),$84.w

 move.l d0,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

 clr.w -(sp)
 trap #1

trapit:
 btst #$05,(a7)
 bne.S super
 move.l usp,a0
 bra.S after
super:
 move.l a7,a0
 addq.l #6,a0
after:
 cmp.w #$3d,(a0)
 beq doopen
 cmp.w #$3f,(a0)
 beq.s load
 IFNE LSEEKROUTINE
 cmp.w #$42,(a0)
 beq.s down
 ENDC
 IFNE SFIRSTROUTINE
 cmp.w #$4e,(a0)
 beq.s dosfirst
 cmp.w #$2f,(a0)
 beq.s dogetdta
 cmp.w #$1a,(a0)
 ENDC
 bne dotrap1

 IFNE SFIRSTROUTINE
 lea retsetdta(pc),a0
 move.l 2(a7),(a0)
 lea setdta(pc),a0
 move.l a0,2(a7)
 bra dotrap1

dogetdta:
 lea retgetdta(pc),a0
 move.l 2(a7),(a0)
 lea getdta(pc),a0
 move.l a0,2(a7)
 bra dotrap1
 ENDC

doopen:
 lea retopen(pc),a0
 move.l 2(a7),(a0)
 lea open(pc),a0
 move.l a0,2(a7)
 bra dotrap1

;here starts the stuff for SFIRST

 IFNE SFIRSTROUTINE
dosfirst:
 lea retsfirst(pc),a0
 move.l 2(a7),(a0)
 lea sfirst(pc),a0
 move.l a0,2(a7)
 bra.s dotrap1
 ENDC

;here start the stuff for LSEEK
 IFNE LSEEKROUTINE
down:
 lea retlseek(pc),a0
 move.l 2(a7),(a0)
 lea lseek(pc),a0
 move.l a0,2(a7)
 bra.s dotrap1
 ENDC

load:
 move.w inopen(pc),d0
 cmp.w #1,d0
 beq.s dotrap1			;if checking depack marker, do real trap1!
 move.w seekflag(pc),d0
 cmp.w #1,d0
 beq.s dotrap1			;if called from seek handler, exit!
 move.w mustdecrun(pc),d0
 cmp.w #1,d0
 bne.s dotrap1			;if marker not present, don't decrunch!

 move.l a7,d0
 movem.l a1-a3,-(sp) 
 
 sub.l #$20,8(a0)
 lea buffer(pc),a1
 move.l 8(a0),(a1)

 move.l d0,a2
 lea return(pc),a1
 move.l 2(a2),(a1)
 lea decrunch(pc),a1
 move.l a1,2(a2)

 move.l buffer(pc),a1
 lea savebuf,a2
 move.l #$20,a3
loadloop:
 move.b (a1)+,(a2)+
 subq.l #1,a3
 cmp.l #0,a3
 bne.s loadloop
 movem.l (sp)+,a1-a3
 
dotrap1:
 dc.w $4ef9
oldtrap1vector:
 dc.l $00


;**************************
open:
 tst.l d0
 bmi exitopen2

 movem.l a1-a3,-(sp)
 move.l d0,a3
 lea inopen(pc),a1
 move.w #1,(a1)

 pea test(pc)
 move.l #8,-(sp)
 move.w a3,-(sp)
 move.w #$3f,-(sp)
 trap #1
 add.l #12,sp
 tst.l d0			;ADDED TO FIX ZERO LENGTH FILE
 beq.s notcrun			;DITTO
 
 move.l magic(pc),d0
 cmp.l test(pc),d0
 bne.s notcrun
 lea mustdecrun(pc),a1
 move.w #1,(a1)
 bra.s skipit
notcrun:
 lea mustdecrun(pc),a1
 move.w #0,(a1)
skipit:

 move.w #1,-(sp)
 move.w a3,-(sp)
 move.l #-8,-(sp)
 move.w #$42,-(sp)
 trap #1
 add.l #10,sp

 move.l a3,d0
exitopen:
 lea inopen(pc),a1
 move.w #0,(a1)
 movem.l (sp)+,a1-a3

exitopen2:
 dc.w $4ef9
retopen:                               ;exit
 dc.l $00

inopen:
 dc.w 0
test:
 dc.l 0
unpaklen:
 dc.l 0
mustdecrun:
 dc.w 0
magic:
 dc.b 'LZH!'

 IFNE SFIRSTROUTINE
;***************************
getdta:
 lea dta(pc),a0
 move.l d0,(a0)
 dc.w $4ef9
retgetdta:
 dc.l $00

;****************************
setdta:
 lea dta(pc),a0
 move.l 2(a7),(a0)
 dc.w $4ef9
retsetdta:
 dc.l $00

;***********************************     FOR $4E (SFIRST)
sfirst:
 tst.l d0
 bne pissoff

 move.l 2(a7),a0

 movem.l a1-a3,-(sp)

 move.w #$2,-(sp)
 move.l a0,-(sp)
 move.w #$3d,-(sp)
 trap #1
 addq.l #8,sp
 lea sfirsthandle(pc),a1
 move.w d0,(a1)

 move.w mustdecrun(pc),d0
 cmp.w #1,d0
 beq.s change
 bra.s afterchange

change:
 move.l dta(pc),a0
 add.l #26,a0
 move.l unpaklen(pc),d0
 move.l d0,(a0)

afterchange:
 move.w sfirsthandle(pc),-(sp)
 move.w #$3e,-(sp)
 trap #1
 addq.l #4,sp

 movem.l (sp)+,a1-a3

pissoff:
 dc.w $4ef9
retsfirst:                               ;exit
 dc.l $00
 ENDC

;***********************************     FOR $42 (LSEEK) IN TRAP1
 IFNE LSEEKROUTINE
lseek:
 cmp.w #2,8(a7)
 bne vamos3
 cmp.l #0,2(a7)
 bne vamos3
 lea seekhandle(pc),a0
 move.w 6(a7),(a0)
 lea sd0save(pc),a0
 move.l d0,(a0)

 move.w mustdecrun(pc),d0
 cmp.w #1,d0
 bne.s vamos 
 move.l unpaklen(pc),d0
 bra.s vamos3

vamos:
 move.l sd0save(pc),d0
vamos3:
 dc.w $4ef9
retlseek:                            ;exit
 dc.l $00
 ENDC

;************************************    FOR $3F (READ) IN TRAP1
decrunch:
         ;a0 - start of crunched data
         ;a1 - beginning of uncrunching area

 movem.l d0-d7/a0-a6,-(sp)
 move.l buffer(pc),a0
 lea origlen(pc),a1
 move.l 4(a0),(a1)

 move sr,d1
 btst #13,d1
 bne nochange

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 lea jek(pc),a6
 move.l d0,(a6)

 lea mode(pc),a1
 move.w #1,(a1)      ;1 denotes must return to user mode

nochange:
 lea colstore(pc),a1
 move.w $fff8240,(a1)
 move.l buffer(pc),a0
 move.l a0,a1
 add.l #$20,a1
 BSR DEPACK
 move.w colstore(pc),$fff8240

				;restore memory saved in buffer
 move.l buffer(pc),a1
 lea savebuf,a2
 move.l #$20,a3
loadloop2:
 move.b (a2)+,(a1)+
 subq.l #1,a3
 cmp.l #0,a3
 bne.s loadloop2

 move.w mode(pc),d0
 cmp.w #1,d0
 bne nochange2

 move.l jek(pc),-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

nochange2:
 lea mode(pc),a1
 move.w #$00,(a1)
 movem.l (sp)+,d0-d7/a0-a6
 move.l origlen(pc),d0
 dc.w $4ef9
return:                            ;exit decrunch module
 dc.l $00


* LZH DEPACKER For use with the JAM Packer V3.0/V4.0
*
* USAGE:
* LEA $ADDRESS OF PACKED DATA,A0
* LEA $ADDRESS TO UNPACK DATA TO,A1
* BSR DEPACK
*
* NOTE: Must save registers before executing depack if original
*       contents are required.

RESET   MOVEM.W D0-D1/D3/D5,-(A7)
	MOVEA.L A1,A2
	MOVEQ   #$00,D2
	MOVEQ   #-$02,D4
	MOVEQ   #$00,D1
	MOVE.W  #$0139,D5
OUTER	ADDQ.W  #2,D4
	CMP.W   (A2)+,D7
	BHI.S   OUTER
	MOVE.W  $00(A3,D4.W),D3
	ADDQ.W  #1,D3
	LSR.W   #1,D3
	CMP.W   -$02(A3,D2.W),D3
	BLS.S 	BIDDLE
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	CMP.W   D0,D3
	BLS.S	BIDDLE
BITH	MOVE.W  D0,$00(A3,D2.W)
	MOVE.W  D1,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D1.W)
	MOVE.W  D2,$02(A0,D1.W)
	ADDQ.W  #2,D2
	ADDQ.L  #4,D1
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	CMP.W   D0,D3
	BHI.S	BITH
BIDDLE	MOVE.W  D3,$00(A3,D2.W)
	MOVE.W  $00(A1,D4.W),D0
	MOVE.W  D0,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D0.W)
	ADDQ.W  #2,D2
	DBF     D5,OUTER
MAKETABLE2
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	MOVE.W  D0,$00(A3,D2.W)
	MOVE.W  D1,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D1.W)
	MOVE.W  D2,$02(A0,D1.W)
	ADDQ.W  #2,D2
	ADDQ.L  #4,D1
	CMP.W   D7,D2
	BNE.S	MAKETABLE2
	MOVEM.W (A7)+,D0-D1/D3/D5
	RTS     

CREATE  MOVE.L	TABLE7(PC),A0
	LEA     TDATA1(PC),A1
	MOVEQ   #$00,D0
	MOVEQ   #$1F,D1
	MOVEQ   #$00,D2
LOOP1   MOVE.B  D0,(A0)+
	DBF     D1,LOOP1
	DBF     D2,EXIT1
	MOVE.W  (A1)+,D3
	MOVEQ   #$03,D2
EXIT1   ROL.W   #4,D3
	MOVE.W  D3,D1
	ANDI.W  #$000F,D1
	ADDQ.B  #4,D0
	BCC.S   LOOP1
	MOVE.L	TABLE8(PC),A0
	LEA     TDATA2(PC),A1
	MOVEQ   #$05,D0
	MOVEQ   #$03,D1
LOOP2   MOVE.B  $00(A1,D0.W),D2
	EXT.W   D2
LOOP3   MOVE.B  D1,(A0)+
	DBF     D2,LOOP3
	ADDQ.W  #1,D1
	DBF     D0,LOOP2
	RTS

CREATE2 MOVE.L	TABLE1(PC),A0
	MOVE.L	TABLE5(PC),A1
	MOVE.L	TABLE4(PC),A2
	MOVEQ   #$01,D1
	MOVE.W  #$04E6,D2
	MOVEQ   #$00,D4
	MOVE.W  #$0139,D0
CONTINUE
	MOVE.W  D1,(A0)+
	MOVE.W  D2,(A1)+
	MOVE.W  D4,(A2)+
	ADDQ.W  #2,D2
	ADDQ.W  #2,D4
	DBF     D0,CONTINUE
	MOVE.L	TABLE1(PC),A0
	MOVE.L	TABLE2(PC),A3
	MOVE.L	TABLE6(PC),A1
	MOVE.L	TABLE3(PC),A2
	MOVE.W  #$0274,D2
	MOVEQ   #$00,D4
	MOVE.W  #$0138,D0
DOMORE	MOVE.W  (A0)+,D1
	ADD.W   (A0)+,D1
	MOVE.W  D1,(A3)+
	MOVE.W  D4,(A1)+
	MOVE.W  D2,(A2)+
	MOVE.W  D2,(A2)+
	ADDQ.W  #4,D4
	ADDQ.W  #2,D2
	DBF     D0,DOMORE
	MOVE.W  #$FFFF,(A3)
	CLR.W   (A2)
	RTS     

RESTORE BSR     RESET
	BRA     BACK

TABLE1 DC.L 00
TABLE2 DC.L 00
TABLE3 DC.L 00
TABLE4 DC.L 00
TABLE5 DC.L 00
TABLE6 DC.L 00
TABLE7 DC.L 00
TABLE8 DC.L 00
BUFPOS: DC.L 00

EXIT
	ADDQ.L	#4,A7
	RTS

DEPACK
	MOVE.L	A0,A5
	MOVE.L	A1,A6
	LEA	TABLE1(PC),A0
	MOVE.L	#0,(A0)		;SET UP RELATIVE TABLE OFFSETS
	MOVE.L	#$274,4(A0)
	MOVE.L	#$4E8,8(A0)
	MOVE.L	#$9CE,12(A0)
	MOVE.L	#$C42,16(A0)
	MOVE.L	#$EB6,20(A0)
	MOVE.L	#$112A,24(A0)
	MOVE.L	#$122A,28(A0)

	MOVE.L	BUFPOS(PC),D1
	TST.L D1
	BNE.S DONTUSESCREEN
	
USESCREEN:
	MOVE.B $FFFF8201.W,D6
	MOVE.B $FFFF8203.W,D7
	LSL.L #8,D6
	MOVE.B D7,D6
	LSL.L #8,D6
	MOVE.L D6,D1

DONTUSESCREEN:
;	MOVE.L	A7,D1		;GET STACK POSITON
;	sub.l	#$1500,D1	;TABLES START ADDRESS IN D1
				;STORE UNDER STACK
	MOVE.W	#7,D0
TABLOOP
	ADD.L	D1,(A0)+	;ADD TABLE BASE ADDRESS TO OFFSETS
	DBF	D0,TABLOOP
	
	BSR	CREATE
	BSR     CREATE2
	MOVE.L	TABLE3(PC),A0
	MOVE.L	TABLE5(PC),A1
	MOVE.L	TABLE1(PC),A3
	MOVE.L  A6,-(A7)
	ADD.L	4(A5),A6
	ADD.L	8(A5),A5
	ADD.L	#$0C,A5
	MOVE.L	A6,A4
				;THIS IS REQUIRED!
	MOVE.W	#59,D0		;MOVE 60 SPACES TO END OF UNPACKED AREA
SPACES	MOVE.B	#$20,(A4)+	;NOTE: SHOULD PROBABLY SAVE THIS DATA
	DBF	D0,SPACES	;      BEFORE WIPING IT OUT!

	MOVEQ   #$08,D6
	MOVE.B  -(A5),D5
	MOVE.W  #$04E6,D7
	MOVE.L	TABLE8(PC),A4

TOP	NOT.W	$FFFF8240.W
	CMPA.L  (A7),A6
	BLE	EXIT

	MOVE.W  $04E4(A1),D0
MORE	DBF     D6,NOTEMPTY
	MOVEQ   #$07,D6
	MOVE.B  -(A5),D5
NOTEMPTY
	ADD.B   D5,D5
	BCC.S   ZERO
	ADDQ.W  #2,D0
ZERO	MOVE.W  $00(A1,D0.W),D0
	CMP.W   D7,D0
	BLT.S   MORE
	MOVE.W  D0,D1
	SUB.W   D7,D0
	MOVE.W  $04E4(A3),D4
	BMI	RESTORE

BACK	MOVE.W  $00(A0,D1.W),D1
SCAN	LEA     $00(A3,D1.W),A2
	ADDQ.W  #1,(A2)
	CMPM.W  (A2)+,(A2)+
	BCS.S   FRSTGTR
	MOVE.W  $00(A0,D1.W),D1
	BNE.S   SCAN
	LSR.W   #1,D0
	CMP.W   #$0100,D0
	BGE.S   GTE256
WRITE	MOVE.B	D0,-(A6)
	BRA.S   TOP

FRSTGTR SUBQ.W  #1,-$0004(A2)
	MOVE.W  -$0004(A2),D4
SAME	CMP.W   (A2)+,D4
	BEQ.S   SAME
	SUBQ.L  #4,A2
	ADDQ.W  #1,(A2)
	SUBA.L  A3,A2
	MOVE.W  $00(A1,D1.W),D4
	MOVE.W  A2,$00(A0,D4.W)
	CMP.W   D7,D4
	BCC.S   SKIP
	MOVE.W  A2,$02(A0,D4.W)
SKIP	MOVE.W  $00(A1,A2.W),D2
	MOVE.W  D4,$00(A1,A2.W)
	MOVE.W  D1,$00(A0,D2.W)
	CMP.W   D7,D2
	BCC.S   SKIP2
	MOVE.W  D1,$02(A0,D2.W)
SKIP2   MOVE.W  D2,$00(A1,D1.W)
	MOVE.W  $00(A0,A2.W),D1
	BNE.S   SCAN
	LSR.W   #1,D0
	CMP.W   #$0100,D0
	BLT.S   WRITE
GTE256	MOVE.B  -1(A5),D1
	MOVEQ   #$00,D2
	LSR.B   D6,D1
	OR.B    D5,D1
	MOVE.B  $00(A4,D1.W),D2
	SUB.W   D2,D6
	BPL.S   POSITIVE
	MOVE.B  -(A5),D5
	MOVE.B  D5,D4
	ADDQ.W  #2,D6
	BMI.S   OVERFLOW
	BEQ.S   MODD4
	LSR.B   #1,D4
	LSL.B   #7,D5
	BRA.S   MODD4
READONE MOVE.B  -(A5),D5
	MOVE.B  D5,D4
	LSL.B   #6,D5
	MOVEQ   #$02,D6
	LSR.B   D6,D4
	BRA.S   DOCOPY
POSITIVE
	BEQ.S   READONE
	MOVE.B (A5),D5
	SUBQ.W  #6,D6
OVERFLOW
	NEG.W   D6
	LSL.B   D6,D5
	MOVE.B  D5,D4
	MOVE.B  -(A5),D5
	MOVE.B  D5,D2
	LSL.B   D6,D5
	SUBQ.W  #8,D6
	NEG.W   D6
	LSR.B   D6,D2
	OR.B    D2,D4
MODD4   ANDI.W  #$003F,D4
DOCOPY	MOVE.L	TABLE7(PC),A0
	MOVE.B  (A0,D1.W),D2
	LSL.W   #4,D2
	OR.B    D4,D2
	;NEG.W   D2
	LEA     $01(A6,D2.W),A0
	SUBI.W  #$00FE,D0
	MOVE.W  D0,D1
COPY	MOVE.B  -(A0),D0
	MOVE.B  D0,-(A6)
	DBF     D1,COPY
	MOVE.L	TABLE3(PC),A0
	BRA	TOP

TDATA2	DC.W	$0F2F
	DC.W	$2F3F
	DC.W	$2F1F
TDATA1
	DC.W	$FFF7
	DC.W	$7777
	DC.W	$7773
	DC.W	$3333
	DC.W	$3333
	DC.W	$3331
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1110
	DC.L	$00
	DC.L	$00

 SECTION DATA
origlen:	dc.l $00
oldssp:		dc.l $00
buffer:		dc.l $00
mode:		dc.l $00
jek:		dc.l $00
length:		dc.l $00
colstore:	dc.l $00
seekflag:	dc.w $00
seekhandle:	dc.w $00
sd0save:	dc.l $00
rtlseeksav:	dc.l $00
sfirsthandle:	dc.l $00
dta:		dc.l $00
oldsize:	dc.l $00
NULL:		DC.L $00