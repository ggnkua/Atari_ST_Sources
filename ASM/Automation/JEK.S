;this will only compile properly under GENST because the register
;lists are different for MOVEM!!

YES		equ	1
NO		equ	0
LSEEKROUTINE	EQU 	YES
SFIRSTROUTINE	EQU	YES
COLFLASH	EQU	YES
HEADING		EQU	YES		;CREDITS
FILECHECK	EQU	YES		
COPYDOWN	EQU	NO
HALFMEGBUF	EQU	NO
DECRUNBUF 	EQU	$9620
HALFMEGBUFPOS	EQU	$78000

PROGSTART:
 BRA CODESTART

FNAME: DC.B 'PARROT2',$00
NULL: DC.L $00

 IFNE HEADING
MYTEXT:
 DC.B $1B,$45
       ;1234567890123456789012345678901234567890
  DC.B "VAPOUR PRESENTS . . .",0
 ENDC
 EVEN

CODESTART:
 IFEQ COPYDOWN
 MOVEA.L A7,A5
 LEA PROGSTART(PC),A7
 MOVEA.L $0004(A5),A5
 MOVE.L  $000C(A5),D0
 ADDI.L  #$00000100,D0
 MOVE.L  D0,-(A7)
 MOVE.L  A5,-(A7)
 MOVE.W  #$0000,-(A7)
 MOVE.W  #$004A,-(A7)
 TRAP    #1
 ADDA.L  #$0000000C,A7
 ENDC

 IFNE COPYDOWN
 MOVEA.L A7,A5
 LEA PROGSTART(PC),A7
 MOVEA.L $0004(A5),A5
 MOVE.L  #$00000300,D0
 MOVE.L  D0,-(A7)
 MOVE.L  A5,-(A7)
 MOVE.W  #$0000,-(A7)
 MOVE.W  #$004A,-(A7)
 TRAP    #1
 ADDA.L  #$0000000C,A7
 ENDC

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,d7

 IFNE HALFMEGBUF
 move.w $42e,d0
 cmp.w #$0008,d0
 bne.s onemeg
 lea decrunloc(pc),a0
 move.l #HALFMEGBUFPOS,(a0)         ;temporary!!!
 bra.s afteronemeg
 ENDC

onemeg:
 move.l #DECRUNBUF,-(sp)
 move.w #$48,-(sp)
 trap #1
 addq.l #6,sp
 lea decrunloc(pc),a0
 move.l d0,(a0)

afteronemeg:
 lea oldtrap1vector(pc),a0
 move.l $84,(a0)

 lea trapit(pc),a0

 IFEQ COPYDOWN
 move.l a0,$84
 ENDC

 IFNE COPYDOWN
 sub.l #$700,d7
 move.l d7,a1	;destination
 lea endofroutine(pc),a2
keepgoing:
 move.l (a0)+,(a1)+
 cmp.l a2,a0
 ble.s keepgoing
 move.l d7,$84
 ENDC

 IFNE HEADING
 PEA MYTEXT(PC)
 MOVE.W #$09,-(SP)
 TRAP   #1
 ADDQ.L #6,SP
 ENDC

 move.l d7,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

 PEA NULL(PC)
 PEA NULL(PC)
 PEA FNAME(PC)
 MOVE.W #0,-(SP)
 MOVE.W #$4B,-(SP)
 TRAP #1
 add.l #14,sp

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

 move.l oldtrap1vector(pc),$84

 move.l d0,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp

 clr.w -(sp)
 trap #1

trapit:
 move.l a1,-(sp)
 lea a0save(pc),a1
 move.l a0,(a1)
 move.l (sp)+,a1
 btst #$05,(a7)
 bne.S super
 move.l usp,a0
 bra.S after
super:
 move.l a7,a0
 addq.l #6,a0
after:
 cmp.w #$3d,(a0)
 beq openfile
 cmp.w #$3c,(a0)
 beq create
 cmp.w #$3f,(a0)
 beq loadfile
 IFNE LSEEKROUTINE
 cmp.w #$42,(a0)
 beq lseek
 ENDC
 cmp.w #$3e,(a0)
 beq close
 IFNE SFIRSTROUTINE
 cmp.w #$4e,(a0)
 beq sfirst
 ENDC

dotrap1:
 move.l a0save(pc),a0
 dc.w $4ef9
oldtrap1vector:
 dc.l $00


 IFNE SFIRSTROUTINE
;************************************
sfirst:
 movem.l d1-d7/a1-a6,-(sp)
 cmp.w #0,6(a0)
 bne dorealsfirst

 MOVE.W alreadyin(pc),A1
 CMP.W #1,A1
 BEQ dorealsfirst

 lea alreadyin(pc),a1
 move.w #1,(a1)
 
 move.w #0,-(sp)
 move.l 2(a0),-(sp)
 move.w #$4e,-(sp)
 trap #1
 addq.l #8,sp
 tst.l d0
 bmi.s errsfirst

 move.w #$2,-(sp)
 move.l 2(a0),-(sp)
 move.w #$3d,-(sp)
 trap #1
 addq.l #8,sp
 lea fp(pc),a2
 move.w d0,(a2)

 pea sbuf(pc)
 move.l #$8,-(sp)
 move.w fp(pc),-(sp)
 move.w #$3f,-(sp)
 trap #1
 add.l #12,sp

 move.w fp(pc),-(sp)
 move.w #$3e,-(sp)
 trap #1
 addq.l #4,sp

 move.l magic(pc),a1
 lea sbuf(pc),a2
 cmp.l 0(a2),a1
 bne.s notcrunched

 move.w #$2F,-(sp)
 trap #1
 addq.l #2,sp

 move.l d0,a1
 move.l 4(a2),26(a1)

notcrunched:
 move.l #0,d0
errsfirst:
 lea alreadyin(pc),a1
 move.w #0,(a1)
 movem.l (sp)+,d1-d7/a1-a6
 rte
 ENDC



;************************************
create:
 move.l a1,-(sp)
 lea closefile(pc),a1
 move.w #$01,(a1)
 move.l (sp)+,a1
 bra dotrap1

;************************************
 IFNE LSEEKROUTINE
lseek:
 movem.l d1-d7/a1-a6,-(sp)

 MOVE.W mustdorealopen(pc),A1
 CMP.W #-1,A1
 BEQ dorealopen

 move.w 8(a0),d1
 cmp.w #0,d1
 beq.s zero
 cmp.w #1,d1
 beq.s one
 cmp.w #2,d1
 beq.s two

zero:
 move.l oldfp(pc),d1
 add.l 2(a0),d1
 lea filepointer(pc),a1
 move.l d1,(a1)
 move.l 2(a0),d0
 bra.s leave

one:
 move.l filepointer(pc),d1
 add.l 2(a0),d1
 lea filepointer(PC),a1
 move.l d1,(a1)
 sub.l oldfp(pc),d1
 move.l d1,d0
 bra.s leave

two:
 move.l oldfp(pc),d1
 add.l origlen(pc),d1
 add.l 2(a0),d1
 lea filepointer(PC),a1
 move.l d1,(a1)
 sub.l oldfp(pc),d1
 move.l d1,d0

leave:
 movem.l (sp)+,d1-d7/a1-a6
 move.l a0save(pc),a0
 rte
 ENDC

;************************************
openfile:
 movem.l d1-d7/a1-a6,-(sp)
 MOVE.W alreadyin(pc),A1
 CMP.W #1,A1
 BEQ dorealopen

 IFNE FILECHECK
 move.l 2(a0),a1

; add.l #5,a1

 lea directory(PC),a2
 move.l a2,a3               ;keep a copy of dir start
again:
 move.b (a1)+,d1
 move.b (a2)+,d2
 cmp.b #0,d1                ;end of filename string?
 beq dorealopen
 cmp.b #$ff,d2
 beq done
 or.b #$20,d1
 or.b #$20,d2
 cmp.b d1,d2
 beq.s again
 add.l #12,a3
 move.l a3,a2
 move.l 2(a0),a1            ;reset pointer to loadfname

 ;add.l #5,a1

 bra.s again
 ENDC

done:
 move.l decrunloc(pc),a1
 add.l #$20,a1
 lea filepointer(pc),a2
 move.l a1,(a2)
 lea oldfp(pc),a2
 move.l a1,(a2)
 lea eofl(pc),a2
 move.l a1,(a2)
 
 lea alreadyin(pc),a2
 move.w #1,(a2)

 move.w #$2,-(sp)
 move.l 2(a0),-(sp)
 move.w #$3d,-(sp)
 trap #1
 addq.l #8,sp
 tst.l d0
 bmi outerr
 lea fp(pc),a2
 move.w d0,(a2)

 move.l decrunloc(pc),-(sp)
 move.l #$fffff,-(sp)
 move.w fp(pc),-(sp)
 move.w #$3f,-(sp)
 trap #1
 add.l #12,sp
 
 move.l decrunloc(pc),a2
 move.l (a2),a1
 cmp.l magic(pc),a1
 beq.s decrunfile

 lea filepointer(pc),a2
 move.l decrunloc(pc),(a2)
 lea oldfp(pc),a2
 move.l decrunloc(pc),(a2)
 lea origlen(pc),a2
 move.l d0,(a2)
 lea eofl(pc),a2
 move.l decrunloc(pc),(a2)
 add.l d0,(a2)
 bra.s next

decrunfile:
 move.l 4(a2),d1
 lea origlen(pc),a2
 move.l d1,(a2)
 lea eofl(pc),a2
 add.l d1,(a2)

 move.l decrunloc(pc),a0
 move.l decrunloc(pc),a1        ;UNCRUNCH TO WORK AREA
 add.l #$20,a1
 lea colstore(pc),a2
 move.w $fff8240,(a2)
 bsr decrunch
 move.w colstore(pc),$fff8240

next:
 move.w fp(pc),-(sp)
 move.w #$3e,-(sp)
 trap #1
 addq.l #4,sp

theend:
 move.l a0save(pc),a0
 moveq.l #$00000006,d0
outerr:
 lea alreadyin(pc),a2
 move.w #0,(a2)
 movem.l (sp)+,d1-d7/a1-a6
 rte

dorealopen:
 move.l a0save(pc),a0
 lea mustdorealopen(pc),a1
 move.l #-1,(a1)
dorealsfirst:
 movem.l (sp)+,d1-d7/a1-a6
 bra dotrap1

;************************************
loadfile:
 movem.l d1-d7/a1-a6,-(sp)
 move.l mustdorealopen(pc),a1
 cmp.l #-1,a1
 beq mustdorealload

 move.l 4(a0),d1
 move.l d1,d0
 move.l 8(a0),a1
 move.l filepointer(pc),a2
lp:
 cmp.l eofl(pc),a2
 beq.s tisdone
 move.b (a2)+,(a1)+
 subq.l #1,d1
 cmp.l #0,d1
 bne.s lp

 move.l 4(a0),d1
 lea filepointer(PC),a1
 add.l d1,(a1)
 bra.s jumpover

tisdone:
 move.l filepointer(pc),d1
 move.l eofl(pc),d2
 sub.l d1,d2
 move.l d2,d0
 lea filepointer(PC),a1
 move.l eofl(pc),(a1)

jumpover:
 movem.l (sp)+,d1-d7/a1-a6
 move.l a0save(pc),a0
 rte

mustdorealload:
 movem.l (sp)+,d1-d7/a1-a6
 move.l a0save(pc),a0
 bra dotrap1

;************************************
close:
 move.l a1,-(sp)
 move.l mustdorealopen(pc),a1
 cmp.l #-1,a1
 beq.s mustdorealclose
 move.w closefile(pc),a1
 cmp.w #1,a1
 beq.s mustdorealclose
 moveq.l #00,d0
 move.l a0save(pc),a0
 move.l (sp)+,a1
 rte

mustdorealclose:
 lea mustdorealopen(PC),a0
 move.l #0,(a0)
 lea closefile(PC),a0
 move.w #0,(a0)
 move.l a0save(pc),a0
 move.l (sp)+,a1
 bra dotrap1


;************************************
decrunch:
		ADDA.L	#$4,A0	;ALLOW FOR HEADER
		MOVE.L	A0,A6
		MOVE.L	(A0)+,D5
		ADDA.L	D5,A1
		ADDA.L	(A0),A0
		SUBA.L	#4,A0
		TST.W	-(A0)
		BPL.S	L_1
		SUBQ.L	#1,A0
L_1		MOVE.B	-(A0),D0
L_2		LSL.B	#1,D0
		BNE.S	L_3
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_3		BCC.S	L_10
		CLR.W	D1
		LSL.B	#1,D0
		BNE.S	L_4
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_4		BCC.S	L_9
		LEA	NUMS(PC),A3
		MOVEQ	#3,D3
L_5		CLR.W	D1
		MOVE.B	0(A3,D3.W),D2
		EXT.W	D2
		MOVEQ	#-1,D4
		LSL.W	D2,D4
		NOT.W	D4
		SUBQ.W	#1,D2
L_6		LSL.B	#1,D0
		BNE.S	L_7
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_7		ROXL.W	#1,D1
		DBF	D2,L_6
		TST.W	D3
		BEQ.S	L_8
		CMP.W	D1,D4
		DBNE	D3,L_5
L_8		MOVE.B	4(A3,D3.W),D2
		EXT.W	D2
		ADD.W	D2,D1
L_9
		MOVE.B	-(A0),-(A1)
		IFNE COLFLASH
;		ADDQ.W	#1,$FFFF8240
		MOVE.W	D0,$FFFF8240
		ENDC
		DBF	D1,L_9
L_10		MOVE.L	A6,A3
		ADDQ.L	#$8,A3
		CMPA.L	A3,A0
		BLE	BYENOW
		LEA	NUMS2(PC),A3
		MOVEQ	#3,D2
L_11		LSL.B	#1,D0
		BNE.S	L_12
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_12		BCC.S	L_13
		DBF	D2,L_11
L_13		CLR.W	D1
		ADDQ.W	#1,D2
		MOVE.B	0(A3,D2.W),D3
		BEQ.S	L_16
		EXT.W	D3
		SUBQ.W	#1,D3
L_14		LSL.B	#1,D0
		BNE.S	L_15
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_15		ROXL.W	#1,D1
		DBF	D3,L_14
L_16		MOVE.B	5(A3,D2.W),D3
		EXT.W	D3
		ADD.W	D3,D1
		CMPI.W	#2,D1
		BEQ.S	L_22
		LEA	NUMS3(PC),A3
		MOVEQ	#1,D3
L_17		LSL.B	#1,D0
		BNE.S	L_18
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_18		BCC.S	L_19
		DBF	D3,L_17
L_19		ADDQ.W	#1,D3
		CLR.W	D2
		MOVE.B	0(A3,D3.W),D4
		EXT.W	D4
L_20		LSL.B	#1,D0
		BNE.S	L_21
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_21		ROXL.W	#1,D2
		DBF	D4,L_20
		LSL.W	#1,D3
		ADD.W	4(A3,D3.W),D2
		BRA.S	L_26
L_22		CLR.W	D2
		MOVEQ	#5,D3
		CLR.W	D4
		LSL.b	#1,D0
		BNE.S	L_23
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_23		BCC.S	L_24
		MOVEQ	#8,D3
		MOVEQ	#$40,D4
L_24		LSL.B	#1,D0
		BNE.S	L_25
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_25		ROXL.W	#1,D2
		DBF	D3,L_24
		ADD.W	D4,D2
L_26		LEA	0(A1,D2.W),A2
		EXT.L	D1
		ADDA.L	D1,A2
		SUBQ.W	#1,D1
L_27		MOVE.B	-(A2),-(A1)
		DBF	D1,L_27
		BRA	L_2
BYENOW		RTS
NUMS		DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01
NUMS2		DC.B	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02
NUMS3		DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
		DC.B	$00,$20,$00,$00

;magic: dc.b 'AUTM'
 magic: dc.b 'LSD!'

 IFNE FILECHECK
directory:
 DC.B 'NAMES       '
 DC.B 'NAMES.NEW   '
 DC.B 'HIGH        '
 DC.B 'HIGH.NEW    '
;dc.b 'xxxxxxxx.xxx'
 DC.L $FFFFFFFF
 ENDC

a0save: dc.l $00
colstore: dc.l $00
filepointer: dc.l $00
origlen: dc.l $00
mustdorealopen: dc.l $00
closefile: dc.w $00
alreadyin: dc.l $00
oldfp: dc.l $00
eofl: dc.l $00
decrunloc: dc.l $00
fp: dc.w $00
sbuf: dc.l $00,$00

endofroutine: