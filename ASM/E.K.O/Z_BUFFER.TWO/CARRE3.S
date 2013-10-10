 	opt	d+
	include	d:\devpac\sources\macro\dsp.mcr

	jmp	main			
save_ints:
	move.b	$fffffa07.w,mfpa07	
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	move.b	$ff8201,save81
	move.b	$ff8203,save82

	move.w	#-1,-(sp)	
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp
	move.w	d0,oldmode
	rts
init_ints:	
	move.w	#3,-(sp)	
	move.w	#%011100010,-(sp)
	move.l	physique,-(sp)	
	move.l	physique,-(sp)	
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	move.w	#%001100010,-(sp)
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp

	move.l	#div_0,$14.w
	clr.b	$fffffa09.w		
	clr.b	$fffffa15.w
	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa19.w
	move.b	#1,$fffffa07.w
	move.b	#34,$fffffa21.w
	move.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.b	#0,$fffffa1b.w
	move.l	#vbi,$70.w
	rts
ret_ints:	
	move.b	mfpa07,$fffffa07.w	
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	move.b	save81,$ff8201
	move.b	save82,$ff8203
	rts
save81:	dc.b	0
save82:	dc.b	0
mfpa07:	dc.b	0			
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0
oldmode	dc.w	0

main:	pea	0			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.l	usp,a0			
	move.l	a0,save_usp

	jsr	save_ints		
	Dsp_lock
	Dsp_flushsubroutines
	Dsp_loadprog dsp,3,buffer
	jsr	init_ints		
	move.w	#$2011,d0
	movec	d0,cacr
	bsr	send_1_sur_x
	bsr	preparation_z1

demo_loop_z1:
*	move.l	#-1,$ffff9800
	bsr	execute_z1
*	move.l	#0,$ffff9800

	bsr	swap
	cmp.b	#185,$fffc02		
	beq	fin
	bsr	wait
	bra	demo_loop_z1


fin	jsr	ret_ints		
	Dsp_unlock
	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)		
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	oldmode,-(sp)	
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp
	clr.w	(sp)			
	trap	#1

wait:	move.w	wfnc,d0
.looop	cmp.w	wfnc,d0
	beq	.looop
	rts

vbi:	add.w	#1,wfnc
	rte

swap:	move.l	logique,d0
	move.l	physique,d1
	move.l	d0,physique
	move.l	d1,logique
	move.l	d1,work
	move.w	d0,d1
	swap	d0
	move.b	d0,$ffff8201.w
	swap	d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	move.b	d1,$ffff820d.w	
	rts

ech_adr
	movem.l	adr_eff,d0-d3
	exg.l	d0,d2
	exg.l	d1,d3
	movem.l	d0-d3,adr_eff
	rts

send
	btst	#1,$ffffa202.w
	beq.s	send
	move.l	d0,$ffffa204.w
	rts

rec
	btst	#0,$ffffa202.w
	beq.s	rec
	move.w	$ffffa206.w,d0
	rts

;++++++++++++++++++++++++++++++++
;				+
; Routine de remplissage au 030	+
;				+
;++++++++++++++++++++++++++++++++

prod_vect:	
	lea	ready,a0
	movem.w	(a0),d0-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	rts

remplir	
	sub.w	d6,d7
	move.w	d7,d2
	
	move.l	work,a1
	lea	mul160,a5
	add.l	(a5,d6.w*4),a1
	lea	gauche,a0
	lea	droite,a3
	add.w	d6,d6
	add.w	d6,a0
	add.w	d6,a3
	lea	mega_tab,a4
	lea	mega_tab1,a2
	move.w	color,d0
	lea	tab_color,a5
	move.l	(a5,d0.w*4),a5 
	jmp	(a5)


	include	d:\z_buffer.two\3d_16co1.s
	include	d:\z_buffer.two\prepa__2.s
	include	d:\z_buffer.two\dsp_com1.s
	include	d:\z_buffer.two\ss_zbuff.s
	include	d:\z_buffer.two\pr_zbuff.s
increm	
	movem.w	(a0),d0-d5	
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	and.w	#$1ff,d0
	and.w	#$1ff,d1
	and.w	#$1ff,d2
	movem.w	d0-d2,(a0)
	rts

efface_objet
	move.l	work,a1
	lea	mul160,a2
	movem.w	(a0),d0-d3
	tst.w	d1
	bpl.s	.a
	moveq	#0,d1
.a	cmp.w	#239,d1
	blt.s	.x
	move.w	#239,d1
.x	tst.w	d3
	bpl.s	.c
	moveq	#0,d3
.c	cmp.w	#239,d3
	blt.s	.d
	move.w	#239,d3
.d	tst.w	d0
	bpl.s	.e
	moveq	#0,d0
.e	cmp.w	#383,d0
	blt.s	.f
	move.w	#383,d0
.f	tst.w	d2
	bpl.s	.g
	moveq	#0,d2
.g	cmp.w	#383,d2
	blt.s	.h
	move.w	#383,d2
.h	add.l	(a2,d1.w*4),a1
	sub.w	d1,d3
	bmi.s	.rt‚s
	and.w	#$fff0,d0
	and.w	#$fff0,d2
	move.w	d0,d4
	lsr.w	#1,d4
	add.w	d4,a1
	sub.w	d0,d2
	bmi.s	.rt‚s
	move.w	#192-8,d5
	lsr.w	#1,d2
	sub.w	d2,d5
	lsr.w	#3,d2
	moveq	#0,d6
	neg.w	d2	
.re	jmp     .clear(pc,d2.w*4)
.re1	
	rept	18
	move.l	d6,(a1)+		
	move.l	d6,(a1)+		
	endr
.clear	move.l	d6,(a1)+		
	move.l	d6,(a1)+		
	add.w	d5,a1
	dbf	d3,.re
.rt‚s	rts

clear_384_240
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6

	moveq	#0,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5

	add.l	#192*240,a6
	move.w	#109,d0
.re
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	dbf	d0,.re
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-a5,-(a6)
	movem.l	d1-d2,-(a6)
	rts


put_palette
	bsr	wait
	move.l	#$ffff9800,a1
	moveq	#$f,d1	
.re	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	move.l	d0,(a1)+
	dbf	d1,.re
	rts

div_0	rte

dsp	dc.b	'd:\ataridsp\triton2.lod',0
	even

tab_color	
	dc.l	fill_color0
	dc.l	fill_color1
	dc.l	fill_color2
	dc.l	fill_color3
	dc.l	fill_color4
	dc.l	fill_color5
	dc.l	fill_color6
	dc.l	fill_color7
	dc.l	fill_color8
	dc.l	fill_color9
	dc.l	fill_color10
	dc.l	fill_color11
	dc.l	fill_color12
	dc.l	fill_color13
	dc.l	fill_color14
	dc.l	fill_color15
	dc.l	fill_color16
	dc.l	fill_color17
	dc.l	fill_color18
	dc.l	fill_color19
	dc.l	fill_color20
	dc.l	fill_color21
	dc.l	fill_color22
	dc.l	fill_color23
	dc.l	fill_color24
	dc.l	fill_color25

sinus		incbin	d:\z_buffer.two\new_sin.tab
		EVEN
cosinus		EQU	sinus+256

COMPT	SET	0
mul160	REPT	250
	DC.l	COMPT
COMPT	SET	COMPT+192
	ENDR

	rept	32*30
	dc.w	$ffff
	dc.w	0
	endr
mega_tab
ouaip	set	0
	rept	24                  
	dc.w	%1111111111111111
	dc.w	ouaip
	dc.w	%111111111111111
	dc.w	ouaip
	dc.w	%11111111111111
	dc.w	ouaip
	dc.w	%1111111111111
	dc.w	ouaip
	dc.w	%111111111111
	dc.w	ouaip
	dc.w	%11111111111
	dc.w	ouaip
	dc.w	%1111111111
	dc.w	ouaip
	dc.w	%111111111
	dc.w	ouaip
	dc.w	%11111111
	dc.w	ouaip
	dc.w	%1111111
	dc.w	ouaip
	dc.w	%111111
	dc.w	ouaip
	dc.w	%11111
	dc.w	ouaip
	dc.w	%1111
	dc.w	ouaip
	dc.w	%111
	dc.w	ouaip
	dc.w	%11
	dc.w	ouaip
	dc.w	%1
	dc.w	ouaip
ouaip	set	ouaip+4
	endr
	rept	32*30
	dc.w	0
	dc.w	4*23
	endr
	rept	32*30
	dc.w	0
	dc.w	0
	endr
mega_tab1
plomp	set	0
	rept	24
	dc.w	%1000000000000000
	dc.w	plomp
	dc.w	%1100000000000000
	dc.w	plomp
	dc.w	%1110000000000000
	dc.w	plomp
	dc.w	%1111000000000000
	dc.w	plomp
	dc.w	%1111100000000000
	dc.w	plomp
	dc.w	%1111110000000000
	dc.w	plomp
	dc.w	%1111111000000000
	dc.w	plomp
	dc.w	%1111111100000000
	dc.w	plomp
	dc.w	%1111111110000000
	dc.w	plomp
	dc.w	%1111111111000000
	dc.w	plomp
	dc.w	%1111111111100000
	dc.w	plomp
	dc.w	%1111111111110000
	dc.w	plomp
	dc.w	%1111111111111000
	dc.w	plomp
	dc.w	%1111111111111100
	dc.w	plomp
	dc.w	%1111111111111110
	dc.w	plomp
	dc.w	%1111111111111111
	dc.w	plomp
plomp	set	plomp-4
	endr
	rept	32*30
	dc.w	$ffff
	dc.w	-23*4
	endr

nb	dc.w	0
work		dc.l	$3b0000
logique		dc.l	$3b0000
physique	dc.l	$3d0000
save_usp:	dc.l	0
wfnc:		dc.w	0
save_stk:	dc.l	0
adr_eff	dc.l	eff0,eff1,eff2,eff3
color		ds.w	1
	section bss
liste_aff	ds.w	100
receive_pv 	ds.w	1000
tab_receive_pv	ds.l	25	
new_p		ds.l	1000
droite		ds.w	250
gauche		ds.w	250
eff0		ds.w	4
eff1		ds.w	4
eff2		ds.w	4
eff3		ds.w	4
eff_bug		ds.w	8
serie_color	ds.w	100
serie_color0	ds.w	100
visible_obj0	ds.l	50
visible_obj1	ds.l	50
visible_obj2	ds.l	50
stock_obj	ds.l	500
tab_offset	ds.l	256
rec_point	ds.b	5000*2
ready	ds.l	20
buffer		ds.b	27000
	end

