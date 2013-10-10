;	routine

	jmp	start
	include	macro&co.s
	include	fal_rez2.s

start
	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1	
	addq.l	#6,sp
	bsr	init_trap
	bsr	init_ecran
	bsr	calc_pal_fonte
	bsr	init_pal2

	asave_palette
	asave_screen
	asave_video
	trap	#3
	bsr	affiche_graph
	aset_screen	ecran
	aset_video	#1

	bsr	init_pal_fonte
	aset_nbcoul	#pal,#$ffff9800,#128
	trap	#3

	move.l	#text,p_text
	bsr	si_va
	move.l	#text2,p_text
	bsr	si_va
	move.l	#text3,p_text
	bsr	si_va
	
	lea	trans,a0
	bsr	reloc
	lea	pal+32*4(pc),a0
	move.l	#$80800080,d1
	move	#32-1,d0
.loop	move.l	d1,(a0)+
	dbf	d0,.loop
	aset_nbcoul	#pal,#$ffff9800,#128
	vsync
	trap	#3
	movem.l	ecran,a0-a1
	jsr	trans

	arestore_palette
	arestore_screen
	arestore_video
	trap	#3

	clr.L	-(sp)
	trap	#1


si_va
	bsr	search_char
	move.l	ecran,a1	
	lea	(384*20)+80(a1),a1
	bsr	aff_bout2
	bsr	search_char
	move.l	ecran,a1	
	lea	(384*50)+128(a1),a1
	bsr	aff_bout2
	bsr	search_char
	move.l	ecran,a1	
	lea	(384*80)+128(a1),a1
	bsr	aff_bout2
	bsr	display
	vsync
	move.l	ecran,a1
	lea	(384*20)+80(a1),a1
	moveq	#0,d0
	move	#80,d7
cls
	move	#18,d6
.cls2
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	dbf	d6,.cls2
	lea	384-(19*16)(a1),a1
	dbf	d7,cls
	rts


display
.cont1
	vsync
	aset_nbcoul	#pal,#$ffff9800,#128
	trap	#3
	move	#9,fade_ok
	bsr	fade_up
	tst.w	fade_ok
	bne.s	.cont1
	move	#100,d7
wait	vsync
	dbf	d7,wait
.cont2
	vsync
	aset_nbcoul	#pal,#$ffff9800,#128
	trap	#3
	move	#9,fade_ok
	bsr	fade_down
	tst.w	fade_ok
	bne.s	.cont2
	vsync
	aset_nbcoul	#pal,#$ffff9800,#128
	trap	#3
	rts

fade_up
	lea	palette_fonte+4(pc),a4
	lea	pal+32*4(pc),a1
	bsr	.fadeu
	lea	pal+64*4(pc),a1
	bsr	.fadeu
	lea	pal+(64+32)*4(pc),a1
	bsr	.fadeu
	rts
.fadeu
.loop_fade
	rept	2
	move.b	(a1),d0
	addq.b	#8,d0
	cmp.b	(a4)+,d0
	bcs.s	*+10
	subq.w	#1,fade_ok
	move.b	(a1),d0
	move.b	d0,(a1)+
	endr
	addq.l	#1,a1
	addq.l	#1,a4
	move.b	(a1),d0
	addq.b	#8,d0
	cmp.b	(a4)+,d0
	bcs.s	*+10
	subq.w	#1,fade_ok
	move.b	(a1),d0
	move.b	d0,(a1)+
	rts

fade_down
	lea	pal+32*4(pc),a1
	bsr	.faded
	lea	pal+64*4(pc),a1
	bsr	.faded
	lea	pal+(64+32)*4(pc),a1
	bsr	.faded
	rts
.faded
.loop_fade
	rept	2
	move.b	(a1),d0
	sub.b	#8,d0
	bcc.s	*+10
	subq.w	#1,fade_ok
	move.b	(a1),d0
	move.b	d0,(a1)+
	endr
	addq.l	#1,a1
	move.b	(a1),d0
	sub.b	#8,d0
	bcc.s	*+10
	subq.w	#1,fade_ok
	move.b	(a1),d0
	move.b	d0,(a1)+
	rts





	




init_pal_fonte
	lea	pal(pc),a0
	clr.l	32*4(a0)
	clr.l	64*4(a0)
	clr.l	(64+32)*4(a0)
	rts



affiche_graph
	lea	img(pc),a0
	move.l	ecran,a1
	move.l	ecran+4,a2
	lea	2*16(a1),a1
	lea	2*16(a2),a2
	add.L	#39*384,a1
	add.L	#39*384,a2
	move	#200-1,d1
.aff_img2
	move	#320/16-1,d0
.aff_img
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	addq	#6,a1
	addq	#6,a2
	dbf	d0,.aff_img
	lea	4*16(a1),a1
	lea	4*16(a2),a2
	dbf	d1,.aff_img2
	rts


init_ecran	
	lea	ecran,a1
	lea	becran,a0
	move.l	a0,d0
	addq	#4,d0
	and.b	#$fc,d0
	move.L	d0,(a1)+
	move.l	d0,a2
	add.l	#384*240,d0
	move.l	d0,(a1)+
	move.L	d0,a3
	move	#384*240/4-1,d7
cls_screen
	clr.l	(a2)+
	clr.l	(a3)+
	dbf	d7,cls_screen
	rts

calc_pal_fonte
	lea	palette_fonte(pc),a0
	lea	table_ste(pc),a1
	lea	fonte+2(pc),a2
	move	#4-1,d7
.calc_pal
	moveq	#0,d0
	moveq	#0,d3
	move	(a2)+,d0
	move.l	d0,d1
	move.l	d1,d2
	and	#$f,d0
	move.b	(a1,d0),d3
	lsl	#8,d3
	swap	d3
	lsr	#4,d1
	and	#$f,d1
	move.b	(a1,d1),d1
	swap	d1
	add.l	d1,d3
	lsr	#8,d2
	and	#$f,d2
	add.b	(a1,d2),d3
	move.l	d3,(a0)+
	dbf	d7,.calc_pal
	rts


search_char
	lea	pbuffer,a1
	move.l	p_text(pc),a0
.loop2
	move.b	(a0)+,d0	
	bmi.s	.no_text
	beq.s	.end_line
	moveq	#-1,d2
	lea	list_char(pc),a2
.loop
	move.b	(a2)+,d1
	bmi.s	.no_think
.cont
	addq	#1,d2
	cmp.b	d1,d0
	bne.s	.loop
	lea	fonte+34(pc),a2
	move	d2,d3
	sub	#20,d2
	bmi.s	.no_add_line
	add.l	#20*4*16,a2
	bra.s	.aj
.no_add_line
	move	d3,d2
.aj
	lsl	#2,d2
	add	d2,a2
	move.l	a2,(a1)+
	bra.s	.loop2		
.no_think
	move.l	#1,(a1)+
	bra	.loop2
.end_line
	move.l	a0,p_text
	clr.l	(a1)
	rts
.no_text	
	move.l	o_text(pc),p_text
	move.l	#-1,(a1)
	rts



aff_bout2
;	adresse
	lea	pbuffer,a0
.rest
	move.l	(a0)+,d0
	ble.s	.no_t	
	cmp.l	#1,d0
	bne.s	.No_sp
	add.l	#16,a1
	bra.s	.rest
.No_sp
	move.l	d0,a2
	moveq	#15,d0
.aff
	move.l	(a2),16-6(a1)
	lea	20*4(a2),a2
	lea	384(a1),a1
	dbf	d0,.aff
	lea	16-384*16(a1),a1
	bra.s	.rest
.no_t	
	rts

init_pal2
	lea	pal+32*4(pc),a0
	move.w	#128-1,d0
.loop_cls
	clr.l	(a0)+
	dbf	d0,.loop_cls
	rts

reloc
	MOVE.L	2(A0),D0
	ADD.L	6(A0),D0
	ADD.L	14(A0),D0
	LEA	$1C(A0),A0
	MOVE.L	A0,A1
	MOVE.L	A0,A2
	MOVE.L	A0,D1
	ADD.L	D0,A1
	MOVE.L	(A1)+,D0
	ADD.L	D0,A2
	ADD.L	D1,(A2)
	MOVEQ.L	#0,D0
.BOUCLE
	MOVE.B	(A1),D0
	CLR.B	(A1)+
	TST.B	D0
	BEQ.S	.FIN_RELOC
	CMP.B	#1,D0
	BEQ.S	.SPECIAL_BRANCH
	ADD.L	D0,A2
	ADD.L	D1,(A2)
	BRA.S	.BOUCLE
.SPECIAL_BRANCH
	LEA	$FE(A2),A2
	BRA.S	.BOUCLE
.FIN_RELOC
	rts


	section	data
palette_fonte	ds.l	4
table_ste	dc.b	0,8<<4,1<<4,9<<4,2<<4,10<<4,3<<4,11<<4,4<<4,12<<4,5<<4,13<<4,6<<4,14<<4,7<<4,15<<4
	even
o_text	dc.l	0
p_text	dc.l	0
text	
	dc.b	'CODER  ',0
	dc.b	' NEW FACE ',0
	dc.b	'  ELENDIL',0
	dc.b	-1
	even
text2	
	dc.b	' GFX  ',0
	dc.b	'  FLAN    ',0
	dc.b	-1
	even
text3	
	dc.b	' MSX  ',0
	dc.b	'  ZIGO    ',0
	dc.b	-1
	even

list_char
	dc.b	'ABCDEFGHIJKLMNOPQRST'
	dc.b	'UVWXYZ!?,.1234567890',-1
	even
pal
	incbin	bab.pal
	ds.b	1024-200
fonte	incbin	exafnt.pl2
img	incbin	bab.dat
	even
trans
	incbin	plaque.prg
	section	bss
fade_ok	ds.w	1
pbuffer	ds.l	40
ecran	ds.L	2
becran	ds.b	(384*240*2)+20	;2 ecrans	
