Start	move.l 	a7,a5
	lea 	Start(pc),a7
	move.l 	$4(a5),a5
	move.l 	$C(a5),d0
	add.l 	#$100,d0
	move.l 	d0,-(a7)
	move.l 	a5,-(a7)
	move 	#$0,-(a7)
	move 	#$4A,-(a7)
	trap 	#$1		Set Block - Shrink Memory
	add.l 	#$C,a7
	clr.l 	-(a7)
	move 	#$20,-(a7)
	trap 	#$1		Enter/Exit Supervisor Mode
	addq.l 	#6,a7
	move.l 	d0,d7
	move.l 	#$249F0,-(a7)
	move 	#$48,-(a7)
	trap 	#$1		Allocate Memory
	addq.l 	#6,a7
	lea 	OldStack(pc),a0
	move.l 	d0,(a0)

	lea 	GoTrap1(pc),a0
	move.l 	$84,(a0)		Trap #1 Instruction
	move.l 	#NewTrap1,$84	Trap #1 Instruction
	move.l 	d7,-(a7)
	move 	#$20,-(a7)
	trap 	#$1		Enter/Exit Supervisor Mode
	addq.l 	#6,a7

*  MAIN LOOP *******************


MainLoop
	move.l 	#Texten,-(a7)
	move 	#$9,-(a7)
	trap 	#$1		Print Line
	addq.l 	#6,a7
	bsr 	GetKey
	cmp.l 	#0,a6
	beq.s 	DropMenu
* A6=name on DAT file
	move 	#$2,-(a7)
	move.l 	a6,-(a7)
	move 	#$3D,-(a7)
	trap 	#$1		Open File
	add.l 	#$8,a7
	move 	d0,-(a7)
	move 	#$3E,-(a7)
	trap 	#$1		Close File
	addq.l 	#4,a7
	move.l 	#ExecNil,-(a7)
	move.l 	#ExecNil,-(a7)
	move.l 	#ExecName,-(a7)
	move 	#$0,-(a7)
	move 	#$4B,-(a7)
	trap 	#$1		Program Exec
	add.l 	#$E,a7
	lea 	L7050C(pc),a0
	move 	#$0,(a0)
	bra 	MainLoop

*  QUIT *******************************

DropMenu:
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap 	#$1		Enter/Exit Supervisor Mode
	addq.l 	#6,a7
	move.l 	d0,d7

	lea 	GoTrap1(pc),a0
	move.l 	(a0),$84	Trap #1 Restore

	move.l 	d7,-(a7)
	move 	#$20,-(a7)
	trap 	#$1		Enter/Exit Supervisor Mode
	addq.l 	#6,a7

	clr.w	-(a7)
	trap	#1


*  SPECIAL TRAP ******************


NewTrap1
	move.l 	a1,-(a7)
	lea 	SaveA0(pc),a1
	move.l 	a0,(a1)
	move.l 	(a7)+,a1
	btst 	#$5,(a7)
	bne.s 	UserOn
	move.l 	usp,a0
	bra.s 	SuperOff
UserOn	move.l 	a7,a0
	addq.l 	#6,a0
SuperOff
	cmp 	#$3D,(a0)
	beq 	OPEN
	cmp 	#$3C,(a0)
	beq 	CREATE
	cmp 	#$3F,(a0)
	beq 	READ
	cmp 	#$42,(a0)
	beq 	LSEEK
	cmp 	#$3E,(a0)
	beq 	CLOSE
TillBaka
	move.l 	SaveA0(pc),a0
	jmp 	0				L0
GoTrap1	equ 	*-4


CREATE	move.l	a1,-(a7)
	lea 	L704F8(pc),a1
	move 	#$1,(a1)
	move.l 	(a7)+,a1
	bra.s 	TillBaka

LSEEK	movem.l d1-d7/a1-a6,-(a7)
	move CrunFlag(pc),a1
	cmpa.w #$ffff,a1
*	dc $B2FC,$FFFF
	beq AntiCrun
	move $8(a0),d1
	cmp #$0,d1
	beq.s L70140
	cmp #$1,d1
	beq.s L70154
	cmp #$2,d1
	beq.s L7016A
L70140	move.l L704FE(pc),d1
	add.l $2(a0),d1
	lea L704EC(pc),a1
	move.l d1,(a1)
	move.l $2(a0),d0
	bra.s L70182
L70154	move.l L704EC(pc),d1
	add.l $2(a0),d1
	lea L704EC(pc),a1
	move.l d1,(a1)
	sub.l L704FE(pc),d1
	move.l d1,d0
	bra.s L70182
L7016A	move.l L704FE(pc),d1
	add.l L704F0(pc),d1
	add.l $2(a0),d1
	lea L704EC(pc),a1
	move.l d1,(a1)
	sub.l L704FE(pc),d1
	move.l d1,d0
L70182	movem.l (a7)+,d1-d7/a1-a6
	move.l SaveA0(pc),a0
	rte



OPEN	movem.l d1-d7/a1-a6,-(a7)
	move L704FA(pc),a1
*	dc $B2FC,$1
	cmpa.w #$1,a1
	beq AntiCrun
	move.l $2(a0),a1
	lea HitchF(pc),a2
	move.l a2,a3
L701A6	move.b (a1)+,d1
	move.b (a2)+,d2
	cmp.b #$0,d1
	beq L702D4
	cmp.b #$FF,d2
	beq L701CC
	cmp.b d1,d2
	beq.s L701A6
	add.l #$D,a3
	move.l a3,a2
	move.l $2(a0),a1
	bra.s L701A6
L701CC	move L7050C(pc),a1
*	dc $B2FC,$1
	cmpa.w #$1,a1
	beq AntiCrun

L701D8	move.l OldStack(pc),a1
	add.l #$100,a1
	lea L704EC(pc),a2
	move.l a1,(a2)
	lea L704FE(pc),a2
	move.l a1,(a2)
	lea L70502(pc),a2
	move.l a1,(a2)
	lea L704FA,a2
	move #$1,(a2)
	move #$2,-(a7)
	move.l $2(a0),-(a7)
	move #$3D,-(a7)
	trap #$1		Open File
	addq.l #8,a7
	lea L7050A(pc),a2
	move d0,(a2)
	move.l OldStack(pc),-(a7)
	move.l #$FFFFF,-(a7)
	move L7050A(pc),-(a7)
	move #$3F,-(a7)
	trap #$1		Read from File
	add.l #$C,a7
	move.l OldStack(pc),a2
	move.l $0(a2),a1
	cmpa.l CruCheck(pc),a1
	beq.s FilCrund
	lea L704EC(pc),a2
	move.l OldStack(pc),(a2)
	lea L704FE(pc),a2
	move.l OldStack(pc),(a2)
	lea L704F0(pc),a2
	move.l d0,(a2)
	lea L70502(pc),a2
	move.l OldStack(pc),(a2)
	add.l d0,(a2)
	bra.s JoinUp
FilCrund
	move.l $4(a2),d1
	lea L704F0(pc),a2
	move.l d1,(a2)
	lea L70502(pc),a2
	add.l d1,(a2)
	move.l OldStack(pc),a0
	move.l OldStack(pc),a1
	add.l #$100,a1
	lea L704E8(pc),a2
	move $FFF8240,(a2)
	bsr UnCrunch
	move L704E8(pc),$FFF8240
	lea L7050C(pc),a0
	move #$1,(a0)
JoinUp	move L7050A(pc),-(a7)
	move #$3E,-(a7)
	trap #$1		Close File
	addq.l #4,a7
	lea L704FA(pc),a2
	move #$0,(a2)
L702AE	move.l SaveA0(pc),a0
	movem.l (a7)+,d1-d7/a1-a6
	move.l #$6,d0		Reset PC
	rte
AntiCrun
	move.l SaveA0(pc),a0
	lea CrunFlag(pc),a1
	move.l #$FFFFFFFF,(a1)
	movem.l (a7)+,d1-d7/a1-a6
	bra TillBaka
L702D4	move L7050C(pc),a1
*	dc $B2FC,$1
	cmpa.w #$1,a1
	beq.s L702AE
	bra L701D8



READ	movem.l d1-d7/a1-a6,-(a7)
	move.l CrunFlag(pc),a1
	cmpa.l #$FFFFFFFF,a1
	beq RealRead
	move.l $4(a0),d1
	move.l d1,d0
	move.l $8(a0),a1
	move.l L704EC(pc),a2
L70302	cmpa.l L70502(pc),a2
	beq.s L70320
	move.b (a2)+,(a1)+
	subq.l #1,d1
	cmp.l #0,d1		; L0
	bne.s L70302
	move.l $4(a0),d1
	lea L704EC(pc),a1
	add.l d1,(a1)
	bra.s L70334
L70320	move.l L704EC(pc),d1
	move.l L70502(pc),d2
	sub.l d1,d2
	move.l d2,d0
	lea L704EC(pc),a1
	move.l L70502(pc),(a1)
L70334	movem.l (a7)+,d1-d7/a1-a6
	move.l SaveA0(pc),a0
	rte
RealRead
	movem.l (a7)+,d1-d7/a1-a6
	move.l SaveA0(pc),a0
	bra TillBaka



CLOSE	move.l a1,-(a7)
	move.l CrunFlag(pc),a1
	cmpa.l #$FFFFFFFF,a1
	beq.s L70370
	move L704F8(pc),a1
*	dc $B2FC,$1
	cmpa.w #1,a1
	beq.s L70370
	move.l #0,d0		Reset SSP   L0
	move.l SaveA0(pc),a0
	move.l (a7)+,a1
	rte
L70370	lea CrunFlag(pc),a0
	move.l #0,(a0)		Reset SSP   L0
	lea L704F8(pc),a0
	move #$0,(a0)
	move.l SaveA0(pc),a0
	move.l (a7)+,a1
	bra TillBaka



UnCrunch
	add.l #$4,a0
	move.l a0,$1000
	move.l (a0)+,d5
	add.l d5,a1
	add.l (a0),a0
	sub.l #$4,a0
	tst -(a0)
	bpl.s Dum1
	subq.l #1,a0
Dum1	move.b -(a0),d0
GigaHopp
	lsl.b #1,d0
	bne.s Dum2
	move.b -(a0),d0
	roxl.b #1,d0
Dum2	bcc.s Dum17
	clr d1
	lsl.b #1,d0
	bne.s Dum3
	move.b -(a0),d0
	roxl.b #1,d0
Dum3	bcc.s Skum1
	lea Data0(pc),a3
	moveq #$3,d3
Loop0	clr d1
	move.b $0(a3,d3),d2
	ext d2
	moveq #-$1,d4
	lsl d2,d4
	not d4
	subq #1,d2
Loop1	lsl.b #1,d0
	bne.s Dum4
	move.b -(a0),d0
	roxl.b #1,d0
Dum4	roxl #1,d1
	dbf d2,Loop1
	tst d3
	beq.s Dum5
	cmp d1,d4
	dbne d3,Loop0
Dum5	move.b $4(a3,d3),d2
	ext d2
	add d2,d1
	bra Skum1
Data0	dc $A03,$202,$E07,$401
Skum1	move.b -(a0),-(a1)
	move a0,$FFFF8240	Palette #$0?
	dbf d1,Skum1
Dum17	move.l $1000,a3
	addq.l #8,a3
	cmpa.l a3,a0
	ble DropOut
	lea Data1(pc),a3
	moveq #$3,d2
Loop2	lsl.b #1,d0
	bne.s Dum6
	move.b -(a0),d0
	roxl.b #1,d0
Dum6	bcc.s Dum7
	dbf d2,Loop2
Dum7	clr d1
	addq #1,d2
	move.b $0(a3,d2),d3
	beq.s Dum8
	ext d3
	subq #1,d3
Loop3	lsl.b #1,d0
	bne.s Dum9
	move.b -(a0),d0
	roxl.b #1,d0
Dum9	roxl #1,d1
	dbf d3,Loop3
Dum8	move.b $5(a3,d2),d3
	ext d3
	add d3,d1
	bra Skutta1
Data1	dc $A02,$100,$A,$604,$302
Skutta1	cmp #$2,d1
	beq.s Dum11
	lea Data2(pc),a3
	moveq #$1,d3
Loop4	lsl.b #1,d0
	bne.s Dum10
	move.b -(a0),d0
	roxl.b #1,d0
Dum10	bcc.s Dum15
	dbf d3,Loop4
Dum15	addq #1,d3
	clr d2
	move.b $0(a3,d3),d4
	ext d4
Loop5	lsl.b #1,d0
	bne.s Dum14
	move.b -(a0),d0
	roxl.b #1,d0
Dum14	roxl #1,d2
	dbf d4,Loop5
	lsl #1,d3
	add $4(a3,d3),d2
	bra.s Skutta2
Data2	dc $B04,$700,$120,$0,$20,$0
Dum11	clr d2
	moveq #$5,d3
	clr d4
	lsl.b #1,d0
	bne.s Dum12
	move.b -(a0),d0
	roxl.b #1,d0
Dum12	bcc.s Dum13
	moveq #$8,d3
	moveq #$40,d4
Dum13	lsl.b #1,d0
	bne.s Dum16
	move.b -(a0),d0
	roxl.b #1,d0
Dum16	roxl #1,d2
	dbf d3,Dum13
	add d4,d2
Skutta2	lea $0(a1,d2),a2
	ext.l d1
	add.l d1,a2
	subq #1,d1
Loop6	move.b -(a2),-(a1)
	dbf d1,Loop6
	bra GigaHopp
DropOut	rts

SaveA0		dc.l $0
L704E8		dc.l $0
L704EC		dc.l $0
L704F0		dc.l $0
CrunFlag	dc.l $0
L704F8		dc $0
L704FA		dc.l $0
L704FE		dc.l $0
L70502		dc.l $0


OldStack	dc.l $0
L7050A		dc $0
L7050C		dc $0
CruCheck	dc.b "AUTM"

GetKey	move #$7,-(a7)
	trap #$1		Get Chr without echo
	addq.l #2,a7
	cmp.b #27,d0
	bne.s	NotEsc
	lea	0,a6
	rts
NotEsc:
	swap d0
	cmp #$3B,d0
	bne.s L7052A
	move.l #HitchF,a6
	rts
L7052A	cmp #$3C,d0
	bne.s L70538
	move.l #LeatherF,a6
	rts
L70538	cmp #$3D,d0
	bne.s L70546
	move.l #HihinxF,a6
	rts
L70546	cmp #$3E,d0
	bne.s L70554
	move.l #StationF,a6
	rts
L70554	cmp #$3F,d0
	bne.s L70562
	move.l #CutthF,a6
	rts
L70562	cmp #$40,d0
	bne.s L70570
	move.l #PlanetF,a6
	rts
L70570	cmp #$41,d0
	bne.s L7057E
	move.l #StarcrF,a6
	rts
L7057E	cmp #$42,d0
	bne.s GetKey
	move.l #SuspectF,a6
	rts

HitchF		dc.b "HITCHHIK.DAT",$0
LeatherF	dc.b "LEATHER.DAT",$0,$0
HihinxF		dc.b "HIJINX.DAT",$0,$0,$0
StationF	dc.b "STATIONF.DAT",$0
CutthF		dc.b "CUTTHRTS.DAT",$0
PlanetF		dc.b "PLANETF.DAT",$0,$0
StarcrF		dc.b "STARCROS.DAT",$0
SuspectF	dc.b "SUSPECT.DAT",$0,$0
		dc.b "STORY.DAT",$0,$0
		dc.b $0,$0,$0
		dc.l $FFFFFFFF

ExecName	dc.b "SHARAZ.JEK",$0,$0
ExecNil		dc.b $0,$0,$0,$0
Texten
	dc.b 27,'E'
	dc.b '                            INFOCOM ADVENTURES',13,10,10,10
	dc.b "                            F1 - HITCHHIKERS GUIDE",$A,$D
	dc.b "                            F2 - LEATHER GODDESSES",$A,$D
	dc.b "                            F3 - HOLLYWOOD HIJINX",$A,$D
	dc.b "                            F4 - STATIONFALL",$A,$D
	dc.b "                            F5 - CUTTHROATS",$A,$D
	dc.b "                            F6 - PLANETFALL",$A,$D
	dc.b "                            F7 - STARCROSS",$A,$D
	dc.b "                            F8 - SUSPECT",$A,$D,10,10
	dc.b "                            Esc  QUIT",0
