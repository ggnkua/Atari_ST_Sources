	**********************************
	* EPIC MUSIC SYSTEM PLAYER V1.2B *
	*        CODING : EPSILON        *
	*        GFX    :   VIXIT        *
	*        MUSIXX :    EPIC        *
	*  (C)1992 THE MISFITS SOFTWARE  *
	**********************************
	
	include 	a:\util.lib
	
debug	set 0	debug mode 0=off/1=on
prg_file	equ 1	demo screen=0/prg_file=1

	ifeq debug
 	opt o+,w-,d-
	endc
	
	ifne prg_file
	supexec main
	pterm
	elseif
	org $40000
	opt o+,w-,d-
debug	set 0
	endc
	
main	jsr clr_bss
	jsr save_all
	jsr init_var
	jsr clr_screen
	jsr init_scr
	jsr init
loop	jsr wait_vbl
	jsr swap_screen
	ifne debug
	move.w #$700,$ffff8240.w
	endc
	jsr eff_scroll
	jsr scroll
	jsr aff_scroll
	jsr aff_reflet
	move.l ad_play,a0
	jsr 4(a0)
	jsr tst_key
	ifne debug
	move.w #$000,$ffff8240.w
	endc
	tst.b flag_exit
	beq.s loop
	jsr restore
	rts
	
clr_bss	lea old_vbl,a0
	lea ecran,a1
clr_bss_s1	clr.l (a0)+
	cmp.l a1,a0
	blt.s clr_bss_s1
	rts

init_var	move.l #ecran,d0
	clr.b d0
	move.l d0,screen1
	add.l #$a900,d0
	move.l d0,screen2
	move.l #mess_32,pt_mess
	move.w #16,pt_lettre
	move.l #tmp1,ad_tmp1
	move.l #tmp2,ad_tmp2
	move.l #courbe,pt_sin
	move.l #zik15,ad_play
	move.w #14,num_zik
	rts
	
save_all	move.w #$2700,sr
	getphys2 oldphys
	getrez2 oldrez
	savepal oldpal
	mouseoff
	move.l $70.w,old_vbl
	move.l $120.w,old_hbl
	loadpal null
	rts
	
restore	move.l #vbl2,$70.w
	jsr wait_vbl
	move.w #$2700,sr
	soundoff
	loadpal null
	move.l old_vbl,$70.w
	move.l old_hbl,$120.w
	move.b mfpa07,$fffffa07.w
	move.b mfpa09,$fffffa09.w
	move.b mfpa13,$fffffa13.w
	move.b mfpa15,$fffffa15.w
	move.b mfpa17,$fffffa17.w
	move.b mfpa1f,$fffffa1f.w
	setscreen2 oldrez,oldphys
	lea pic2+34,a5
	lea $78000,a3
	jsr decomp_pic
	loadpal oldpal
	rts
	
init	move.w #$2700,sr
	move.b $fffffa07.w,mfpa07
	move.b $fffffa09.w,mfpa09
	move.b $fffffa13.w,mfpa13
	move.b $fffffa15.w,mfpa15
	move.b $fffffa17.w,mfpa17
	move.b $fffffa1f.w,mfpa1f
	clr.b $fffffa07.w
	clr.b $fffffa09.w
	move.b #1,$fffffa07.w
	move.b #1,$fffffa13.w
	bclr #3,$fffffa17.w
	move.l #vbl2,$70.w
	move.l #hbl,$120.w
	moveq #1,d0
	jsr zik15
	move.w #$2300,sr
	jsr wait_vbl
	setscreen2 #0,screen1
	loadpal pic+2
	move.l #vbl,$70.w
	rts
	
swap_screen	movem.l screen1,d0-d3
	exg.l d0,d1
	exg.l d2,d3
	movem.l d0-d3,screen1
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	rts

clr_screen	movem.l screen1,a0-a1
	move.l a1,a2
	add.l #$a900,a2
clr_scrs1	clr.l (a0)+
	clr.l (a1)+
	cmp.l a1,a2
	bne.s clr_scrs1
	rts
	
init_scr	lea pic+34,a5
	move.l screen1,a3
	jsr decomp_pic
	lea pic+34,a5
	move.l screen2,a3
	jsr decomp_pic
	rts
	
wait_vbl	sf.b pt_vbl
wait_vbls1	tst.b pt_vbl
	beq.s wait_vbls1
	rts
	
tst_key	moveq #0,d0
	move.b $fffffc02.w,d0
	cmp.b #$3b,d0
	blt.s tst_keys1
	cmp.b #$44,d0
	bhi.s tst_keys1
	sub.w #$3b,d0
	bra.s tst_keys2
tst_keys1	cmp.b #$02,d0
	blt.s tst_keys3
	cmp.b #$07,d0
	bhi.s tst_keys3
	add.w #8,d0
tst_keys2	cmp.w num_zik,d0
	beq.s tst_keys3
	move.w d0,num_zik
	add.w d0,d0
	add.w d0,d0
	lea ad_zik,a0
	move.l (a0,d0.w),a0
	move.l a0,ad_play
	moveq #1,d0
	jsr (a0)
	bra.s tst_keys5
tst_keys3	cmp.b #$39,d0
	bne.s tst_keys5
	st.b flag_exit
tst_keys5	rts
	
vbl2	st.b pt_vbl
	rte
	
vbl	st.b pt_vbl
	clr.b $fffffa1b.w
	movem.l d0-d7,-(sp)
	loadpal pic+2
	movem.l (sp)+,d0-d7
	move.l #hbl,$120.w
	move.b #140,$fffffa21.w
	move.b #8,$fffffa1b.w
	rte

hbl	movem.l d0-d7,-(sp)
	lea $fffffa21.w,a0
	move.b (a0),d0
mfp0s1	cmp.b (a0),d0
	beq.s mfp0s1
	loadpal fontes_pal
	movem.l (sp)+,d0-d7
	clr.b $fffffa1b.w
	move.l #hbl1,$120.w
	move.b #49,$fffffa21.w
	move.b #8,$fffffa1b.w
	rte

hbl1	movem.l d0/a0,-(sp)
	lea $fffffa21.w,a0
	move.b (a0),d0
mfp1s1	cmp.b (a0),d0
	beq.s mfp1s1
	nnop 6
	move.w #$247,$ffff8240.w
	movem.l (sp)+,d0/a0
	clr.b $fffffa1b.w
	move.l #hbl2,$120.w
	move.b #8,$fffffa21.w
	move.b #8,$fffffa1b.w
	rte

hbl2	movem.l d0/a0,-(sp)
	lea $fffffa21.w,a0
	move.b (a0),d0
mfp2s1	cmp.b (a0),d0
	beq.s mfp2s1
	bclr #1,$ffff820a.w
	nnop 13
	bset #1,$ffff820a.w
	movem.l (sp)+,d0/a0
	clr.b $fffffa1b.w
	move.l #hbl3,$120.w
	move.b #30,$fffffa21.w
	move.b #8,$fffffa1b.w
	rte

hbl3	clr.w $ffff8240.w
	clr.b $fffffa1b.w
	rte

scroll	cmp.w #16,pt_lettre
	bne.s scroll_s2
	move.l pt_mess,a0
	moveq #0,d0
	move.b (a0)+,d0
	bpl.s scroll_s1
	lea mess_32,a0
	move.b (a0)+,d0
scroll_s1	move.l a0,pt_mess
	sub.w #32,d0
	lea ad_fnt,a0
	add.w d0,d0
	add.w d0,d0
	move.l (a0,d0.w),ad_fnt2
	move.w #0,pt_lettre
scroll_s2	move.l ad_tmp2,a1
	move.l ad_fnt2,a2
	add.w pt_lettre,a2
	move.l ad_tmp1,a3
	add.l #152,a3
	moveq #30,d0
scroll_s3	lea 8(a1),a0
	rept 38
	move.l (a0)+,(a1)+
	endr
	movep.l 1(a3),d1
	movep.l d1,0(a1)
	movep.l 0(a2),d1
	movep.l d1,1(a1)
	lea 160(a3),a3
	add.l #16,a2
	addq.w #8,a1
	dbra d0,scroll_s3
	move.w pt_lettre,d0
	addq.w #1,d0
	btst #0,d0
	bne.s scroll_s4
	addq.w #6,d0
scroll_s4	move.w d0,pt_lettre
	rts

eff_scroll	tst.l ad_old1
	beq eff_scrs2
	move.l ad_old1,a0
	movem.l null,d0-d7
	bsr.s eff_scrs1
	lea 28*160(a0),a0
eff_scrs1	lea 480(a0),a0
	rept 15
	movem.l d0-d7,-(a0)
	endr
eff_scrs2	rts

aff_scroll	move.l ad_tmp1,a0
	move.l screen2,a1
	move.l pt_sin,a2
	add.w (a2)+,a1
	cmp.l #end_sin,a2
	bne.s aff_scrs2
	lea courbe,a2
aff_scrs2	move.l a2,pt_sin
	move.l a1,ad_old1
	move.w #(31*160)/4-1,d0
aff_scrs1	move.l (a0)+,(a1)+
	dbra d0,aff_scrs1
	rts

aff_reflet	move.l screen2,a1
	lea 32000-(1*160)(a1),a1
	lea 160(a1),a2
	moveq #29,d0
aff_refs1	movem.l 0(a1),d1-a0
	movem.l d1-a0,0(a2)
	movem.l 32(a1),d1-a0
	movem.l d1-a0,32(a2)
	movem.l 64(a1),d1-a0
	movem.l d1-a0,64(a2)
	movem.l 96(a1),d1-a0
	movem.l d1-a0,96(a2)
	movem.l 128(a1),d1-a0
	movem.l d1-a0,128(a2)
	lea -160(a1),a1
	lea 160(a2),a2
	dbra d0,aff_refs1
	rts

decomp_pic	move.l #$c7,d4
	move.l #6,a0
	moveq #4,d6
	moveq #$28,d7
dec9	clr.b d1
	move.l a3,a4
dec8	move.l a4,-(sp)
	clr.b d3
dec7	move.b (a5)+,d0
	tst.b d0
	bmi.s dec1
	addq.b #1,d0
dec3	move.b (a5)+,(a4)+
	addq.b #1,d3
	move.l a4,d5
	btst #0,d5
	bne.s dec2
	add.l a0,a4
dec2	subq.b #1,d0
	bne.s dec3
	bra.s dec4
dec1	neg.b d0
	addq.b #1,d0
	move.b (a5)+,d2
dec6	move.b d2,(a4)+
	addq.b #1,d3
	move.l a4,d5
	btst #0,d5
	bne.s dec5
	add.l a0,a4
dec5	subq.b #1,d0
	bne.s dec6
dec4	cmp.b d7,d3
	BNE.S DEC7
	move.l (sp)+,a4
	addq.l #2,a4
	addq.b #1,d1
	cmp.b d6,d1
	bne.s dec8
	add.l #$a0,a3
	dbra d4,dec9
	rts
	section data

zik1	incbin a:\epic_sys\epic_001.mus
	even
zik2	incbin a:\epic_sys\epic_002.mus
	even
zik3	incbin a:\epic_sys\epic_003.mus
	even
zik4	incbin a:\epic_sys\epic_005.mus
	even
zik5	incbin a:\epic_sys\epic_008.mus
	even
zik6	incbin a:\epic_sys\epic_010.mus
	even
zik7	incbin a:\epic_sys\epic_013.mus
	even
zik8	incbin a:\epic_sys\epic_014.mus
	even
zik9	incbin a:\epic_sys\epic_015.mus
	even
zik10	incbin a:\epic_sys\epic_016.mus
	even
zik11	incbin a:\epic_sys\epic_017.mus
	even
zik12	incbin a:\epic_sys\epic_018.mus
	even
zik13	incbin a:\epic_sys\epic_019.mus
	even
zik14	incbin a:\epic_sys\epic_020.mus
	even
zik15	incbin a:\epic_sys\epic_021.mus
	even
zik16	incbin a:\epic_sys\epic_022.mus
	even

ad_zik	dc.l zik1,zik2,zik3,zik4
	dc.l zik5,zik6,zik7,zik8
	dc.l zik9,zik10,zik11,zik12
	dc.l zik13,zik14,zik15,zik16

pic	incbin a:\epic_sys\tms_log2.pc1
	even
pic2	incbin a:\loader\load.pc1
	even

fontes	incbin a:\epic_sys\isa_fnt.fnt

fontes_pal	incbin a:\epic_sys\isa_fnt.pal

courbe	incbin a:\epic_sys\courbe.sin
end_sin	equ *


mess_32	incbin a:\epic_sys\SCROLL.TXT
	even

ad_fnt	mtable_l 60,fontes,16*31

	section bss

old_vbl	ds.l 1
old_118	ds.l 1
old_hbl	ds.l 1
oldphys	ds.l 1
oldrez	ds.w 1
oldpal	ds.w 16

mfpa07	ds.b 1
mfpa09	ds.b 1
mfpa13	ds.b 1
mfpa15	ds.b 1
mfpa17	ds.b 1
mfpa1f	ds.b 1

null	ds.b 32

pt_vbl	ds.b 1
flag_exit	ds.b 1

screen1	ds.l 1
screen2	ds.l 1
ad_tmp1	ds.l 1
ad_tmp2	ds.l 1
ad_old1	ds.l 1
ad_old2	ds.l 1

pt_scrn	ds.w 1

pt_mess	ds.l 1
pt_lettre	ds.w 1
ad_fnt2	ds.l 1

pt_sin	ds.l 1

num_zik	ds.w 1
ad_play	ds.l 1

tmp1	ds.b 31*160

tmp2	ds.b 31*160

	ds.b 256
ecran	equ *