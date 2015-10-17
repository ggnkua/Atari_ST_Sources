	
	include a:\util.lib

nb_blk	equ	11
lg_plan	equ	66
ht_plan	equ	17

prg_file	equ	1	0=demo screen/1=prg file

	opt o+,w-,d+
	
	ifne prg_file
	supexec debut
	pterm
	elseif
	org $10000
	endc

debut	jsr clr_bss
	jsr init_plan
	jsr init_int
	jsr deca_blk
	jsr clr_scr
	jsr init_scr
main_loop	jsr set_screen
	jsr aff_all
	jsr music+4
	cmp.l #"O.K.",$200.w
	bne.s main_loop
	cmp.b #$39,$fffffc02.w
	bne.s main_loop
	jsr stop_int
	rts

clr_scr	movem.l screen1,a0-a3
	move.w #9159,d0
clr_scrs1	clr.l (a0)+
	clr.l (a1)+
	clr.l (a2)+
	clr.l (a3)+
	dbra d0,clr_scrs1
	rts

clr_bss	lea crd_x,a0
clr_bss2	clr.l (a0)+
	cmp.l #ecran,a0
	blt.s clr_bss2
	rts

init_int
	ifne prg_file
	getphys scr_back
	getrez rez_back
	savepal pal_back
	mouseoff
	loadpal null
	endc
	move.l #ecran,d0
	and.w #$ff00,d0
	lea screen,a0
	add.l d0,(a0)+
	add.l d0,(a0)+
	add.l d0,(a0)+
	add.l d0,(a0)+
	add.l d0,(a0)+
	moveq #1,d0
	jsr music
	move.w #$2700,sr
	ifne prg_file
	move.b $fffffa07.w,old_mfp
	move.b $fffffa09.w,old_mfp+1
	move.b $fffffa13.w,old_mfp+2
	move.b $fffffa15.w,old_mfp+3
	move.l $70.w,old_vbl
	move.l $68.w,old_v68
	endc
	move.b #0,$ffff8260.w
	clr.b $fffffa07.w
	clr.b $fffffa09.w
	clr.b $fffffa13.w
	move.l #hbl1,$120.w
	move.l #v68,$68.w
	ori.b #1,$fffffa07.w
	ori.b #1,$fffffa13.w
	bclr #5,$fffffa15.w
	bset #5,$fffffa09.w
	move.w #$2100,sr
	move.l #vbl,$70.w
	clr.w crd_x
	clr.w crd_y
	st.b flag_droite
	st.b flag_bas
set_screen	clr.b flag68_5
set_scrs1	tst.b flag68_5
	beq.s set_scrs1
	jsr set_scrs2
	move.w crd_y,d1
	and.w #$000f,d1
	mulu #160,d1
	add.l d1,d0
	sub.l #23*160,d0
	move.l d0,d1
	and.w #$ff00,d0
	and.w #$00ff,d1
	lsr.w #3,d1
	move.w d1,decalage
	add.w d1,d1
	lea table,a0
	add.w d1,a0
	add.w d1,a0
	add.w d1,a0
	move.w 4(a0),d1
	lsl.l #8,d1
	sub.l d1,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	rts

set_scrs2	move.w num_scr,d0
	add.w d0,d0
	add.w d0,d0
	lea screen1,a0
	move.l (a0,d0.w),d0
	move.w crd_y,d1
	and.w #$fff0,d1
	mulu #160,d1
	add.l d1,d0
	move.w crd_x,d1
	and.w #$fff0,d1
	lsr.w #1,d1
	add.w d1,d0
	move.l d0,screen
	rts

	ifne prg_file
stop_int	move.l #vbl2,$70.w
	moveq #0,d0
	jsr music
	clr.b pt_vbl
stp_int	tst.b pt_vbl
	beq.s stp_int
	move.l old_vbl,$70.w
	move.w #$2700,sr
	move.l old_v68,$68.w
	move.b old_mfp,$fffffa07.w
	move.b old_mfp+1,$fffffa09.w
	move.b old_mfp+2,$fffffa13.w
	move.b old_mfp+3,$fffffa15.w
	setscreen rez_back,scr_back,scr_back
	loadpal pal_back
	mouseon
	rts
	endc

vbl2	st.b pt_vbl
	rte

pt_vbl	dc.w 0

init_scr	movem.l screen1,a0-a3
	lea plan,a4
	lea tmp_blk,a5
	moveq #12,d0		12 blks de haut
init_scrs1	move.l a4,-(sp)
	jsr init_scrs2
	lea 15*160(a0),a0
	lea 15*160(a1),a1
	lea 15*160(a2),a2
	lea 15*160(a3),a3
	move.l (sp)+,a4
	lea lg_plan*2(a4),a4
	dbra d0,init_scrs1
	rts

init_scrs2	moveq #19,d2
	moveq #0,d1
init_scrs3	lea 128(a5),a6
	move.w (a4)+,d1
	add.l d1,a6

offset2	set 0
	rept 16
	move.l (a6)+,offset2+0(a0)
	move.l (a6)+,offset2+4(a0)
offset2	set offset2+160
	endr
	lea nb_blk*256-128(a6),a6

offset2	set 0
	rept 16
	move.l (a6)+,offset2+0(a1)
	move.l (a6)+,offset2+4(a1)
offset2	set offset2+160
	endr

	lea nb_blk*256-128(a6),a6
offset2	set 0
	rept 16
	move.l (a6)+,offset2+0(a2)
	move.l (a6)+,offset2+4(a2)
offset2	set offset2+160
	endr

	lea nb_blk*256-128(a6),a6
offset2	set 0
	rept 16
	move.l (a6)+,offset2+0(a3)
	move.l (a6)+,offset2+4(a3)
offset2	set offset2+160
	endr

	lea (a5),a6
	move.w (a4),d1
	add.l d1,a6

	lea nb_blk*256(a6),a6
offset2	set 0
	rept 16
	movem.l (a6)+,d3-d4
	or.l d3,offset2+0(a1)
	or.l d4,offset2+4(a1)
offset2	set offset2+160
	endr

	lea nb_blk*256-128(a6),a6
offset2	set 0
	rept 16
	movem.l (a6)+,d3-d4
	or.l d3,offset2+0(a2)
	or.l d4,offset2+4(a2)
offset2	set offset2+160
	endr

	lea nb_blk*256-128(a6),a6
offset2	set 0
	rept 16
	movem.l (a6)+,d3-d4
	or.l d3,offset2+0(a3)
	or.l d4,offset2+4(a3)
offset2	set offset2+160
	endr

	addq.l #8,a0
	addq.l #8,a1
	addq.l #8,a2
	addq.l #8,a3
	dbra d2,init_scrs3
	rts

aff_all	tst.b flag_droite
	beq.s aff_alls1
	cmp.w #(lg_plan-20)*16,crd_x
	bge.s aff_droites1
	addq.w #4,crd_x
	move.w num_scr,d1
	addq.w #1,d1
	and.w #3,d1
	move.w d1,num_scr
	jsr set_scrs2
	moveq #1,d0
	jsr aff_vertical
	bra aff_alls2
aff_droites1	clr.b flag_droite
	st.b flag_gauche
	bra aff_alls2
aff_alls1	tst.b flag_gauche
	beq.s aff_alls2
	cmp.w #0,crd_x
	ble.s aff_gauches1
	subq.w #4,crd_x
	move.w num_scr,d1
	subq.w #1,d1
	and.w #3,d1
	move.w d1,num_scr
	jsr set_scrs2
	moveq #0,d0
	jsr aff_vertical
	bra.s aff_alls2
aff_gauches1	clr.b flag_gauche
	st.b flag_droite
aff_alls2	tst.b flag_haut
	beq aff_alls3
	cmp.w #0,crd_y
	ble aff_hauts1
	subq.w #1,crd_y
	move.w crd_y,d0
	lsr.w #4,d0
	cmp.w old_y,d0
	beq.s aff_alls3
	move.w d0,old_y
	move.w d0,flg_scrn1
	move.w d0,flg_scrn2
	move.w d0,flg_scrn3
	move.w d0,flg_scrn4
	bra aff_alls4
aff_hauts1	clr.b flag_haut
	st.b flag_bas
	bra aff_alls4
aff_alls3	tst.b flag_bas
	beq aff_alls4
	cmp.w #(ht_plan-13)*16,crd_y
	bge aff_bass1
	addq.w #1,crd_y
	move.w crd_y,d0
	lsr.w #4,d0
	cmp.w old_y,d0
	beq.s aff_alls4
	move.w d0,old_y
	add.w #12,d0
	move.w d0,flg_scrn1
	move.w d0,flg_scrn2
	move.w d0,flg_scrn3
	move.w d0,flg_scrn4
	bra.s aff_alls4
aff_bass1	clr.b flag_bas
	st.b flag_haut
aff_alls4	move.w num_scr,d0
	add.w d0,d0
	lea flg_scrn1,a1
	tst.w (a1,d0.w)
	bpl.s aff_alls5
	moveq #0,d0
	tst.w (a1,d0.w)	ecran 1
	bpl.s aff_alls5
	addq.w #2,d0
	tst.w (a1,d0.w)	ecran 2
	bpl.s aff_alls5
	addq.w #2,d0
	tst.w (a1,d0.w)	ecran 3
	bpl.s aff_alls5
	addq.w #2,d0
	tst.w (a1,d0.w)	ecran 4
	bmi.s aff_alls6
aff_alls5	move.w (a1,d0.w),d2	
	move.w #-1,(a1,d0.w)
	add.w d0,d0
	lea plan,a0
	move.w d2,d3
	mulu #lg_plan*2,d2
	add.l d2,a0
	lea screen1,a1
	move.l (a1,d0.w),a2
	mulu #16*160,d3
	add.l d3,a2
	lea ad_block,a1
	move.l (a1,d0.w),a1
	move.w crd_x,d1
	and.l #$fff0,d1
	lsr.w #1,d1		d1 / 2
	add.l d1,a2
	lsr.w #2,d1		d1 / 4 = d1 / 8
	add.l d1,a0
	jsr aff_horiz
aff_alls6	rts

old_y	dc.w 0
flg_scrn1	dc.w -1
flg_scrn2	dc.w -1
flg_scrn3	dc.w -1
flg_scrn4	dc.w -1

aff_horiz	moveq #19,d0
aff_horizs1	moveq #0,d1
	moveq #0,d2
	move.w (a0)+,d1
	move.w (a0),d2
	lea (a1,d1.w),a3
	lea (a1,d2.w),a4
	add.l #128,a3
	move.l d0,-(sp)

offset	set 0
	rept 4
	movem.l (a3)+,d0-d7
	or.l (a4)+,d0
	or.l (a4)+,d1
	or.l (a4)+,d2
	or.l (a4)+,d3
	or.l (a4)+,d4
	or.l (a4)+,d5
	or.l (a4)+,d6
	or.l (a4)+,d7
	move.l d0,offset+0*160+0(a2)
	move.l d1,offset+0*160+4(a2)
	move.l d2,offset+1*160+0(a2)
	move.l d3,offset+1*160+4(a2)
	move.l d4,offset+2*160+0(a2)
	move.l d5,offset+2*160+4(a2)
	move.l d6,offset+3*160+0(a2)
	move.l d7,offset+3*160+4(a2)
offset	set offset+4*160
	endr
	lea 8(a2),a2
	move.l (sp)+,d0
	dbra d0,aff_horizs1
	rts

aff_vertical	lea plan,a0
	move.w crd_x,d1
	and.w #$fff0,d1
	lsr.w #3,d1
	add.w d1,a0
	move.w crd_y,d1
	and.w #$fff0,d1
	lsr.w #3,d1
	mulu #lg_plan,d1
	add.l d1,a0
	move.w num_scr,d1
	add.w d1,d1
	add.w d1,d1
	lea ad_block,a1
	move.l (a1,d1.w),a1
	move.l screen,a2
	tst.w d0
	beq.s aff_verts1
	lea 152(a2),a2
	lea 19*2(a0),a0
aff_verts1	moveq #12,d0
aff_verts2	moveq #0,d1
	moveq #0,d2
	move.w (a0),d1
	move.w 2(a0),d2
	lea (a1,d1.w),a3
	lea (a1,d2.w),a4
	add.l #128,a3
	move.l d0,-(sp)

	rept 4
	movem.l (a3)+,d0-d7
	or.l (a4)+,d0
	or.l (a4)+,d1
	or.l (a4)+,d2
	or.l (a4)+,d3
	or.l (a4)+,d4
	or.l (a4)+,d5
	or.l (a4)+,d6
	or.l (a4)+,d7
	move.l d0,0*160+0(a2)
	move.l d1,0*160+4(a2)
	move.l d2,1*160+0(a2)
	move.l d3,1*160+4(a2)
	move.l d4,2*160+0(a2)
	move.l d5,2*160+4(a2)
	move.l d6,3*160+0(a2)
	move.l d7,3*160+4(a2)
	lea 4*160(a2),a2
	endr
	move.l (sp)+,d0
	lea lg_plan*2(a0),a0
	dbra d0,aff_verts2
	rts
	
flag68_5	dc.b 0
	dc.b 0
flag68_3	dc.w 0

vbl	addq.b #1,pt_vbl
offset	set $ffff8240
	rept 8
	clr.l (offset).w
offset	set offset+4
	endr
	move.w #32,flag68_3
	move.l #v68,$68.w
	and.w #$f1ff,(a7)	set sr to low priority
	rte

v68	subq.w #1,flag68_3
	bmi.s v68s1
	rte
v68s1	move.l #v68s3,$68.w
	bclr #6,$fffffa15.w
v68s2	stop #$2100		wait hbl's inter.
	bra.s v68s2		only hbl's inter !!!

table	incbin a:\the_end\hd_scr.tab

decalage	dc.w 0
v68s3	move.w #$2700,sr
	addq.l #6,sp
	movem.l d0-a6,-(sp)
	lea table(pc),a4
	move.w decalage(pc),d0
	add.w d0,d0
	add.w d0,a4
	add.w d0,a4
	add.w d0,a4
	moveq #0,d0
	lea $ffff8209.w,a0
	move.w #$60,d2
	nnop 7
v68s4	nnop 30
	move.w #10,d1
	move.w #0,$ffff8240.w
	move.b #0,$ffff820a.w
	moveq #2,d3
v68s5	nop
	dbra d3,v68s5
	move.b #2,$ffff820a.w
	nnop 8
v68s6	move.b (a0),d0
	cmp.b #$40,d0
	bgt.s v68s7
	dbra d1,v68s6
v68s7	sub.w d0,d2
	lsl.w d2,d0
	nnop 5
	moveq #0,d2
	lea $ffff8240.w,a3

	rept 8
	move.l d2,(a3)+
	endr

	move.w (a4),d1	ligne de 230 octets (8 cycles)
	move.w 2(a4),d2	ligne de 204 octets (12 cycles)
	lea $ffff820a.w,a1
	lea $ffff8260.w,a0
	moveq #0,d3
	moveq #2,d4
	move.w #19,d0
v68s8	cmp.w #0,d1
	beq v68s10
	subq.w #1,d1

	nnop 3

	move.b d4,(a0)
	nop
	move.b d3,(a0)

	nnop 89

	move.b d3,(a1)
	move.b d4,(a1)

	nnop 13

	move.b d4,(a0)
	nop
	move.b d3,(a0)

	dbra d0,v68s8
	
v68s9	nnop 5
	
v68s10	cmp.w #0,d2
	beq v68s11
	
	move.b d3,(a0)	
	move.b d3,(a0)
	subq.w #1,d2
	
	nnop 88
	
	move.b d3,(a1)
	move.b d4,(a1)

	nnop 13

	move.b d3,(a0)
	nop
	move.b d3,(a0)
		
	dbra d0,v68s9
v68s11	move.w (a4)+,d0
	add.w (a4),d0
	moveq #$15,d1
	sub.w d0,d1
	move.l #hbl1,$120.w
	move.b d1,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #v68s12,$68.w
	bset #6,$fffffa15.w
	st.b flag68_5
	movem.l (sp)+,d0-a6
	or.w #$300,(a7)
v68s12	rte

hbl1	move.l a0,-(sp)
	clr.b $fffffa1b.w
	lea block+2,a0
	nnop 98
offset	set $ffff8240
	rept 8
	move.l (a0)+,(offset).w
offset	set offset+4
	endr
	move.l (sp)+,a0
	move.l #hbl2,$120.w
	move.b #191,$fffffa21.w
	move.b #8,$fffffa1b.w
	bclr #0,$fffffa0f.w
	rte

hbl2	clr.b $fffffa1b.w
	nnop 100
offset	set $ffff8240
	rept 8
	clr.l (offset).w
offset	set offset+4
	endr
	bclr #0,$fffffa0f.w
	rte

deca_blk	lea	block+34,a4
	add.l	#nb_blk*128,a4	block fond
	lea	tmp_blk,a1
	move.w	#3,d0	nb de decalages
	moveq	#0,d3
	moveq	#0,d4
decas1	move.w	#nb_blk-1,d1
	lea	block+34,a2
decas2	move.l	a2,a0
	move.l	a4,a3
	moveq	#15,d2
decas3	movem.l	null,d5-d7

	move.w	(a0),d7
	or.w	2(a0),d7
	or.w	4(a0),d7
	or.w	6(a0),d7
	not.w	d7
	
	move.w	(a0),d5
	move.w	(a3),d6
	ror.w	d4,d6
	and.w	d7,d6
	or.w	d6,d5
	lsl.l	d3,d5
	move.w	d5,128(a1)
	swap	d5
	move.w	d5,0(a1)

	moveq	#0,d5
	move.w	2(a0),d5
	move.w	2(a3),d6
	ror.w	d4,d6
	and.w	d7,d6
	or.w	d6,d5
	lsl.l	d3,d5
	move.w	d5,130(a1)
	swap	d5
	move.w	d5,2(a1)

	moveq	#0,d5
	move.w	4(a0),d5
	move.w	4(a3),d6
	ror.w	d4,d6
	and.w	d7,d6
	or.w	d6,d5
	lsl.l	d3,d5
	move.w	d5,132(a1)
	swap	d5
	move.w	d5,4(a1)

	moveq	#0,d5
	move.w	6(a0),d5
	move.w	6(a3),d6
	ror.w	d4,d6
	and.w	d7,d6
	or.w	d6,d5
	lsl.l	d3,d5
	move.w	d5,134(a1)
	swap	d5
	move.w	d5,6(a1)

	lea	8(a0),a0
	lea	8(a3),a3
	lea	8(a1),a1
	dbra	d2,decas3
	lea	128(a1),a1
	lea	128(a2),a2
	dbra	d1,decas2
	addq.w	#4,d3
	addq.w	#2,d4
	dbra	d0,decas1
	rts

init_plan	lea carte+2,a0
	move.w (a0)+,d1
	mulu (a0)+,d1
	addq.w #2,a0
	subq.w #1,d1
init_plans1	moveq #0,d0
	move.w (a0),d0
	and.w #$00ff,d0
	lsl.w #8,d0		mul 256
	move.w d0,(a0)+
	dbra d1,init_plans1
	rts

	section data

screen	dc.l 3*$9e00
screen1	dc.l 3*$9e00
screen2	dc.l 2*$9e00
screen3	dc.l 1*$9e00
screen4	dc.l 0*$9e00

ad_block	dc.l tmp_blk+0*(nb_blk*256)
	dc.l tmp_blk+1*(nb_blk*256)
	dc.l tmp_blk+2*(nb_blk*256)
	dc.l tmp_blk+3*(nb_blk*256)

carte	incbin a:\the_end\the_end.kar

plan	equ carte+8

block	incbin a:\the_end\the_end.pse

music	incbin a:\the_end\epic_016.mus
	even
	
	section bss

crd_x	ds.w 1
crd_y	ds.w 1
flag_droite	ds.b 1
flag_gauche	ds.b 1
flag_haut	ds.b 1
flag_bas	ds.b 1
num_scr	ds.w 1
	ifne prg_file
old_mfp	ds.b 4
old_v68	ds.l 1
old_vbl	ds.l 1	
scr_back	ds.l 1
rez_back	ds.w 1
pal_back	ds.w 16
	endc
tmp_blk	ds.b 4*(nb_blk*256)
null	ds.b 32
	ds.b 256+(23*160)
ecran	equ *
