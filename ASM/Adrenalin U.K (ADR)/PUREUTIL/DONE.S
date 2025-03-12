	text
begin
	move.w	#4,-(a7)		;getrez
	trap	#$e
	addq.l	#2,a7
	move.w	d0,old_rez
	clr.w	-(a7)
	pea	$ffffffff.w
	pea	$ffffffff.w
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	lea	12(a7),a7
	pea	main(pc)
	move.w	#$26,-(a7)		;supexec
	trap	#$e
	addq.l	#6,a7
	move.w	old_rez,-(a7)
	pea	$ffffffff.w
	pea	$ffffffff.w
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	lea	12(a7),a7
	clr.w	-(a7)		;pterm0
	trap	#1
main	move.l	a7,old_a7
	lea	l0048,a7
	move.l	#l0049,d0
	clr.b	d0
	lea	l003e,a0
	move.l	d0,(a0)+
	addi.l	#$7d00,d0
	move.l	d0,(a0)
	clr.b	$ffff820d.w
	bsr	l000a
	lea	l0044,a0
	lea	l0045,a1
	move.w	#$c7,d0
	move.w	#$1540,d1
l0001	move.w	d1,(a0)+
	move.w	d1,(a1)+
	dbf	d0,l0001
	lea	pic_dat,a0
	movem.l	l003e,a1-a2
	move.w	#$f9f,d0
l0002	move.l	(a0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	move.l	(a0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	dbf	d0,l0002
	lea	l003e,a0
	lea	$ffff8201.w,a1
	movep.w	0(a1),d0
	move.w	d0,l003f
	move.b	1(a0),(a1)
	move.b	2(a0),2(a1)

	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,old_pal

	movem.l	pic_pal,d0-d7
	movem.l	d0-d7,(a0)
	move	#$2700,sr
	lea	$fffffa00.w,a0
	move.l	6(a0),l0039
	move.l	18(a0),l003a
	clr.l	6(a0)
	clr.l	18(a0)
	move.l	$70.w,old_70
	move.l	#new_70,$70.w
	move.w	26(a0),l0041
	move.w	32(a0),l0042
	move.l	$120.w,old_120
	clr.b	27(a0)
	move.l	#new_120,$120.w
	clr.b	33(a0)
	ori.b	#1,7(a0)
	ori.b	#1,19(a0)
	bclr	#3,23(a0)
	moveq	#0,d0
	jsr	music
	jsr	m_init
	move	#$2300,sr
	stop	#$2300
loop	btst	#0,$fffffc00.w
	beq.b	loop
	move.b	$fffffc02.w,d0
	cmpi.b	#$b9,d0
	bne.b	loop
	move	#$2700,sr
	moveq	#-1,d0
	jsr	music
	jsr	m_off
	lea	$fffffa00.w,a0
	move.l	l0039,6(a0)
	move.l	l003a,18(a0)
	move.l	old_70,$70.w
	move.w	l0041,26(a0)
	move.w	l0042,32(a0)
	move.l	old_120,$120.w
	bset	#3,23(a0)
	move	#$2300,sr
	bsr.b	empty_kb
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	lea	$ffff8201.w,a0
	move.w	l003f,d0
	movep.w	d0,0(a0)
	movea.l	old_a7,a7
	rts

empty_kb	btst	#0,$fffffc00.w
	beq.b	l0005
	move.b	$fffffc02.w,d0
	bra.b	empty_kb
l0005	rts

new_70	movem.l	a0-a6/d0-d7,-(a7)
	move.w	pic_pa2,$ffff8242.w
	lea	l003e,a0
	movem.l	(a0),d0-d1
	exg	d1,d0
	movem.l	d0-d1,(a0)
	lea	$ffff8201.w,a1
	move.b	1(a0),(a1)
	move.b	2(a0),2(a1)
	bsr.b	l0007
	jsr	m_vbl
	bsr	l0015
	bsr	l000d
	bsr	l000f
	movem.l	(a7)+,a0-a6/d0-d7
	rte

l0007	clr.b	$fffffa1b.w
	move.b	#$20,$fffffa21.w
	move.l	#new_120,$120.w
	lea	pal_2,a0
	move.w	(a0)+,l002e
	move.l	a0,l002d
	eori.w	#1,l002b
	beq.b	l0009
	lea	pal_1,a0
	lea	2(a0),a1
	move.w	(a0),d1
	moveq	#$28,d0
l0008	move.w	(a1)+,(a0)+
	dbf	d0,l0008
	move.w	d1,(a0)
l0009	move.b	#8,$fffffa1b.w
	rts

l000a	lea	l0046,a0
	lea	l0047,a1
	moveq	#0,d0
	moveq	#$f,d1
	move.w	#$ff0,d2
l000b	move.w	d0,d3
	and.w	d2,d3
	lsr.w	#1,d3
	move.w	d3,(a0)+
	move.w	d0,d3
	and.w	d1,d3
	sub.w	d1,d3
	bpl.b	l000c
	neg.w	d3
l000c	moveq	#0,d4
	bset	d3,d4
	move.w	d4,(a1)+
	addq.w	#1,d0
	cmp.w	#$140,d0
	bne.b	l000b
	rts

l000d	lea	l002f,a0
	movem.l	(a0),d0-d1
	exg	d1,d0
	movem.l	d0-d1,(a0)
	movea.l	d0,a1
	movea.l	l003e,a0
	addq.l	#4,a0
	move.w	#$63,d0
	moveq	#0,d1
l000e	move.w	(a1)+,d2
	move.w	d1,0(a0,d2.w)
	move.w	(a1)+,d2
	move.w	d1,0(a0,d2.w)
	dbf	d0,l000e
	rts

l000f	movea.l	l003e,a0
	addq.l	#4,a0
	lea	table,a1
	lea	l0046,a2
	lea	l0047,a3
	movea.l	l002f,a4
	move.w	#$13f,d3
	move.w	#$63,d0
l0010	move.w	(a1),d1
	subq.w	#1,d1
	bmi.b	l0013
l0011	move.w	d1,(a1)+
	move.w	(a1)+,d2
	add.w	d1,d1
	add.w	0(a2,d1.w),d2
	move.w	0(a3,d1.w),d1
	or.w	d1,0(a0,d2.w)
	move.w	d2,(a4)+
	move.w	(a1),d1
	subq.w	#2,d1
	bmi.b	l0014
l0012	move.w	d1,(a1)+
	move.w	(a1)+,d2
	add.w	d1,d1
	add.w	0(a2,d1.w),d2
	move.w	0(a3,d1.w),d1
	or.w	d1,0(a0,d2.w)
	move.w	d2,(a4)+
	dbf	d0,l0010
	rts

l0013	add.w	d3,d1
	bra.b	l0011
l0014	add.w	d3,d1
	bra.b	l0012
l0015	tst.w	l0028
	bne	l001a
	tst.w	l0029
	bne	l001e
	movea.l	text_ptr,a0
	lea	new_font,a1
	movem.l	l003e,a2-a3
	moveq	#0,d0
	move.b	(a0)+,d0
	beq	l0017
	cmp.b	#2,d0
	beq	l0018
	cmp.b	#1,d0
	beq	l0019
	subi.b	#$20,d0
	lsl.w	#3,d0
	adda.l	d0,a1
	move.w	l0027,d0
	move.w	l0026,d1
	move.w	d1,d2
	andi.w	#$ff0,d2
	lsr.w	#1,d2
	andi.w	#$f,d1
	beq.b	l0016
	addq.w	#1,d2
l0016	add.w	d2,d0
	adda.l	d0,a2
	adda.l	d0,a3
	move.b	(a1),(a2)
	move.b	(a1)+,(a3)
	move.b	(a1),160(a2)
	move.b	(a1)+,160(a3)
	move.b	(a1),320(a2)
	move.b	(a1)+,320(a3)
	move.b	(a1),480(a2)
	move.b	(a1)+,480(a3)
	move.b	(a1),640(a2)
	move.b	(a1)+,640(a3)
	move.b	(a1),800(a2)
	move.b	(a1)+,800(a3)
	move.b	(a1),960(a2)
	move.b	(a1)+,960(a3)
	move.b	(a1),1120(a2)
	move.b	(a1)+,1120(a3)
	addq.w	#8,l0026
	move.w	#4,l0029
	move.l	a0,text_ptr
	rts

l0017	move.w	#$ffff,l0028
	clr.w	l0029
	rts

l0018	clr.w	l0026
	addi.w	#$500,l0027
	move.l	a0,text_ptr
	rts

l0019	move.w	#1,l0028
	clr.w	l0029
	move.l	a0,text_ptr
	rts

l001a	movem.l	l003e,a0-a1
	lea	5440(a0),a0
	lea	5440(a1),a1
	moveq	#0,d0
	move.w	l0029,d0
	adda.l	d0,a0
	adda.l	d0,a1
	moveq	#$13,d0
	moveq	#0,d1
l001b	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	dbf	d0,l001b
	addi.w	#$a0,l0029
	cmpi.w	#$5be0,l0029
	bne.b	l001d
	cmpi.w	#$ffff,l0028
	bne.b	l001c
	move.l	#text_mess,text_ptr
l001c	clr.w	l0028
	clr.w	l0026
	move.w	#$1900,l0027
	clr.w	l0029
l001d	rts

l001e	subq.w	#1,l0029
	rts

new_120	move.w	d0,-(a7)
	pea	(a0)
	lea	$fffffa21.w,a0
	clr.b	$fffffa1b.w
	move.l	#l0021,$120.w
	move.b	#$94,(a0)
	move.b	#8,$fffffa1b.w
	move.b	(a0),d0
l0020	cmp.b	(a0),d0
	beq.b	l0020
	pea	(a1)
	lea	pal_1(pc),a0
	lea	$ffff8240.w,a1
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	(a0)+,(a1)
	and.w	d0,d0
	move.w	#1,(a1)
	movea.l	(a7)+,a1
	movea.l	(a7)+,a0
	move.w	(a7)+,d0
	rte

l0021	move.w	d0,-(a7)
	pea	(a0)
	pea	(a1)
	lea	$fffffa21.w,a0
	lea	$fffffa1b.w,a1
	clr.b	(a1)
	move.l	#l0023,$120.w
	move.b	#$c8,(a0)
	move.b	#8,(a1)
	move.b	(a0),d0
l0022	cmp.b	(a0),d0
	beq.b	l0022
	clr.b	(a1)
	move.b	#1,(a0)
	move.b	#8,(a1)
	lea	l002b(pc),a0
	lea	$ffff8240.w,a1
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	move.w	-(a0),(a1)
	clr.w	(a1)
	movea.l	(a7)+,a1
	movea.l	(a7)+,a0
	move.w	(a7)+,d0
	rte

l0023	move.w	l002e(pc),$ffff8242.w
	pea	(a0)
	movea.l	l002d(pc),a0
	move.w	(a0)+,l002e
	move.l	a0,l002d
	movea.l	(a7)+,a0
	rte

	data

;
; 1 = New text page
; 2 = New line

text_mess
	dc.b	'           ME(STE) PRESENTS',2,2
	dc.b	'     PURE ENERGY UTILITIES DISC 15A',2,2
	dc.b	'  ',2
	dc.b	'         PROTEXT V6.04 (DISC 1)        ',2,2
	dc.b	'    NEOCHROME MASTER TUTORIAL (DISC 1)      ',2,2,2,2
	dc.b	'This intro was coded by Dr Computer/ADR.',2
	dc.b	'   Logo ripped from MB fonts Disk 1.',2
	dc.b	'   Half-track Music by Lotus/ETERNAL',1
	dc.b	'GREETZ TO ALL ON THE ST SCENE.......',2
	dc.b	' ',2
	dc.b	' CONTACT US AT:       ',2
	dc.b	'                P.O BOX 1391 - HOVE ',2
	dc.b	'                     EAST-SUSSEX',2
	dc.b	'                       BN3 5DU',2
	dc.b	'                        ENGLAND ',2
	dc.b	'       ',2
	dc.b	' ALL SOFTWARE WAS SUPPLIED BY',2
	dc.b	' HAIRY MONSTER, MARIO AND PAGESTREAM    ',2,2
	dc.b	'  ALL SOFTWARE IS ARCHIVED',2
	dc.b	' ',2
	dc.b	'             PURE ENERGY IN 93     ',2,2,2
	dc.b	'12.11.93',2
	dc.b	'                                       ',2,0

text_ptr	dc.l	text_mess

l0026	dc.b	0,0
l0027	dc.b	$19,0
l0028	dc.b	0,0
l0029	dc.b	0,0

pal_1	dc.b	0,7,0,$17,0,$27,0,'7'
	dc.b	0,'G',0,'W',0,'g',0,'w'
	dc.b	0,'v',0,'u',0,'t',0,'s'
	dc.b	0,'r',0,'q',0,'p',1,'p'
	dc.b	2,'p',3,'p',4,'p',5,'p'
	dc.b	6,'p',7,'p',7,'`',7,'P'
	dc.b	7,'@',7,'0',7,' ',7,$10
	dc.b	7,0,7,1,7,2,7,3
	dc.b	7,4,7,5,7,6,7,7
	dc.b	6,7,5,7,4,7,3,7
	dc.b	2,7,1,7
l002b	dc.b	0,0
pal_2	dc.b	0,0,1,1,1,1,1,1
	dc.b	2,2,2,2,3,3,4,4
	dc.b	5,5,6,6,7,7,7,7
	dc.b	6,6,5,5,4,4,3,3
	dc.b	2,2,2,2,1,1,1,1
	dc.b	0,0
l002d	dc.l	pal_2
l002e	dc.b	0,0
l002f	dc.l	l0044
	dc.l	l0045
	dc.b	0,0

piccy	incbin	'pure.pi1'
	even

pic_pal	equ	piccy+2

pic_pa2	equ	piccy+4
pic_dat	equ	piccy+34

	dc.b	0,1,0,1,0,1,0,1
	dcb.w	8

table	dc.b	0,$a1,': ',0,$fa,'D '
	dc.b	0,'jZ',$a0,0,$a2,'G',$e0
	dc.b	1,$d,'b ',0,$b4,',`'
	dc.b	0,$c1,'V@',0,'L6`'
	dc.b	0,$10,'[@',0,$cb,'#',$a0
	dc.b	0,$f3,'o',$e0,0,'r`@'
	dc.b	0,$de,'I ',0,'cB',$e0
	dc.b	1,'.<',0,0,$fe,$1f,'@'
	dc.b	0,$18,'l ',0,'0V@'
	dc.b	0,'$%',$80,0,$a2,'I',$c0
	dc.b	1,'0 ',$80,0,4,'2',0
	dc.b	1,'%d',0,0,$eb,$27,'`'
	dc.b	0,$1a,'[@',0,'j& '
	dc.b	1,4,'g',$c0,0,$f4,'Q',$e0
	dc.b	0,$d0,'5 ',0,9,'2',0
	dc.b	0,'"K',0,0,'K2',$a0
	dc.b	0,$a4,'S ',0,'_J`'
	dc.b	0,$c6,'&',$c0,0,$eb,'Z',0
	dc.b	0,'ŽE`',0,'W,`'
	dc.b	0,$be,'@`',0,$de,'l '
	dc.b	0,$d2,'] ',1,$17,'=@'
	dc.b	0,$97,'1`',0,$ca,' ',$80
	dc.b	0,$c2,'_',0,1,'9K',$a0
	dc.b	0,$c8,'i',0,0,'k_',$a0
	dc.b	0,$f3,'+',$c0,1,')G@'
	dc.b	0,$b6,'V',$e0,0,$9f,'K',$a0
	dc.b	0,'i)',$e0,0,$bc,'-',0
	dc.b	0,$fc,'] ',0,'3',$27,'`'
	dc.b	0,'>8',$e0,0,$c,'D',$c0
	dc.b	1,'4X',$c0,0,'`o@'
	dc.b	0,$e8,$16,$80,1,2,$16,$80
	dc.b	0,'gL',$e0,0,$ca,$15,'@'
	dc.b	1,$18,'] ',1,'<%',$80
	dc.b	1,$10,$1e,$a0,0,$a6,'Y`'
	dc.b	0,$d5,'l',$c0,0,$91,',`'
	dc.b	1,$b,'%',$80,1,'8b',$c0
	dc.b	1,',',$1f,$e0,1,$1d,'.',$e0
	dc.b	1,'$b ',1,'5N '
	dc.b	0,$10,'i',$a0,0,$ce,'5',$c0
	dc.b	0,'pW',$80,0,'=(',0
	dc.b	1,'=n',$a0,0,$bd,'& '
	dc.b	0,'4U',$a0,0,'EA',0
	dc.b	0,$c5,'p',$80,0,$ce,'M',$80
	dc.b	0,$c2,$1f,'@',0,$b4,'N',$c0
	dc.b	0,'!: ',0,'%0',$c0
	dc.b	0,'eA',0,1,2,'X',$c0
	dc.b	0,$fa,'2',$a0,0,'}S '
	dc.b	0,'Q.@',1,'0"`'
	dc.b	1,',N ',0,'=`',$e0
	dc.b	1,$27,'7',$a0,0,$17,')',$e0
	dc.b	0,'.n',$a0,0,$fe,'n',$a0
	dc.b	0,$8c,';`',0,$a5,'`@'
	dc.b	0,$b0,'7',0,0,$90,'j',$e0
	dc.b	0,$bc,'G',$e0,0,$ec,'L@'
	dc.b	0,$a,'U',$a0,0,$91,'l',$c0
	dc.b	0,$d7,'C',$80,0,'E2',0
	dc.b	0,$b9,'L@',1,'0',$15,'@'
	dc.b	1,'=I ',0,$94,'S',$c0
	dc.b	0,'0Q@',1,'2n',$a0
	dc.b	0,'s9',$80,0,$e3,'L',$e0
	dc.b	1,'4_',0,1,';i',0
	dc.b	0,$96,'D ',0,$15,'+ '
	dc.b	0,'}8@',0,'X_',0
	dc.b	0,'`J`',0,'ao',$e0
	dc.b	0,$1f,'>',$80,0,$bf,'-',0
	dc.b	0,$8c,' ',$80,0,$a4,'=@'
	dc.b	0,'š#',$a0,0,$ae,'^`'
	dc.b	0,';',$1b,$80,0,$17,'b '
	dc.b	0,$cb,'b ',0,'z1`'
	dc.b	0,$13,'(',0,0,'8<',$a0
	dc.b	0,$df,'W',$80,0,$a6,'h`'
	dc.b	0,$d9,'4',$80,0,'iF',0
	dc.b	1,'>c`',1,8,'Q@'
	dc.b	0,$f7,'Z',0,0,$bc,'&',$c0
	dc.b	0,'+1`',1,$b,'=',$e0
	dc.b	0,'@7',$a0,1,'=G@'
	dc.b	1,'8',$16,$80,0,'#] '
	dc.b	0,'wW',$80,1,'#',$16,$80
	dc.b	0,$a3,'P',0,0,$a8,'L@'
	dc.b	0,$af,')',$e0,0,$ba,'5 '
	dc.b	0,'7-',0,0,$b2,$1c,' '
	dc.b	0,'X_',$a0,0,'oV',$e0
	dc.b	0,'IC',$80,1,4,'8',$e0
	dc.b	0,$b9,'U',$a0,0,$ae,'g',$c0
	dc.b	0,$d8,'+',$c0,0,$b9,'o',$e0
	dc.b	0,'>@`',0,$f0,'(',0
	dc.b	0,'<B@',0,$82,'F',$a0
	dc.b	0,$10,'F',$a0,1,'7n',0
	dc.b	0,'šn',$a0,0,$e6,'c`'
	dc.b	1,$17,'#',$a0,0,$27,')@'
	dc.b	0,$d1,'3',$e0,0,$95,'=@'
	dc.b	0,'\a',$80,0,'qU',0
	dc.b	1,$b,'#',0,1,7,'X '
	dc.b	0,$9d,'6`',0,$d,'o',$e0
	dc.b	0,$e0,'5 ',0,'SN '
	dc.b	0,'mp',$80,0,$15,'_',0
	dc.b	0,$f1,'o@',0,$e8,'o',$e0
	dc.b	0,'.j@',0,'";`'
	dc.b	1,'/l',$c0,0,$16,'#',$a0
	dc.b	0,$14,'F',0,0,'D',$1d,'`'

new_font
	incbin	'pure.fon'
	even
	
music	incbin	'lotus.mus'
	even

m_init	equ	music+18
m_off	equ	music+22
m_vbl	equ	music+26

	bss
l0039	ds.l	1
l003a	ds.l	1
old_70	ds.l	1
old_pal	ds.b	32
old_a7	ds.l	1
l003e	ds.b	8
l003f	ds.w	1
old_rez	ds.w	1
l0041	ds.w	1
l0042	ds.w	1
old_120	ds.l	1
l0044	ds.b	400
l0045	ds.b	400
l0046	ds.b	640
l0047	ds.b	1152
l0048	ds.b	260
l0049	ds.b	64000
zuend	end
