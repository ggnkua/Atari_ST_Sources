*  All Coded by ~Vat~ at 5-02.1993  *
*************************************
; Hej! wyslalem te zrodlowke gdyz
; stwierdzilem, ze jest ona strasznie
; cienka. acha, jesli bedziesz chcial
; uruchomic ja pod debug-erem, to
; bedziesz musial 'ubezwzglednic' 
; kilka adresow. a tak pozatem to aby
; dojsc do tego, co sie tu dzieje
; bedziesz sie musial nieco pomeczyc,
; bo ja sam juz nawet nie pamietam co
; tu namiachalem! co do grafiki, to
; jest ona zastrzezona! jesli chcesz
; jej uzywac, to najpierw skontaktuj
; sie z Peter-em! (adres w skrolu)...
Begin:	lea	$80000,a7
sss	pea	$400.w
	move.w	#32,-(a7)
	trap	#1
	cmp.b	#2,$ffff8260.w
	beq	KoNiEc
	clr.b	$484.w
	lea	$ffff8200.w,a0
	clr.b	$60(a0)
	move.b	#2,10(a0)
ShAdOwS
	clr.l	$140.w
	lea	$70000,a0
	lea	(a0),a1
	moveq	#2,d7
	bsr	Show
	move.w	#$777,$ffff8240.w
	moveq	#6,d7
WyCien	sub.w	#$111,$ffff8240.w
	bsr	DoubleVbl
	dbf	d7,WyCien
	move.l	#$30000,d0
Verbatim sub.l	#1,d0
	cmp.l	#0,d0
	bne.s	Verbatim
	lea	SHOWpal1(pc),a0
	bsr	n1
	bsr	PST
ShowTimeComing1
	bsr	DoubleVbl
	lea	STart1,a0
	lea	$78030+86*160,a1
	moveq	#26,d7
	bsr	Show
	bsr	ColorShow
ShowTimeComing2
	bsr	DoubleVbl
	lea	STart2,a0
	lea	$78030+95*160,a1
	moveq	#9,d7
	bsr	Show
	bsr	ColorShow
ShowTimeComing3
	bsr	DoubleVbl
	lea	STart4,a0
	lea	$78030+68*160,a1
	moveq	#63,d7
	bsr	Show
	bsr	ColorShow
ShowTimeComing4
	bsr	DoubleVbl
	lea	STart3,a0
	lea	$78030+65*160,a1
	moveq	#70,d7
	bsr	Show
	bsr	ColorShow
ShowTimeComing5
	bsr	DoubleVbl
	lea	STart5,a0
	lea	$78030+65*160,a1
	moveq	#70,d7
	move.l	#-1,$140.w
	bsr	Show
	bsr	ColorShow
	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824c.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825c.w
	move.b	#$07,$ffff8201.w
	move.b	#$60,$ffff8203.w
	bra	LetsGoDemo
ColorShow
	lea	SHOWpal0(pc),a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	bsr	MegaWait
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	DoubleVbl
L140	rts

MegaWait
	move.l	#$38000,d0
MW1	move.l	$400.w,$400.w
	move.l	a0,a0
	sub.l	#1,d0
	cmp.l	#0,d0
	bne.s	MW1
	rts
DoubleVbl
	move.l	$466.w,d0
xyz1	cmp.l	$466.w,d0
	beq.s	xyz1
	move.l	$466.w,d0
xyz2	cmp.l	$466.w,d0
	beq.s	xyz2
	rts
Show	move.l	#$70080,$ffff8200.w
	moveq	#0,d0
	lea	$78000,a2
	move.w	#199,d6
qwertz	rept	40
	move.l	d0,(a2)+
	endr
	dbf	d6,qwertz
	moveq	#8,d4
	moveq	#6,d6
Show2	
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,8(a1)
	swap	d0
	or.w	d0,0(a1)
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,10(a1)
	swap	d0
	or.w	d0,2(a1)
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,12(a1)
	swap	d0
	or.w	d0,4(a1)
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,14(a1)
	swap	d0
	or.w	d0,6(a1)
	addq.l	#8,a1
	dbf	d6,Show2
	moveq	#6,d6
	lea	104(a1),a1
	dbf	d7,Show2
	rts
n1	lea	32(a0),a1
	lea	(a1),a2
	bsr	tfuKUPA
n2	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfuKUPA
n3	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfuKUPA
n4	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfuKUPA
n5	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfuKUPA
n6	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfuKUPA
n7	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfuKUPA
	lea	SHOWpal1(pc),a0
	lea	(a0),a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	rts
tfuKUPA	movem.l	(a0)+,d0-d3
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	movem.l	d0-d3,(a1)
	movem.l	(a0),d0-d3
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	movem.l	d0-d3,16(a1)
	rts
one_col	moveq	#0,d4
	moveq	#0,d5
	move.w	d6,d4
	ror.l	#8,d4
	tst.b	d4
	beq.s	husarz
	subq.w	#1,d4
husarz	move.b	d4,d5
	lsl.w	#4,d5
	rol.l	#4,d4
	and.b	#15,d4
	tst.b	d4
	beq.s	husarz1
	subq.w	#1,d4
husarz1	or.b	d4,d5
	lsl.w	#4,d5
	rol.l	#4,d4
	and.b	#15,d4
	tst.b	d4
	beq.s	husarz2
	subq.w	#1,d4
husarz2	or.b	d4,d5
	rts
SHOWpal0 DS.W	8*16
SHOWpal1 dc.w	$000,$222,$333,$444,$555,$666,$777,$700
	dc.w	$400,$600,$500,$300,$730,$740,$750,$760
	DS.W	7*16
LetsGoDemo
	bsr	prepareFala
	moveq	#0,d0
	move.w	#$9b0,d7
	lea	$76000,a0
qwT	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,qwT
	lea	auroraT(pc),a0
	lea	$76000,a1
	moveq	#19,d6
	moveq	#27,d7
GrafAT	move.l	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	addq.l	#8,a1
	dbf	d6,GrafAT
	moveq	#19,d6
	dbf	d7,GrafAT
	bsr	resol
	bsr	przelicz
	lea	Medal,a3
	lea	$76000+31*160,a4
	move.w	#198-32,d7
Medal2	move.l	(a3)+,(a4)
	move.l	(a3)+,4(a4)
	move.l	(a3)+,8(a4)
	move.l	(a3)+,12(a4)
	move.l	(a3)+,16(a4)
	move.l	(a3)+,20(a4)
	move.l	(a3)+,24(a4)
	move.l	(a3)+,28(a4)
	move.l	(a3)+,32(a4)
	move.l	(a3)+,36(a4)
	move.l	(a3)+,40(a4)
	move.l	(a3)+,44(a4)
	move.l	(a3)+,48(a4)
	move.l	(a3)+,52(a4)
	move.l	(a3)+,56(a4)
	move.l	(a3)+,60(a4)
	move.l	(a3)+,64(a4)
	move.l	(a3)+,68(a4)
	move.l	(a3)+,72(a4)
	move.l	(a3)+,76(a4)
	lea	160(a4),a4
	dbf	d7,Medal2
	bsr	prepare

press3	
	clr.w	sss
WaitVbl	cmp.w	#-1,sss
	bne.s	WaitVbl
	bra.s	press3
	illegal

End_Story
	nop
	jsr	(music+12)
	bsr	ret_reg
	cmp.l	#'Vat!',$1000.w
	beq	ReSeT
KoNiEc	
	lea	$70000,a0
	lea	(a0),a1
	moveq	#2,d7
	bsr	Show
	lea	$77000,a0
	lea	(a0),a1
	moveq	#2,d7
	bsr	Show
	lea	STkolory(pc),a0
	lea	$ffff8200.w,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$40(a1)
	clr.w	-(a7)
	move.l	#$78000,-(a7)
	move.l	#$78000,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	clr.l	-(a7)
	trap	#1
	illegal
OldPal	ds.l	2
resol	
	lea	OldPal(pc),a0
	lea	$ffff8200.w,a1
	move.b	10(a1),(a0)+
	move.b	$60(a1),(a0)+
	move.b	1(a1),(a0)+
	move.b	3(a1),(a0)+
	clr.b	$484.w
	move.b	#2,$ffff820a.w
	lea	End_Muz,a0
	moveq	#0,d0
	move.w	#2000,d7
wyczsc	rept	8
	move.l	d0,(a0)+
	endr
	dbf	d7,wyczsc
	lea	aurora(pc),a0
	lea	End_Muz,a1
	lea	A_Adresy(pc),a2
	moveq	#15,d7
	bsr	shift_logo
	bsr	Prep_Shft
	rts
Prep_Shft
	lea	Przesun_Aurora(pc),a0
et	move.l	(a0),d0
	cmp.l	#-1,d0
	beq.s	jdfh
	divu	#16,d0
	moveq	#0,d1
	move.w	d0,d1
	mulu	#8,d1
	move.w	d1,d0
	swap	d0
	move.l	d0,(a0)+
	bra.s	et
jdfh	rts
Draw
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	lea	Przesun_Aurora(pc),a0
	lea	$7600e,a1
	lea	A_Adresy(pc),a2
	move.w	Fix_Aurora(pc),d3
	move.w	(a0,d3.w),d5
	move.w	2(a0,d3.w),d4
	cmp.w	#-1,d4
	bne.s	Fifka
	move.w	(a0),d4
	move.w	2(a0),d5
	clr.w	Fix_Aurora
Fifka	add.w	#4,Fix_Aurora
	add.l	d5,a1
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a2,d4.w),a2
	moveq	#0,d6
	moveq	#27,d7
Draw2	
	move.w	d6,-8(a1)
	move.w	(a2)+,(a1)
	move.w	(a2)+,8(a1)
	move.w	(a2)+,16(a1)
	move.w	(a2)+,24(a1)
	move.w	(a2)+,32(a1)
	move.w	(a2)+,40(a1)
	move.w	(a2)+,48(a1)
	move.w	(a2)+,56(a1)
	move.w	(a2)+,64(a1)
	move.w	(a2)+,72(a1)
	move.w	(a2)+,80(a1)
	move.w	(a2)+,88(a1)
	move.w	(a2)+,96(a1)
	move.w	d6,104(a1)
	lea	160(a1),a1
	dbf	d7,Draw2
	rts
shift_logo
	move.l	a1,(a2)+
	moveq	#0,d4
lets1	moveq	#11,d5
	moveq	#27,d6
dawaj_go
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,2(a1)
	swap	d0
	or.w	d0,0(a1)
	addq.l	#2,a1
	dbf	d5,dawaj_go
	moveq	#11,d5
	addq.l	#2,a1
	dbf	d6,dawaj_go
	lea	8(a1),a1
	addq.w	#1,d4
	moveq	#11,d5
	moveq	#28,d6
	move.l	a1,(a2)+
	lea	aurora(pc),a0
	dbf	d7,dawaj_go
	rts
prepare	
	move.w	sr,-(a7)
	move.w	#$2700,sr
	lea	Zapisz(pc),a0
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	bclr	#3,$fffffa17.w
	move.b	#1,$fffffa07.w
	move.b	#$40,$fffffa09.w
	move.b	#1,$fffffa13.w
	move.b	#$40,$fffffa15.w
	move.l	#Key,$118.w
	move.l	#Rte,$120.w
	moveq 	#1,d0
	jsr 	(music+0)
	jsr	(music+8)
	move.l	#VBL,$70.w
	rte
ret_reg	move.w	sr,-(a7)
	move.w	#$2700,sr
	lea	Zapisz(pc),A0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	move.b	#$c0,$fffffa23.w
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	lea	OldPal(pc),a0
	lea	$ffff8200.w,a1
	move.b	(a0)+,10(a1)
	move.b	(a0)+,$60(a1)
	move.b	(a0)+,1(a1)
	move.b	(a0)+,3(a1)
	move.b	#7,$484.w
	rte
Key	move.b	$fffffc02.w,Klawisz
	rte

PST	lea	tekst_1(pc),a0
PST2	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#-1,d0
	beq.s	EPST
	bsr	comPare
	bra.s	PST2
EPST	rts
comPare
	cmp.b	#' ',d0
	bne.s	CMP0
	moveq	#64,d0
	bra	CMPend
CMP0	cmp.b	#'!',d0
	bne.s	CMP1
	moveq	#92,d0
	bra	CMPend
CMP1	cmp.b	#'(',d0
	bne.s	CMP2
	moveq	#91,d0
	bra	CMPend
CMP2	cmp.b	#')',d0
	bne.s	CMP3
	moveq	#93,d0
	bra	CMPend
CMP3	cmp.b	#'"',d0
	bne.s	CMP4
	moveq	#94,d0
	bra	CMPend
CMP4	cmp.b	#"'",d0
	bne.s	CMP5
	moveq	#95,d0
	bra	CMPend
CMP5	cmp.b	#'?',d0
	bne.s	CMP6
	moveq	#96,d0
	bra	CMPend
CMP6	cmp.b	#'c',d0
	bne.s	CMP7
	moveq	#98,d0
	bra	CMPend
CMP7	cmp.b	#'e',d0
	bne.s	CMP8
	moveq	#99,d0
	bra	CMPend
CMP8	cmp.b	#'l',d0
	bne.s	CMP9
	moveq	#100,d0
	bra	CMPend
CMP9	cmp.b	#'n',d0
	bne.s	CMP10
	moveq	#101,d0
	bra	CMPend
CMP10	cmp.b	#'o',d0
	bne.s	CMP11
	moveq	#102,d0
	bra	CMPend
CMP11	cmp.b	#'s',d0
	bne.s	CMP12
	moveq	#103,d0
	bra	CMPend
CMP12	cmp.b	#'z',d0
	bne.s	CMP13
	moveq	#104,d0
	bra	CMPend
CMP13	cmp.b	#'y',d0
	bne.s	CMP14
	moveq	#105,d0
	bra	CMPend
CMP14	cmp.b	#'-',d0
	bne.s	CMP15
	moveq	#106,d0
	bra	CMPend
CMP15	cmp.b	#'.',d0
	bne.s	CMP16
	moveq	#107,d0
	bra	CMPend
CMP16	cmp.b	#':',d0
	bne.s	CMP17
	moveq	#108,d0
	bra	CMPend
CMP17	cmp.b	#',',d0
	bne.s	CMP18
	moveq	#109,d0
	bra	CMPend
CMP18	cmp.b	#';',d0
	bne.s	CMP19
	moveq	#110,d0
	bra	CMPend
CMP19	cmp.b	#'1',d0
	bne.s	CMP20
	moveq	#111,d0
	bra	CMPend
CMP20	cmp.b	#'2',d0
	bne.s	CMP21
	moveq	#112,d0
	bra	CMPend
CMP21	cmp.b	#'3',d0
	bne.s	CMP22
	moveq	#113,d0
	bra	CMPend
CMP22	cmp.b	#'4',d0
	bne.s	CMP23
	moveq	#114,d0
	bra	CMPend
CMP23	cmp.b	#'5',d0
	bne.s	CMP24
	moveq	#115,d0
	bra	CMPend
CMP24	cmp.b	#'6',d0
	bne.s	CMP25
	moveq	#116,d0
	bra.s	CMPend
CMP25	cmp.b	#'7',d0
	bne.s	CMP26
	moveq	#117,d0
	bra.s	CMPend
CMP26	cmp.b	#'8',d0
	bne.s	CMP27
	moveq	#118,d0
	bra.s	CMPend
CMP27	cmp.b	#'9',d0
	bne.s	CMP28
	moveq	#119,d0
	bra.s	CMPend
CMP28	cmp.b	#'0',d0
	bne.s	CMPend
	moveq	#120,d0
CMPend	sub.w	#64,d0
	move.b	d0,(a0)+
	rts
Zupa	rte
ReSeT
	lea	music,a0
	lea	$78000,a1
	moveq	#0,d0
Slayer	rept	4
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	endr
	cmp.l	a0,a1
	bgt.s	Slayer
	bsr	reZ
	lea	Zupa(pc),a0
	move.l	a0,$70.w
	move.l	a0,$120.w
	move.l	a0,$118.w
	moveq	#1,d0
	jsr	(P_Tale+0)
	jsr	(P_Tale+8)
	lea	VbL(pc),a0
	move.l	a0,$70.w
GetLoop	nop
	bra.s	GetLoop
VbL	
	move.b	#7,$ffff8201.w
	move.b	#$80,$ffff8203.w
	bsr	Equalz
	bsr.s	rysuj
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	(P_Tale+4)
	movem.l	(a7)+,d0-d7/a0-a6
	rte
rysuj	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d6
	move.w	counter(pc),d6
	lea	way(pc),a6
	lea	$78000,a5
	move.w	0(a6,d6.w),d5 *pobierz dla
	move.w	2(a6,d6.w),d2 *spritea
	move.w	-2(a6,d6.w),d3 *pobierz dla
	move.w	-4(a6,d6.w),d4 *maski
	cmp.w	#-1,d5
	bne.s	nie_kon
	move.w	(a6),d5
	move.w	2(a6),d2
	clr.w	counter
nie_kon	add.l	d3,a5
	moveq	#0,d6
	moveq	#97,d7
maskuj_to
	move.l	d6,(a5)
	move.w	d6,4(a5)
	move.l	d6,8(a5)
	move.w	d6,12(a5)
	move.l	d6,16(a5)
	move.w	d6,20(a5)
	move.l	d6,24(a5)
	move.w	d6,28(a5)
	move.l	d6,32(a5)
	move.w	d6,36(a5)
	move.l	d6,40(a5)
	move.w	d6,44(a5)
	move.l	d6,48(a5)
	move.w	d6,52(a5)
	lea	160(a5),a5
	dbf	d7,maskuj_to
	lea	StalAdr(pc),a6
	lea	$78000,a5
	add.l	d2,a5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a6,d5.w),a6
	moveq	#97,d7
naszkicuj_to
	movem.l	(a6)+,d4-d6
	or.l	d4,(a5)
	or.w	d5,8(a5)
	swap	d5
	or.w	d5,4(a5)
	or.l	d6,10(a5)
	movem.l	(a6)+,d4-d6
	or.l	d4,16(a5)
	or.w	d5,24(a5)
	swap	d5
	or.w	d5,20(a5)
	or.l	d6,26(a5)
	movem.l	(a6)+,d4-d6
	or.l	d4,32(a5)
	or.w	d5,40(a5)
	swap	d5
	or.w	d5,36(a5)
	or.l	d6,42(a5)
	move.l	(a6)+,d5
	move.w	(a6)+,d6
	or.l	d5,48(a5)
	or.w	d6,52(a5)
	lea	160(a5),a5
	dbf	d7,naszkicuj_to
	addq.w	#4,counter
	rts
Equalz	moveq	#0,d4
	moveq	#0,d5
	lea	$ffff8800.w,a6
	lea	Cyfry(pc),a5
	lea	$79dd1+6,a4
	moveq	#8,d4
	bsr	Equalizer
	lea	$79dd9+6,a4
	moveq	#9,d4
	bsr	Equalizer
	lea	$79de8+6,a4
	moveq	#10,d4
	bsr	Equalizer
	rts
Equalizer
	move.b	d4,(a6)
	move.b	(a6),d4
	btst	#4,d4
	beq.s	dal1
	moveq	#15,d4
dal1	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	lea	(a5,d4.w),a3
wRiTe2	move.b	(a3)+,(a4)
	move.b	(a3)+,160(a4)
	move.b	(a3)+,320(a4)
	move.b	(a3)+,480(a4)
	move.b	(a3)+,640(a4)
	move.b	(a3)+,800(a4)
	move.b	(a3)+,960(a4)
	move.b	(a3)+,1120(a4)
	rts
reZ	move.w	sr,d0
	btst	#13,d0
	bne.s	SuperV
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
SuperV	stop	#$2300
	clr.b	$484.w
	move.b	#2,$ffff820a.w
	move.l	#$78000,d0
	lea	$ffff8200.w,a0
	swap	d0
	move.b	d0,1(a0)
	swap	d0
	lsr.w	#8,d0
	move.b	d0,3(a0)
	move.b	#2,10(a0)
	move.b	#0,96(a0)
	lea	pal(pc),a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,64(a0)
czycz	lea	$78000,a0
	move.w	#1333,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
clin	movem.l	d0-d5,(a0)
	lea	24(a0),a0
	dbf	d7,clin
	lea	music,a0
	move.w	#4999,d7
	moveq	#0,d0
psgj	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,psgj
	lea	Stalin,a0
	lea	music,a1
	lea	StalAdr(pc),a3
	move.l	a1,(a3)+
	moveq	#0,d4
	moveq	#15,d7
item	moveq	#5,d5
	moveq	#97,d6
set_1	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,06(a1)
	swap	d0
	or.w	d0,00(a1)
set_2	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,08(a1)
	swap	d0
	or.w	d0,02(a1)
set_3	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,10(a1)
	swap	d0
	or.w	d0,4(a1)
	addq.l	#6,a1
	addq.l	#2,a0
	dbf	d5,set_1
	addq.l	#6,a1
	moveq	#5,d5
	dbf	d6,set_1
	lea	Stalin,a0
	moveq	#5,d5
	moveq	#97,d6
	move.l	a1,(a3)+
	addq.w	#1,d4
	dbf	d7,set_1
	move.l	#$78000,d0
	lea	$ffff8200.w,a0
	swap	d0
	move.b	d0,1(a0)
	swap	d0
	lsr.w	#8,d0
	move.b	d0,3(a0)
	lea	way(pc),a0
ReCaL	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a0),d0
	move.w	2(a0),d1
	cmp.w	#-1,d0
	beq.s	ReCaLed
	divu	#16,d0
	move.w	d0,d2
	swap	d0
	mulu	#8,d2
	mulu	#160,d1
	add.w	d2,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	bra.s	ReCaL
ReCaLed	lea	MonST,a0
	lea	$78006,a1
	move.w	#3999,d7
uhu	move.w	(a0)+,(a1)
	addq.l	#8,a1
	dbf	d7,uhu
	lea	$79dd0+6,a4
	lea	Cyfry(pc),a3
	bsr	wRiTe2
	lea	$79dd8+6,a4
	lea	Cyfry(pc),a3
	bsr	wRiTe2
	lea	$79de1+6,a4
	lea	Cyfry(pc),a3
	bsr	wRiTe2
	rts
Cyfry	dc.l	$3C666E76,$66663C00
	dc.l	$18381818,$18187E00
	dc.l	$3C66060C,$18307E00
	dc.l	$7E0C180C,$06663C00
	dc.l	$0C1C3C6C,$7E0C0C00
	dc.l	$7E607C06,$06663C00
	dc.l	$3C60607C,$66663C00
	dc.l	$7E060C18,$30303000
	dc.l	$3C66663C,$66663C00
	dc.l	$3C66663E,$060C3800
	dc.l	$183C6666,$7E666600
	dc.l	$7C66667C,$66667C00
	dc.l	$3C666060,$60663C00
	dc.l	$786C6666,$666C7800
	dc.l	$7E60607C,$60607E00
	dc.l	$7E60607C,$60606000
pal	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$310,$111,$222,$333,$444,$555,$666,$777
counter	ds.l	2
StalAdr	ds.l	18
way	include	\aurora17\funkcja2.s
	include	\aurora17\okrag.s
	include	\aurora17\petla2.s
	dc.l	-1
skroll	moveq	#0,d5
	tst.w	control
	bne.s	przesun
	move.w	#0,kupa
	move.w	lit(pc),d5
	lea	tekst_1(pc),a6
	move.b	(a6,d5.w),d5
	cmp.b	#-1,d5
	bne.s	jeszcze
	move.b	(a6),d5
	clr.w	lit
jeszcze	and.l	#$3f,d5
	addq.w	#1,lit
	add.w	d5,d5
	add.w	d5,d5
	lea	letter(pc),a6
	add.l	d5,a6
	move.l	(a6),a6
	add.l	#fonts,a6
	move.l	a6,adr
	move.w	#16,control
przesun	move.l	#$76000+200*160,a5
	move.l	adr(pc),a6
	add.l	#1,adr
	moveq	#31,d7
	moveq	#0,d6
go	movep.l	1(a5),d6
	movep.l	d6,(a5)
	movep.l	8(a5),d6
	movep.l	d6,1(a5)
	movep.l	9(a5),d6
	movep.l	d6,8(a5)
	movep.l	16(a5),d6
	movep.l	d6,9(a5)
	movep.l	17(a5),d6
	movep.l	d6,16(a5)
	movep.l	24(a5),d6
	movep.l	d6,17(a5)
	movep.l	25(a5),d6
	movep.l	d6,24(a5)
	movep.l	32(a5),d6
	movep.l	d6,25(a5)
	movep.l	33(a5),d6
	movep.l	d6,32(a5)
	movep.l	40(a5),d6
	movep.l	d6,33(a5)
	movep.l	41(a5),d6
	movep.l	d6,40(a5)
	movep.l	48(a5),d6
	movep.l	d6,41(a5)
	movep.l	49(a5),d6
	movep.l	d6,48(a5)
	movep.l	56(a5),d6
	movep.l	d6,49(a5)
	movep.l	57(a5),d6
	movep.l	d6,56(a5)
	movep.l	64(a5),d6
	movep.l	d6,57(a5)
	movep.l	65(a5),d6
	movep.l	d6,64(a5)
	movep.l	72(a5),d6
	movep.l	d6,65(a5)
	movep.l	73(a5),d6
	movep.l	d6,72(a5)
	movep.l	80(a5),d6
	movep.l	d6,73(a5)
	movep.l	81(a5),d6
	movep.l	d6,80(a5)
	movep.l	88(a5),d6
	movep.l	d6,81(a5)
	movep.l	89(a5),d6
	movep.l	d6,88(a5)
	movep.l	96(a5),d6
	movep.l	d6,89(a5)
	movep.l	97(a5),d6
	movep.l	d6,96(a5)
	movep.l	104(a5),d6
	movep.l	d6,97(a5)
	movep.l	105(a5),d6
	movep.l	d6,104(a5)
	movep.l	112(a5),d6
	movep.l	d6,105(a5)
	movep.l	113(a5),d6
	movep.l	d6,112(a5)
	movep.l	120(a5),d6
	movep.l	d6,113(a5)
	movep.l	121(a5),d6
	movep.l	d6,120(a5)
	movep.l	128(a5),d6
	movep.l	d6,121(a5)
	movep.l	129(a5),d6
	movep.l	d6,128(a5)
	movep.l	136(a5),d6
	movep.l	d6,129(a5)
	movep.l	137(a5),d6
	movep.l	d6,136(a5)
	movep.l	144(a5),d6
	movep.l	d6,137(a5)
	movep.l	145(a5),d6
	movep.l	d6,144(a5)
	movep.l	152(a5),d6
	movep.l	d6,145(a5)
	movep.l	153(a5),d6
	movep.l	d6,152(a5)
	movep.l	(a6),d6
	movep.l	d6,153(a5)
	lea	160(a5),a5
	lea	16(a6),a6
	dbf	d7,go
	add.w	#1,kupa
	cmp.w	#2,kupa
	bne.s	nic_to
	add.l	#6,adr
nic_to	sub.w	#4,control
	rts
little_vbl
	lea	LiczAdr(pc),a0
	lea	KolAdr(pc),a1
	lea	Kol_1(pc),a2
	addq.w	#4,(a0)
	addq.l	#4,(a1)
	cmp.w	#42*20,(a0)
	bne.s	Kol_Not_Yet
	clr.w	(a0)
	move.l	a2,(a1)
Kol_Not_Yet
	rts

VBL	move.w	#-1,sss
	move.b	#$07,$ffff8201.w
	move.b	#$60,$ffff8203.w
	clr.b	$fffffa1b.w
	move.l	#HBL,$120.w
	move.b	#28,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7,-(a7)
	movem.l	Aurora_Kol(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	equal_
	bsr	Draw
	bsr	Napisy
	bsr	little_vbl
	jsr	(music+4)
	bsr	skroll
	cmp.b	#$39,Klawisz
	beq	End_Story
	cmp.b	#$66,Klawisz
	bne.s	NOTres
	move.l	#'Vat!',$1000.w
	bra	End_Story
NOTres	cmp.b	#$1e,Klawisz ;A
	bne.s	hasz1
	moveq	#1,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz1
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz1	cmp.b	#$30,Klawisz ;B
	bne.s	hasz2
	moveq	#3,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz2
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz2	cmp.b	#$2e,Klawisz ;C
	bne.s	hasz3
	moveq	#5,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz3
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz3	cmp.b	#$20,Klawisz ;D
	bne.s	hasz4
	moveq	#7,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz4
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz4	cmp.b	#$12,Klawisz ;E
	bne.s	hasz5
	moveq	#11,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz5
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz5	cmp.b	#$21,Klawisz ;F
	bne.s	hasz6
	moveq	#13,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz6
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz6	cmp.b	#$22,Klawisz ;G
	bne.s	hasz7
	moveq	#9,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz7
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz7	cmp.b	#$23,Klawisz ;H
	bne.s	hasz8
	moveq	#2,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz8
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz8	cmp.b	#$17,Klawisz ;I
	bne.s	hasz9
	moveq	#4,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz9
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz9	cmp.b	#$24,Klawisz ;J
	bne.s	hasz10
	moveq	#6,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz10
	move.b	d0,Wcisniety
	jsr	music
	bra	hasz11
hasz10	cmp.b	#$25,Klawisz ;K
	bne.s	hasz11
	moveq	#10,d0
	cmp.b	Wcisniety,d0
	beq.s	hasz11
	move.b	d0,Wcisniety
	jsr	music
hasz11	movem.l	(a7)+,d0-d7
	rte
Rte	rte
HBL	movem.l	a0-a1,-(a7)
	clr.b	$fffffa1b.w
	lea	$ffff8240.w,a1
	move.l	#$0000770,(a1)+
	move.l	#$6000500,(a1)+
	move.l	#$4000300,(a1)+
	move.l	#$2000222,(a1)+
	move.l	#$3330444,(a1)+
	move.l	#$5550666,(a1)+
	move.l	#$7770700,(a1)+
*******	move.l	#$6420775,(a1)+
	move.l	#HBL_1a,$120.w
	move.b	#15,$fffffa21.w
	move.b	#8,$fffffa1b.w
x	lea	$fffffa21.w,a0
	move.b	(a0),d0
x_883	cmp.b	(a0),d0
	beq.s	x_883
	move.l	KolAdr(pc),a0
	lea	$ffff8240.w,a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
K10	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
K20	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
K30	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
K40	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	clr.w	(a1)
	move.w	#$700,2(a1)
	movem.l	(a7)+,a0-a1
	bclr	#0,$fffffa0f.w
	rte
HBL_1a	move.w	#4,$ffff8242.w
	clr.b	$fffffa1b.w
	move.l	#HBL_5,$120.w
	move.b	#8,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
HBL_5	move.w	#5,$ffff8242.w
	move.l	#HBL_6,$120.w
	rte
HBL_6	move.w	#6,$ffff8242.w
	move.l	#HBL_7,$120.w
	rte
HBL_7	move.w	#7,$ffff8242.w
	move.l	#HBL_8,$120.w
	rte
HBL_8	move.w	#$207,$ffff8242.w
	move.l	#HBL_9,$120.w
	rte
HBL_9	move.w	#$307,$ffff8242.w
	move.l	#HBL_10,$120.w
	rte
HBL_10	move.w	#$407,$ffff8242.w
	move.l	#HBL_11,$120.w
	rte
HBL_11	move.w	#$507,$ffff8242.w
	move.l	#HBL_12,$120.w
	rte
HBL_12	move.w	#$607,$ffff8242.w
	move.l	#HBL_13,$120.w
	rte
HBL_13	move.w	#$707,$ffff8242.w
	move.l	#HBL_14,$120.w
	rte
HBL_14	move.w	#$737,$ffff8242.w
	move.l	#HBL_15,$120.w
	rte
HBL_15	move.w	#$100,$ffff8242.w
	move.l	#HBL_16,$120.w
	rte
HBL_16	move.w	#$200,$ffff8242.w
	move.l	#HBL_17,$120.w
	rte
HBL_17	move.w	#$300,$ffff8242.w
	move.l	#HBL_18,$120.w
	rte
HBL_18	move.w	#$400,$ffff8242.w
	move.l	#HBL_19,$120.w
	rte
HBL_19	move.w	#$500,$ffff8242.w
	move.l	#HBL_20,$120.w
	rte
HBL_20	move.w	#$600,$ffff8242.w
	clr.b	$fffffa1b.w
	move.l	#HBL_21,$120.w
	move.b	#26,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
HBL_21	movem.l	a0-a1,-(a7)
	clr.b	$fffffa1b.w
	move.l	#Ramka,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	lea	$fffffa21.w,a0
	move.b	(a0),d0
x_884	cmp.b	(a0),d0
	beq.s	x_884
	move.l	#Kol_1,a0
	lea	$ffff8240.w,a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
L10	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
L20	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
L30	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
L40	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	clr.w	(a1)
	movem.l	(a7)+,a0-a1
	bclr	#0,$fffffa0f.w
	rte
Ramka	move.l	a1,-(a7)
	lea	$ffff8240.w,a1
	move.l	#$0000777,(a1)+
	move.l	#$6660555,(a1)+
	move.l	#$4440333,(a1)+
	move.l	#$0040005,(a1)+
	move.l	#$0060007,(a1)+
	move.l	#$0270037,(a1)+
	move.l	#$0470057,(a1)+
	move.l	#$4670555,(a1)
	move.l	(a7)+,a1
	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(a7)
	lea	$fffffa21.w,a0
	move.b	#200,(a0)
	move.b	#8,$fffffa1b.w
	move.b	(a0),d0
x_882	cmp.b	(a0),d0
	beq.s	x_882
	move.b	#$fc,$ffff820a.w
	move.w	#2,d0
x_892	nop
	dbf	d0,x_892
	move.b	#$fe,$ffff820a.w
	movem.l	(a7)+,d0/a0
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
equal_	move.l	#160,d5
	moveq	#0,d0
	moveq	#0,d1
	lea	$ffff8800.w,a5
	lea	AdrLed(pc),a2
	lea	$7a160+35*160,a6
	moveq	#8,d0
	bsr	equalizer
	lea	$7a170+35*160,a6
	moveq	#9,d0
	bsr	equalizer
	lea	$7a180+35*160,a6
	moveq	#10,d0
	bsr	equalizer
	rts
equalizer
	move.b	d0,(a5)
	move.b	(a5),d0
	btst	#4,d0
	beq.s	dal0
	moveq	#15,d0
dal0	add.w	d0,d0
	add.w	d0,d0
	move.l	(a2,d0.w),a3
	moveq	#29,d7
wRiTe	move.w	(a3)+,(a6)
	move.w	(a3)+,8(a6)
	move.w	(a3)+,160(a6)
	move.w	(a3)+,168(a6)
	lea	320(a6),a6
	dbf	d7,wRiTe
	rts
Napisy
	lea	AdrFala1(pc),a2
	lea	FaLaSiN(pc),a3
	lea	$77bd8-160+1280*0,a4
	lea	FalaLicz01(pc),a5
	bsr	Napisy2
	lea	AdrFala2(pc),a2
	lea	$77bd8-160+1280*1,a4
	lea	FalaLicz02(pc),a5
	bsr	Napisy2
	lea	AdrFala3(pc),a2
	lea	$77bd8-160+1280*2,a4
	lea	FalaLicz03(pc),a5
	bsr	Napisy2
	lea	AdrFala4(pc),a2
	lea	$77bd8-160+1280*3,a4
	lea	FalaLicz04(pc),a5
	bsr	Napisy2
	lea	AdrFala5(pc),a2
	lea	$77bd8-160+1280*4,a4
	lea	FalaLicz05(pc),a5
	bsr	Napisy2
	lea	AdrFala6(pc),a2
	lea	$77bd8-160+1280*5,a4
	lea	FalaLicz06(pc),a5
	bsr	Napisy2
	lea	AdrFala7(pc),a2
	lea	$77bd8-160+1280*6,a4
	lea	FalaLicz07(pc),a5
	bsr	Napisy2
	lea	AdrFala8(pc),a2
	lea	$77bd8-160+1280*7,a4
	lea	FalaLicz08(pc),a5
	bsr	Napisy2
	lea	AdrFala9(pc),a2
	lea	$77bd8-160+1280*8,a4
	lea	FalaLicz09(pc),a5
	bsr	Napisy2
	lea	AdrFala10(pc),a2
	lea	$77bd8-160+1280*9,a4
	lea	FalaLicz10(pc),a5
	bsr	Napisy2
	lea	AdrFala11(pc),a2
	lea	$77bd8-160+1280*10,a4
	lea	FalaLicz11(pc),a5
	bsr	Napisy2
	rts
Napisy2	moveq	#0,d4
	moveq	#0,d5
	move.w	(a5),d4
	move.w	0(a3,d4.w),d5
	move.w	2(a3,d4.w),d4
	cmp.w	#-1,d5
	bne.s	JuTa
	move.w	(a3),d5
	move.w	2(a3),d4
	clr.w	(a5)
JuTa	add.l	d5,a4
	add.w	d4,d4
	add.w	d4,d4
	add.w	#4,(a5)
	move.l	(a2,d4.w),a6
	moveq	#0,d6
PifPaf0	move.w	d6,-8(a4)
	move.w	(a6)+,00(a4)
	move.w	(a6)+,08(a4)
	move.w	(a6)+,16(a4)
	move.w	(a6)+,24(a4)
	move.w	(a6)+,32(a4)
	move.w	(a6)+,40(a4)
	move.w	(a6)+,48(a4)
	move.w	d6,56(a4)
PifPaf1	move.w	d6,152(a4)
	move.w	(a6)+,160(a4)
	move.w	(a6)+,168(a4)
	move.w	(a6)+,176(a4)
	move.w	(a6)+,184(a4)
	move.w	(a6)+,192(a4)
	move.w	(a6)+,200(a4)
	move.w	(a6)+,208(a4)
	move.w	d6,216(a4)
PifPaf2	move.w	d6,312(a4)
	move.w	(a6)+,320(a4)
	move.w	(a6)+,328(a4)
	move.w	(a6)+,336(a4)
	move.w	(a6)+,344(a4)
	move.w	(a6)+,352(a4)
	move.w	(a6)+,360(a4)
	move.w	(a6)+,368(a4)
	move.w	d6,376(a4)
PifPaf3	move.w	d6,472(a4)
	move.w	(a6)+,480(a4)
	move.w	(a6)+,488(a4)
	move.w	(a6)+,496(a4)
	move.w	(a6)+,504(a4)
	move.w	(a6)+,512(a4)
	move.w	(a6)+,520(a4)
	move.w	(a6)+,528(a4)
	move.w	d6,536(a4)
PifPaf4	move.w	d6,632(a4)
	move.w	(a6)+,640(a4)
	move.w	(a6)+,648(a4)
	move.w	(a6)+,656(a4)
	move.w	(a6)+,664(a4)
	move.w	(a6)+,672(a4)
	move.w	(a6)+,680(a4)
	move.w	(a6)+,688(a4)
	move.w	d6,696(a4)
PifPaf5	move.w	d6,792(a4)
	move.w	(a6)+,800(a4)
	move.w	(a6)+,808(a4)
	move.w	(a6)+,816(a4)
	move.w	(a6)+,824(a4)
	move.w	(a6)+,832(a4)
	move.w	(a6)+,840(a4)
	move.w	(a6)+,848(a4)
	move.w	d6,856(a4)
PifPaf6	move.w	d6,952(a4)
	move.w	(a6)+,960(a4)
	move.w	(a6)+,968(a4)
	move.w	(a6)+,976(a4)
	move.w	(a6)+,984(a4)
	move.w	(a6)+,992(a4)
	move.w	(a6)+,1000(a4)
	move.w	(a6)+,1008(a4)
	move.w	d6,1016(a4)
PifPaf7	move.w	d6,1112(a4)
	move.w	(a6)+,1120(a4)
	move.w	(a6)+,1128(a4)
	move.w	(a6)+,1136(a4)
	move.w	(a6)+,1144(a4)
	move.w	(a6)+,1152(a4)
	move.w	(a6)+,1160(a4)
	move.w	(a6)+,1168(a4)
	move.w	d6,1176(a4)
	rts
przelicz
	lea	FaLaSiN(pc),a0
Nxt	moveq	#0,d0
	moveq	#0,d1
	move.l	(a0),d0
	cmp.l	#-1,d0
	beq.s	TRep
	divu	#16,d0
	move.w	d0,d1
	mulu	#8,d1
	move.w	d1,d0
	swap	d0
	move.l	d0,(a0)+
	bra.s	Nxt
TRep	rts
prepareFala
	lea	$70000,a0
	moveq	#0,d0
	move.w	#2000,d7
KlF	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,KlF
	lea	$70000,a1
	lea	AdrFala1(pc),a2
	lea	FaLe1(pc),a0
	move.l	a0,a6
F1	bsr	Szift
	lea	AdrFala2(pc),a2
	lea	FaLe2(pc),a0
	move.l	a0,a6
F2	bsr	Szift
	lea	AdrFala3(pc),a2
	lea	FaLe3(pc),a0
	move.l	a0,a6
F3	bsr	Szift
	lea	AdrFala4(pc),a2
	lea	FaLe4(pc),a0
	move.l	a0,a6
F4	bsr	Szift
	lea	AdrFala5(pc),a2
	lea	FaLe5(pc),a0
	move.l	a0,a6
F5	bsr	Szift
	lea	AdrFala6(pc),a2
	lea	FaLe6(pc),a0
	move.l	a0,a6
F6	bsr	Szift
	lea	AdrFala7(pc),a2
	lea	FaLe7(pc),a0
	move.l	a0,a6
F7	bsr	Szift
	lea	AdrFala8(pc),a2
	lea	FaLe8(pc),a0
	move.l	a0,a6
F8	bsr	Szift
	lea	AdrFala9(pc),a2
	lea	FaLe9(pc),a0
	move.l	a0,a6
F9	bsr	Szift
	lea	AdrFala10(pc),a2
	lea	FaLe10(pc),a0
	move.l	a0,a6
F10	bsr	Szift
	lea	AdrFala11(pc),a2
	lea	FaLe11(pc),a0
	move.l	a0,a6
F11	bsr	Szift
	rts
Szift	moveq	#00,d4
	moveq	#05,d5
	moveq	#07,d6
	moveq	#15,d7
	move.l	a1,(a2)+
Plan1	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,2(a1)
	swap	d0
	or.w	d0,0(a1)
	addq.l	#2,a1
	dbf	d5,Plan1
	addq.l	#2,a1
	moveq	#5,d5
	dbf	d6,Plan1
	moveq	#7,d6
	addq.w	#1,d4
	move.l	a1,(a2)+
	move.l	a6,a0
	dbf	d7,Plan1
	rts
FaLaSiN	include	\aurora17\sinus.s
	dc.l	-1,-1
AdrFala1 ds.l	18
AdrFala2 ds.l	18
AdrFala3 ds.l	18
AdrFala4 ds.l	18
AdrFala5 ds.l	18
AdrFala6 ds.l	18
AdrFala7 ds.l	18
AdrFala8 ds.l	18
AdrFala9 ds.l	18
AdrFala10 ds.l	18
AdrFala11 ds.l	18
FalaLicz01 dc.w	0/2
FalaLicz02 dc.w	8/2
FalaLicz03 dc.w	16/2
FalaLicz04 dc.w	24/2
FalaLicz05 dc.w	32/2
FalaLicz06 dc.w	48/2
FalaLicz07 dc.w	64/2
FalaLicz08 dc.w	80/2
FalaLicz09 dc.w	96/2
FalaLicz10 dc.w	112/2
FalaLicz11 dc.w	128/2
FaLe1	dc.l  $7C00F9FE,$7C7CFE06,$33006000,$C6018C30
	dc.l  $C6C6C007,$3480E000,$C6018030,$C6C0C007
	dc.l  $B4806000,$C600F830,$C6DEF806,$F4806000
	dc.l  $FE000C30,$FEC6C006,$73006000,$C6318C30
	dc.l  $C6C6C006,$30006000,$C630F830,$C67EFE06
	dc.l  $3000F000,$00000000,$00000000,$00000000
FaLe2	dc.l  $FC00F9FE,$7C7CFE06,$3301F000,$C6018C30
	dc.l  $C6C6C007,$34831800,$C6018030,$C6C0C007
	dc.l  $B4801800,$FC00F830,$C6DEF806,$F4803000
	dc.l  $C6000C30,$FEC6C006,$73006000,$C6318C30
	dc.l  $C6C6C006,$3000C000,$FC30F830,$C67EFE06
	dc.l  $3003F800,$00000000,$00000000,$00000000
FaLe3	dc.l  $7C00F9FE,$7C7CFE06,$3301F000,$C6018C30
	dc.l  $C6C6C007,$34831800,$C0018030,$C6C0C007
	dc.l  $B4801800,$C000F830,$C6DEF806,$F480F000
	dc.l  $C0000C30,$FEC6C006,$73001800,$C6318C30
	dc.l  $C6C6C006,$30031800,$7C30F830,$C67EFE06
	dc.l  $3001F000,$00000000,$00000000,$00000000
FaLe4	dc.l  $FC00F9FE,$7C7CFE06,$33005800,$C6018C30
	dc.l  $C6C6C007,$34809800,$C6018030,$C6C0C007
	dc.l  $B4811800,$C600F830,$C6DEF806,$F483F800
	dc.l  $C6000C30,$FEC6C006,$73001800,$C6318C30
	dc.l  $C6C6C006,$30001800,$FC30F830,$C67EFE06
	dc.l  $30001800,$00000000,$00000000,$00000000
FaLe5	dc.l  $FE00F9FE,$7C7CFE06,$3303F800,$C0018C30
	dc.l  $C6C6C007,$34830000,$C0018030,$C6C0C007
	dc.l  $B4830000,$F800F830,$C6DEF806,$F483F000
	dc.l  $C0000C30,$FEC6C006,$73001800,$C0318C30
	dc.l  $C6C6C006,$30001800,$FE30F830,$C67EFE06
	dc.l  $3003F000,$00000000,$00000000,$00000000
FaLe6	dc.l  $FE00F9FE,$7C7CFE06,$3301F000,$C0018C30
	dc.l  $C6C6C007,$34831800,$C0018030,$C6C0C007
	dc.l  $B4830000,$F800F830,$C6DEF806,$F483F000
	dc.l  $C0000C30,$FEC6C006,$73031800,$C0318C30
	dc.l  $C6C6C006,$30031800,$C030F830,$C67EFE06
	dc.l  $3001F000,$00000000,$00000000,$00000000
FaLe7	dc.l  $7C00F9FE,$7C7CFE06,$3303F800,$C6018C30
	dc.l  $C6C6C007,$34831800,$C0018030,$C6C0C007
	dc.l  $B4801800,$DE00F830,$C6DEF806,$F4807800
	dc.l  $C6000C30,$FEC6C006,$73001800,$C6318C30
	dc.l  $C6C6C006,$30001800,$7E30F830,$C67EFE06
	dc.l  $30001800,$00000000,$00000000,$00000000
FaLe8	dc.l  $C600F9FE,$7C7CFE06,$3301F000,$C6018C30
	dc.l  $C6C6C007,$34831800,$C6018030,$C6C0C007
	dc.l  $B4831800,$FE00F830,$C6DEF806,$F481F000
	dc.l  $C6000C30,$FEC6C006,$73031800,$C6318C30
	dc.l  $C6C6C006,$30031800,$C630F830,$C67EFE06
	dc.l  $3001F000,$00000000,$00000000,$00000000
FaLe9	dc.l  $3C00F9FE,$7C7CFE06,$3301F000,$18018C30
	dc.l  $C6C6C007,$34831800,$18018030,$C6C0C007
	dc.l  $B4831800,$1800F830,$C6DEF806,$F481F800
	dc.l  $18000C30,$FEC6C006,$73001800,$18318C30
	dc.l  $C6C6C006,$30031800,$3C30F830,$C67EFE06
	dc.l  $3001F000,$00000000,$00000000,$00000000
FaLe10	dc.l  $FE01F981,$FDFDFC06,$33E6FF00,$06018D81
	dc.l  $81801806,$36361800,$06018D81,$81803006
	dc.l  $36361800,$0601F981,$F9F06006,$B6361800
	dc.l  $06018181,$8180C007,$F7F61800,$C6318181
	dc.l  $81818007,$76361800,$7C3181FD,$FDFDFC06
	dc.l  $36361800,$00000000,$00000000,$00000000
FaLe11	dc.l  $C601FEC6,$FE03FB1B,$F0000000,$CC0030C6
	dc.l  $C003039B,$18000000,$D80030C6,$C00303DB
	dc.l  $18000000,$F00030FE,$F803E37B,$18000000
	dc.l  $D80030C6,$C003033B,$18000000,$CC3030C6
	dc.l  $C003031B,$18000000,$C63030C6,$FE03FB1B
	dc.l  $F0000000,$00000000,$00000000,$00000000
STkolory dc.l  $0FFF0F00,$00F00FF0,$000F0F0F,$00FF0555
	dc.l  $03330F33,$03F30FF3,$033F0F3F,$03FF0000
AdrLed	dc.l	Led1,Led2,Led3,Led4,Led5,Led6,Led7,Led8,Led9,Led10,Led11,Led12,Led13,Led14,Led15,Led16,Led16
Led1	ds.l	4*14
	dc.l  $00000000,$00000000,$00000000,$FFFFFFFF
Led2	ds.l	4*13
	dc.l  $00000000,$00000000,$00018000,$00066000
	dc.l  $00381C00,$01C00380,$1E000078,$E0000007
Led3	ds.l	4*13
	dc.l  $00018000,$00066000,$00181800,$00600600
	dc.l  $01800180,$06000060,$18000018,$E0000007
Led4	ds.l	4*12
	dc.l  $00010000,$00028000,$000C6000,$00101000
	dc.l  $00200800,$00C00400,$01000300,$02000080
	dc.l  $04000040,$18000030,$20000008,$C0000007
Led5	ds.l	4*11
	dc.l  $00010000,$00028000,$00044000,$00082000
	dc.l  $00101000,$00200800,$00400400,$00800200
	dc.l  $00800200,$01000100,$02000080,$04000040
	dc.l  $08000020,$10000010,$20000008,$C0000007
Led6	ds.l	4*9
	dc.l  $00000000,$00000000,$00000000,$00008000
	dc.l  $00008000,$00014000,$00014000,$00022000
	dc.l  $00041000,$00081000,$00080800,$00100400
	dc.l  $00200400,$00400200,$00400100,$00800080
	dc.l  $01000080,$02000040,$02000020,$04000020
	dc.l  $08000010,$10000008,$10000008,$E0000007
Led7	ds.l	4*8
	dc.l  $00000000,$00000000,$00000000,$00010000
	dc.l  $00010000,$00028000,$00028000,$00044000
	dc.l  $00044000,$00082000,$00101000,$00101000
	dc.l  $00200800,$00200800,$00400400,$00800200
	dc.l  $00800200,$01000100,$02000080,$02000080
	dc.l  $04000040,$04000040,$08000020,$10000010
	dc.l  $10000010,$20000008,$20000008,$C0000007
Led8	ds.l	4*7
	dc.l  $00000000,$00000000,$00000000,$00010000
	dc.l  $00010000,$00028000,$00028000,$00044000
	dc.l  $00044000,$00082000,$00082000,$00101000
	dc.l  $00101000,$00200800,$00200800,$00400400
	dc.l  $00400400,$00800200,$00800200,$01000100
	dc.l  $01000100,$02000080,$02000080,$04000040
	dc.l  $04000040,$08000020,$08000020,$10000010
	dc.l  $10000010,$20000008,$20000008,$C0000007
Led9	ds.l	4*7
	dc.l  $00010000,$00010000,$00028000,$00028000
	dc.l  $00044000,$00044000,$00082000,$00082000
	dc.l  $00101000,$00101000,$00200800,$00200800
	dc.l  $00200800,$00400400,$00400400,$00800200
	dc.l  $00800200,$01000100,$01000100,$02000080
	dc.l  $02000080,$02000080,$04000040,$04000040
	dc.l  $08000020,$08000020,$10000010,$10000010
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led10	ds.l	4*6
	dc.l  $00010000,$00010000,$00028000,$00028000
	dc.l  $00044000,$00044000,$00044000,$00082000
	dc.l  $00082000,$00101000,$00101000,$00101000
	dc.l  $00200800,$00200800,$00400400,$00400400
	dc.l  $00400400,$00800200,$00800200,$01000100
	dc.l  $01000100,$01000100,$02000080,$02000080
	dc.l  $04000040,$04000040,$04000040,$08000020
	dc.l  $08000020,$10000010,$10000010,$10000010
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led11	ds.l	4*4
	dc.l  $00000000,$00000000,$00000000,$00010000
	dc.l  $00010000,$00010000,$00028000,$00028000
	dc.l  $00028000,$00044000,$00044000,$00082000
	dc.l  $00082000,$00082000,$00101000,$00101000
	dc.l  $00101000,$00200800,$00200800,$00200800
	dc.l  $00400400,$00400400,$00400400,$00800200
	dc.l  $00800200,$01000100,$01000100,$01000100
	dc.l  $02000080,$02000080,$02000080,$04000040
	dc.l  $04000040,$04000040,$08000020,$08000020
	dc.l  $08000020,$10000010,$10000010,$20000008
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led12	ds.l	4*3
	dc.l  $00000000,$00000000,$00000000,$00010000
	dc.l  $00010000,$00010000,$00028000,$00028000
	dc.l  $00028000,$00044000,$00044000,$00044000
	dc.l  $00082000,$00082000,$00082000,$00101000
	dc.l  $00101000,$00101000,$00200800,$00200800
	dc.l  $00200800,$00400400,$00400400,$00400400
	dc.l  $00800200,$00800200,$00800200,$00800200
	dc.l  $01000100,$01000100,$01000100,$02000080
	dc.l  $02000080,$02000080,$04000040,$04000040
	dc.l  $04000040,$08000020,$08000020,$08000020
	dc.l  $10000010,$10000010,$10000010,$20000008
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led13	ds.l	4*2
	dc.l  $00000000,$00000000,$00010000,$00010000
	dc.l  $00010000,$00010000,$00028000,$00028000
	dc.l  $00028000,$00028000,$00044000,$00044000
	dc.l  $00044000,$00082000,$00082000,$00082000
	dc.l  $00101000,$00101000,$00101000,$00101000
	dc.l  $00200800,$00200800,$00200800,$00400400
	dc.l  $00400400,$00400400,$00800200,$00800200
	dc.l  $00800200,$00800200,$01000100,$01000100
	dc.l  $01000100,$02000080,$02000080,$02000080
	dc.l  $04000040,$04000040,$04000040,$04000040
	dc.l  $08000020,$08000020,$08000020,$10000010
	dc.l  $10000010,$10000010,$20000008,$20000008
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led14	ds.l	4
	dc.l  $00000000,$00000000,$00010000,$00010000
	dc.l  $00010000,$00010000,$00028000,$00028000
	dc.l  $00028000,$00028000,$00044000,$00044000
	dc.l  $00044000,$00044000,$00082000,$00082000
	dc.l  $00082000,$00101000,$00101000,$00101000
	dc.l  $00101000,$00200800,$00200800,$00200800
	dc.l  $00200800,$00400400,$00400400,$00400400
	dc.l  $00800200,$00800200,$00800200,$00800200
	dc.l  $01000100,$01000100,$01000100,$02000080
	dc.l  $02000080,$02000080,$02000080,$04000040
	dc.l  $04000040,$04000040,$04000040,$08000020
	dc.l  $08000020,$08000020,$10000010,$10000010
	dc.l  $10000010,$10000010,$20000008,$20000008
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led15	dc.l  $00000000,$00000000,$00000000,$00010000
	dc.l  $00010000,$00010000,$00010000,$00028000
	dc.l  $00028000,$00028000,$00028000,$00044000
	dc.l  $00044000,$00044000,$00044000,$00082000
	dc.l  $00082000,$00082000,$00082000,$00101000
	dc.l  $00101000,$00101000,$00101000,$00200800
	dc.l  $00200800,$00200800,$00200800,$00400400
	dc.l  $00400400,$00400400,$00400400,$00800200
	dc.l  $00800200,$00800200,$01000100,$01000100
	dc.l  $01000100,$01000100,$02000080,$02000080
	dc.l  $02000080,$02000080,$04000040,$04000040
	dc.l  $04000040,$04000040,$08000020,$08000020
	dc.l  $08000020,$08000020,$10000010,$10000010
	dc.l  $10000010,$10000010,$20000008,$20000008
	dc.l  $20000008,$20000008,$40000004,$C0000007
Led16	dc.l  $00010000,$00010000,$00010000,$00010000
	dc.l  $00028000,$00028000,$00028000,$00028000
	dc.l  $00044000,$00044000,$00044000,$00044000
	dc.l  $00082000,$00082000,$00082000,$00082000
	dc.l  $00101000,$00101000,$00101000,$00101000
	dc.l  $00200800,$00200800,$00200800,$00200800
	dc.l  $00400400,$00400400,$00400400,$00400400
	dc.l  $00800200,$00800200,$00800200,$00800200
	dc.l  $01000100,$01000100,$01000100,$01000100
	dc.l  $02000080,$02000080,$02000080,$02000080
	dc.l  $04000040,$04000040,$04000040,$04000040
	dc.l  $08000020,$08000020,$08000020,$08000020
	dc.l  $10000010,$10000010,$10000010,$10000010
	dc.l  $20000008,$20000008,$20000008,$20000008
	dc.l  $40000004,$40000004,$40000004,$C0000007
LiczAdr	dc.w	0
KolAdr	dc.l	Kol_1
Kol_1	rept	210
	dc.w	$600
	endr
	rept	42
	dc.w	$37
	endr
	rept	210
	dc.w	$600
	endr
Kol_2	dc.w	$070,$060,$050,$040,$030,$040,$050,$060
	dc.w	$770,$760,$650,$540,$430,$540,$650,$760
Aurora_Kol dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$070,$060,$050,$040,$030,$020,$010
Fonts_Kol dc.w	$000,$210,$320,$430,$540,$650,$760,$772
	dc.w	$000,$200,$300,$410,$520,$630,$642,$775
Klawisz	ds.w	1
lit	ds.w	1
adr	ds.l	1
control	ds.w	1
screen	dc.l	$78000 
kupa	ds.w	1
Przesun_Aurora
	dc.l	0,1,2,3,5,7,9
	dc.l	11,13,15,17,19
	dc.l	21,23,25,27,29
	dc.l	31,33,35,37,39,41,43,45
Half1	dc.l	47,49,51,53,55,57,59
	dc.l	61,63,65,67,69
	dc.l	71,73,75,77,79
	dc.l	81,83,85,87,89,91,93,95,96,97
Half2	dc.l	97,96,95,93,91,89,87,85,83,81
	dc.l	79,77,75,73,71,69,67
	dc.l	65,63,61,59,57
	dc.l	55,53,51,49,47,45,43,41,39
Half3	dc.l	37,35,33,31,29
	dc.l	27,25,23,21,19
	dc.l	17,15,13,11,9,7
	dc.l	5,3,2,1,0
	dc.l	-1
Control_Aurora	ds.w	1
Fix_Aurora	ds.w	1
A_Adresy ds.l	18
Zapisz	ds.l	10
Wcisniety dc.w	$100
tekst_1	
 dc.b	'          YEAH AND ALLRIGHT !!! TO CO TERAZ WIDZICIE TO PIERWSZY PRODUKT SPolKI '
 dc.b	'AUTORSKIEJ "VAT(CODE) AND PETER(GFX)". TO DENTRO(DEMKO-INTRO, JAKBY KTOs NIE WIEDZIAl)'
 dc.b	' NIE JEST MOzE DO KOnCA DOPRACOWANE, '
 dc.b	'ALE OBIECUJe zE NASTePNE BeDa LEPSZE. '
 dc.b	'JEDNOCZEsNIE JEST TO POWRoT GRUPY "QUANT" NA SCENe ST PO PONAD 2.5 ROCZNEJ '
 dc.b	'NIEOBECNOsCI. A WlAsCIWIE TYLKO JEJ CZesCI. "QUANT" TO PIERWSZA POLSKA GRUPA HACKERSKO-KODERSKA NA ATARI ST. '
 dc.b	'TWORZYLI Ja CHARLIE(CODER) I JA, CZYLI PETER(GRAFIK). '
 dc.b	'OSTATNIM PRODUKTEM "QUANT',39,'A" PRZED DlUGa PRZERWa BYlA GIERKA '
 dc.b	'"ONSLAUGHT" WYPUSZCZONA 5 MAJA 1990 ROKU (FONTY KToRE TERAZ OGLaDASZ '
 dc.b	'POCHODZa Z INTRA DO TEJ GRY). '
 dc.b	'A NIEDlUGO POTEM SlUCH O NAS ZAGINal. NA PONAD 2.5 ROKU. TO STRASZNE. '
 dc.b	'WZRUSZENIE ODBIERA MI MOWe. NO, DOSYc JUz TYCH KOMBATANCKICH WSPOMNIEn. '
 dc.b	'CZAS NA POZDROWIENIA. '
 dc.b	'POZDRAWIAMY WSZYSTKICH, A ZWlASZCZA NASTePUJaCE OSOBY'
 dc.b	' (WYMIENIONE W KOLEJNOsCI ALFABETYCZNEJ):    '
 dc.b	'ACID MAKER, '
 dc.b	'ADAM, '
 DC.B	'ANDREAS D., '
 dc.b	'BARONTRONIC, '
 dc.b	'BARTEK s., '
 dc.b	'CHARLIE (JEzELI JESZCZE zYJESZ, TO ODEZWIJ SIe !), '
 dc.b	'CIAPKI, '
 dc.b	'DAGMARA (JEDYNA ZNANA MI POSIADACZKA ST PlCI zEnSKIEJ), '
 dc.b	'DAREK R., '
 dc.b	'GAC KAZIMIERZ, '
 dc.b	'GAlGAN, '
 dc.b	'GRAF (A.n.), '
 dc.b	'ILLUSIONS (DLACZEGO MAGNUM NIE CHODZI NA MOIM ST ?), '
 dc.b	'IMMORTALS (CO TAM SlYCHAc W KIELCACH ?), '
 dc.b	'KIJOP, '
 dc.b	'LECH Z. (BILBO), '
 dc.b	'MARCHEW (DLACZEGO TWOJE SCROLLINGI CHODZa TAK POWOLI ? JEST WIELE OSoB, KToRE CZYTAJa SZYBCIEJ NIz PO 1 LITERCE...), '
 dc.b	'MAREK J., '
 dc.b	'MC MAT, '
 dc.b	'MIG-29 , '
 dc.b	'MIXX (KOSZALIN), '
 dc.b	'QUAST, '
 dc.b	'PERVERT, '
 dc.b	'RADZIO (lOCHU), '
 dc.b	'RMD (ROMAN, KIEDY DOSTANe FORSe ?), '
 dc.b	'RYSZARD l., '
 dc.b	'SILESIA ROUSERS, '
 dc.b	'TFTE, '
 dc.b	'TOMEK J., '
 dc.b	'TSV (HEJ RAFAl ! SGH FOREVER !), '
 dc.b	'YCA CREW, '
 dc.b	'ZYP (USA- SZYBKO KOnCZ SWOJE "ORYGINALNE" MEGA DEMO). '
 dc.b	'JEzELI O KIMs ZAPOMNIAlEM, TO PRZEPRASZAM. '
 dc.b	'A TERAZ OPOWIEM KAWAl. CZY WIESZ, zE NIEDlUGO WPROWADZa NOWE PODATKI ? '
 dc.b	'OD zON. ZA zONe DO 30 LAT - PODATEK OD LUKSUSU. ZA zONe DO 50 LAT - '
 dc.b	'PODATEK OBROTOWY. ZA zONe POWYzEJ 50 LAT - PODATEK OD NIERUCHOMOsCI. '
 dc.b	'HAHAHAHAHA ! DOBRE, NO NIE ? NIE OBRAzAJCIE SIe DZIEWCZYNY. ZMIEnMY TEMAT. '
 dc.b	'SKORO DEMKO TO NOSI BARDZO POLITYCZNa NAZWe (AURORA 1917), TO POWINNO BYc W NIM '
 dc.b	'COs O POLITYCE. NA POCZaTKU CHCIAlBYM POZDROWIc MOICH ULUBIONYCH POSloW. '
 dc.b	'MIANOWICIE POSlANKe BOBe, STEFANA NIESIOlOWSKIEGO, WIESlAWA CHRZANOWSKIEGO, MARKA JURKA I '
 dc.b	'ZENKA FRANKA. NIE MUSZe CHYBA MoWIc, JAK BLISKa JEST MI IDEA POWROTU DO sREDNIOWIECZA, '
 dc.b	'CZASoW INKWIZYCJI ETC. CIEKAWE, KIEDY ZOSTANIE WPROWADZONA CENZURA SCROLLINGoW '
 dc.b	'W DEMKACH ? PEWNIE JUz NIEDlUGO. TOTEz ABY NIE BYc OSKARzONYM O BRAK '
 dc.b	'WARTOsCI CHRZEsCIJAnSKICH RZUCe JAKIEs HASElKO. NIECH zYJE WALKA POSloW '
 dc.b	'ZCHN Z ZABoJCAMI ZYGOT !!! NO I W PORZaSIU, BYlO WZNIOsLE I Z WARTOsCIAMI '
 dc.b	'CHRZEsCIJAnSKIMI. TERAZ JUz zADEN CENZOR W SUTANNIE NIE PRZYCZEPI SIe '
 dc.b	'DO MNIE. MUSZe JESZCZE KOGOs POZDROWIc. OToz MEGA-SUPER-SPECIAL POZDROWIENIA PRZESYlAM '
 dc.b	'DLA LECHA WAleSY. ZA CO ? ZA CAlOKSZTAlT RADOSNEJ DZIAlALNOsCI NA STANOWISKU '
 dc.b	'PREZYDENTA RP. NIECH NAM zYJE, ROsNIE DUzY I GRUBY ! ODNOSZe WRAzENIE, ZE WSZYSCY '
 dc.b	'OBECNI POLITYCY ZA KOMUNY BYLI MOCNO BICI PO GlOWIE PRZEZ SB. SKUTKI Sa '
 dc.b	'WIDOCZNE TERAZ. WYSTARCZY OBEJRZEc OBRADY SEJMU ALBO POSlUCHAc CO MoWI '
 dc.b	'GlOWA PAnSTWA... NO DOBRA, JUz KOnCZe. TERAZ NAGRODA ZA TO, zE DOCZYTAlEs '
 dc.b	'TEN SCROLL DO KOnCA. W TYM DENTRZE JEST UKRYTY SCREEN. POTRAKTUJ TO JAKO '
 dc.b	'GWIAZDKOWY PREZENT NA GWIAZDKe... I NA TYM KOnCZe.   DO ZOBACZENIA WKRoTCE '
 dc.b	'W TEJ LUB INNEJ GALAKTYCE.....           WARSZAWA 93.02.08 '
 dc.b	'ADRES DO KORESPONDENCJI: PETER,   SOBIESKIEGO 8 M.77,   02-957 WARSZAWA        '
 dc.b	'   JESZCZE RAZ:    PETER,   SOBIESKIEGO 8 M.77,   02-957 WARSZAWA              '
 dc.b	'  P.S. DEGAS ELITE JEST NAJLEPSZY !!!                  CIACH!                                     '
 dc.b	-1,-1
 even
letter	dc.l	32*16*00,32*16*01,32*16*02,32*16*03,32*16*04,32*16*05,32*16*06,32*16*07,32*16*08,32*16*09
	dc.l	32*16*10,32*16*11,32*16*12,32*16*13,32*16*14,32*16*15,32*16*16,32*16*17,32*16*18,32*16*19
	dc.l	32*16*20,32*16*21,32*16*22,32*16*23,32*16*24,32*16*25,32*16*26,32*16*27,32*16*28,32*16*29
	dc.l	32*16*30,32*16*31,32*16*32,32*16*33,32*16*34,32*16*35,32*16*36,32*16*37,32*16*38,32*16*39
	dc.l	32*16*40,32*16*41,32*16*42,32*16*43,32*16*44,32*16*45,32*16*46,32*16*47,32*16*48,32*16*49
	dc.l	32*16*50,32*16*51,32*16*52,32*16*53,32*16*54,32*16*55,32*16*56,32*16*57,32*16*58,32*16*59
aurora	incbin	\aurora17\au-spr.img
auroraT	incbin	\aurora17\au-tlo.img
fonts	incbin	\aurora17\fonts.cod
Medal	incbin	\aurora17\medal.img
STart1	incbin	\aurora17\credits1.img
STart2	incbin	\aurora17\credits2.img
STart3	incbin	\aurora17\credits3.img
STart4	incbin	\aurora17\credits4.img
STart5	incbin	\aurora17\credits5.img
P_Tale	incbin	\aurora17\P_Tale.mus
MonST	incbin	\aurora17\monst.img
Stalin	incbin	\aurora17\stalin.img
music	incbin	\aurora17\wingsd.muz
End_Muz	end
