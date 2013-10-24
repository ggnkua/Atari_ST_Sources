	text
begin
	bra	relocation
	bra	fabrique_fonte_o
	bra	gfa_cadre_centre
	bra	l0001
	bra	gfa_dessine_cadr
	bra	gfa_affchaine_tr
	bra	l0004
	bra	gfa_affchaine_no
	bra	gfa_affcar8x6
	bra	gfa_affcar8x6_de
	bra	gfa_affcar8x6_om
	bra	l0009
	bra	gfa_affcar8x6nt_
	bra	gfa_affiche_patt
	bra	gfa_affiche_samp
	bra	gfa_convert_nt_2
	bra	gfa_convert_669_
	bra	gfa_convert_mtm_
	bra	gfa_signe_sample
	bra	l0011
	bra	gfa_stereo_2_mon
	bra	gfa_convert_mmd1
	bra	gfa_teste_icones
	bra	gfa_convert_s3m_
	bra	gfa_intel_16_bit
	bra	gfa_convert_ult_
	bra	gfa_convert_gtk_
	bra	gfa_clear_note_b
	bra	gfa_paste_note_b
	bra	gfa_atomik_35_un
	bra	gfa_swap_note_bl
	bra	gfa_transpose_no
	bra	gfa_packice_21_u
	bra	gfa_invert_memor
gfa_cadre_centre	movem.l	a0-a1/d0,-(a7)
	movea.l	16(a7),a0
	movea.l	20(a7),a1
	move.w	24(a7),d0
	bsr	cadre_centre
	movem.l	(a7)+,a0-a1/d0
	rts

l0001	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	dessine_cadre_in
	movea.l	(a7)+,a0
	rts

gfa_dessine_cadr	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	dessine_cadre_ex
	movea.l	(a7)+,a0
	rts

gfa_affchaine_tr	movem.l	a1/d2-d3/d0,-(a7)
	movea.l	20(a7),a1
	move.w	24(a7),d3
	move.w	26(a7),d2
	move.w	28(a7),d0
	bsr	affchaine_trans
	movem.l	(a7)+,a1/d2-d3/d0
	rts

l0004	movem.l	a1/d0-d3,-(a7)
	movea.l	24(a7),a1
	move.w	28(a7),d3
	move.w	30(a7),d2
	move.w	32(a7),d1
	move.w	34(a7),d0
	bsr	affchaine_trans_
	movem.l	(a7)+,a1/d0-d3
	rts

gfa_affchaine_no	movem.l	a1/d2-d3/d0,-(a7)
	movea.l	20(a7),a1
	move.w	24(a7),d3
	move.w	26(a7),d2
	move.w	28(a7),d0
	bsr	affchaine_notran
	movem.l	(a7)+,a1/d2-d3/d0
	rts

gfa_affcar8x6	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.w	20(a7),d1
	move.w	22(a7),d0
	bsr	affcar8x6
	movem.l	(a7)+,a0/d0-d1
	rts

gfa_affcar8x6_de	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.w	20(a7),d1
	move.w	22(a7),d0
	bsr	affcar8x6_dec
	movem.l	(a7)+,a0/d0-d1
	rts

gfa_affcar8x6_om	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.w	20(a7),d1
	move.w	22(a7),d0
	bsr	affcar8x6_ombr
	movem.l	(a7)+,a0/d0-d1
	rts

l0009	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.w	20(a7),d1
	move.w	22(a7),d0
	bsr	affcar8x6_ombr_d
	movem.l	(a7)+,a0/d0-d1
	rts

gfa_affcar8x6nt_	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.w	20(a7),d1
	move.w	22(a7),d0
	bsr	affcar8x6nt_ombr
	movem.l	(a7)+,a0/d0-d1
	rts

gfa_affiche_patt	movem.l	a0-a2/d0-d2,-(a7)
	move.w	28(a7),d0
	movea.l	30(a7),a0
	movea.l	34(a7),a1
	movea.l	38(a7),a2
	move.w	42(a7),d1
	move.w	44(a7),d2
	bsr	affiche_pattern
	movem.l	(a7)+,a0-a2/d0-d2
	rts

gfa_affiche_samp	movem.l	a0/d0-d6,-(a7)
	movea.l	36(a7),a0
	move.l	40(a7),d0
	move.w	44(a7),d1
	move.w	46(a7),d2
	move.w	48(a7),d3
	move.w	50(a7),d4
	move.l	52(a7),d5
	move.l	56(a7),d6
	bsr	affiche_sample
	movem.l	(a7)+,a0/d0-d6
	rts

gfa_convert_nt_2	movem.l	a0/d0,-(a7)
	movea.l	12(a7),a0
	move.l	16(a7),d0
	bsr	convert_nt_2_gtk
	movem.l	(a7)+,a0/d0
	rts

gfa_convert_669_	movem.l	a0-a1,-(a7)
	movea.l	12(a7),a0
	movea.l	16(a7),a1
	bsr	convert_669_2_gt
	movem.l	(a7)+,a0-a1
	rts

gfa_convert_mtm_	movem.l	a0-a1/d0-d1,-(a7)
	movea.l	20(a7),a0
	movea.l	24(a7),a1
	move.w	28(a7),d0
	move.w	30(a7),d1
	bsr	convert_mtm_voic
	movem.l	(a7)+,a0-a1/d0-d1
	rts

gfa_signe_sample	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.l	20(a7),d0
	move.w	24(a7),d1
	bsr	signe_sample
	movem.l	(a7)+,a0/d0-d1
	rts

l0011	movem.l	a0-a1/d0-d1,-(a7)
	movea.l	20(a7),a0
	movea.l	24(a7),a1
	move.l	28(a7),d0
	move.w	32(a7),d1
	bsr	stereo_2_mono_on
	movem.l	(a7)+,a0-a1/d0-d1
	rts

gfa_stereo_2_mon	movem.l	a0-a1/d0-d1,-(a7)
	movea.l	20(a7),a0
	movea.l	24(a7),a1
	move.l	28(a7),d0
	move.w	32(a7),d1
	bsr	stereo_2_mono_av
	movem.l	(a7)+,a0-a1/d0-d1
	rts

gfa_convert_mmd1	movem.l	a0-a2/d6/d0-d1,-(a7)
	movea.l	28(a7),a0
	movea.l	32(a7),a1
	movea.l	36(a7),a2
	move.w	40(a7),d0
	move.w	42(a7),d1
	move.w	44(a7),d6
	bsr	convert_mmd1_2_g
	movem.l	(a7)+,a0-a2/d6/d0-d1
	rts

gfa_teste_icones	movem.l	a0/d1-d2,-(a7)
	movea.l	16(a7),a0
	move.w	20(a7),d0
	move.w	22(a7),d1
	move.w	24(a7),d2
	bsr	teste_icones
	movem.l	(a7)+,a0/d1-d2
	rts

gfa_convert_s3m_	movem.l	a0-a2/d0,-(a7)
	movea.l	20(a7),a0
	movea.l	24(a7),a1
	movea.l	28(a7),a2
	move.w	32(a7),d0
	bsr	convert_s3m_2_gt
	movem.l	(a7)+,a0-a2/d0
	rts

gfa_intel_16_bit	movem.l	a0/d0,-(a7)
	movea.l	12(a7),a0
	move.l	16(a7),d0
	bsr	intel_16_bits
	movem.l	(a7)+,a0/d0
	rts

gfa_convert_ult_	movem.l	a0-a1,-(a7)
	movea.l	12(a7),a0
	movea.l	16(a7),a1
	move.w	20(a7),d0
	bsr	convert_ult_2_gt
	movem.l	(a7)+,a0-a1
	rts

gfa_convert_gtk_	movem.l	a0/d0,-(a7)
	movea.l	12(a7),a0
	move.l	16(a7),d0
	bsr	convert_gtk_2_gt
	movem.l	(a7)+,a0/d0
	rts

gfa_clear_note_b	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	clear_note_block
	movea.l	(a7)+,a0
	rts

gfa_paste_note_b	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	paste_note_block
	movea.l	(a7)+,a0
	rts

gfa_atomik_35_un	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	atomik_35_unpack
	movea.l	(a7)+,a0
	rts

gfa_swap_note_bl	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	swap_note_block
	movea.l	(a7)+,a0
	rts

gfa_transpose_no	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	transpose_note_b
	movea.l	(a7)+,a0
	rts

gfa_packice_21_u	move.l	a0,-(a7)
	movea.l	8(a7),a0
	bsr	packice_21_unpac
	movea.l	(a7)+,a0
	rts

gfa_invert_memor	movem.l	a0/d0-d1,-(a7)
	movea.l	16(a7),a0
	move.l	20(a7),d0
	move.w	24(a7),d1
	bsr	invert_memory
	movem.l	(a7)+,a0/d0-d1
	rts

relocation	movem.l	a0-a2/d1,-(a7)
	movea.l	20(a7),a0
	move.l	2(a0),d0
	add.l	6(a0),d0
	add.l	14(a0),d0
	adda.l	#$1c,a0
	move.l	a0,d1
	movea.l	a0,a1
	movea.l	a1,a2
	adda.l	d0,a1
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	clr.l	d0
relocloop	move.b	(a1)+,d0
	beq.s	reloc_end
	cmp.b	#1,d0
	beq.s	reloc_nxt
	adda.l	d0,a2
	add.l	d1,(a2)
	bra.s	relocloop
reloc_nxt	adda.l	#$fe,a2
	bra.s	relocloop
reloc_end	lea	adrecr(pc),a0
	move.l	a0,d0
	movem.l	(a7)+,a0-a2/d1
	rts

invert_memory	movem.l	a0-a1/d0-d1,-(a7)
	lea	0(a0,d0.l),a1
	lsr.l	#1,d0
	cmp.w	#2,d1
	beq.s	l0027
	subq.l	#1,d0
	swap	d0
l0025	swap	d0
l0026	move.b	(a0),d1
	move.b	-(a1),(a0)+
	move.b	d1,(a1)
	dbf	d0,l0026
	swap	d0
	dbf	d0,l0025
	bra.s	l002a
l0027	lsr.l	#1,d0
	subq.l	#1,d0
	swap	d0
l0028	swap	d0
l0029	move.w	(a0),d1
	move.w	-(a1),(a0)+
	move.w	d1,(a1)
	dbf	d0,l0029
	swap	d0
	dbf	d0,l0028
l002a	movem.l	(a7)+,a0-a1/d0-d1
	rts

atomik_35_unpack	movem.l	a0-a6/d0-d7,-(a7)
	cmpi.l	#$41544d35,(a0)+
	bne	atm35_e1
	link	a2,#$ffe4
	move.l	(a0)+,d0
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	movea.l	a5,a4
	lea	128(a4),a5
	lea	-12(a4),a4
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	lsl.w	#2,d0
	suba.w	d0,a4
	lea	ice2_21(pc),a3
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$8c,d0
	bra.s	atm35_b5
atm35_b4	move.b	(a4)+,(a3)+
	subq.w	#1,d0
atm35_b5	bne.s	atm35_b4
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.b	-(a6),d7
	bra	atm35_d5
atm35_b6	move.w	d3,d5
atm35_b7	add.b	d7,d7
atm35_b8	dbcs	d5,atm35_b7
	beq.s	atm35_bb
	bcc.s	atm35_b9
	sub.w	d3,d5
	neg.w	d5
	bra.s	atm35_be
atm35_b9	moveq	#3,d6
	bsr.s	atm35_c4
	beq.s	atm35_ba
	bra.s	atm35_bd
atm35_ba	moveq	#7,d6
	bsr.s	atm35_c4
	beq.s	atm35_bc
	addi.w	#$f,d5
	bra.s	atm35_bd
atm35_bb	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	atm35_b8
atm35_bc	moveq	#$d,d6
	bsr.s	atm35_c4
	addi.w	#$10e,d5
atm35_bd	add.w	d3,d5
atm35_be	lea	atm35_e2(pc),a4
	move.w	d5,d2
	bne.s	atm35_c8
	add.b	d7,d7
	bne.s	atm35_bf
	move.b	-(a6),d7
	addx.b	d7,d7
atm35_bf	bcs.s	atm35_c0
	moveq	#1,d6
	bra.s	atm35_c9
atm35_c0	moveq	#3,d6
	bsr.s	atm35_c4
	tst.b	-28(a2)
	beq.s	atm35_c1
	move.b	-18(a2,d5.w),-(a5)
	bra	atm35_d4
atm35_c1	move.b	(a5),d0
	btst	#3,d5
	bne.s	atm35_c2
	bra.s	atm35_c3
atm35_c2	addi.b	#$f0,d5
atm35_c3	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	atm35_d4
atm35_c4	clr.w	d5
atm35_c5	add.b	d7,d7
	beq.s	atm35_c7
atm35_c6	addx.w	d5,d5
	dbf	d6,atm35_c5
	tst.w	d5
	rts

atm35_c7	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	atm35_c6
atm35_c8	moveq	#2,d6
atm35_c9	bsr.s	atm35_c4
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	atm35_ca
	addq.w	#4,d6
	bra.s	atm35_ce
atm35_ca	bsr.s	atm35_c4
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	atm35_c4
	cmp.b	#7,d5
	blt.s	atm35_cc
	moveq	#0,d6
	bsr.s	atm35_c4
	beq.s	atm35_cb
	moveq	#2,d6
	bsr.s	atm35_c4
	add.w	d5,d5
	or.w	d1,d5
	bra.s	atm35_cf
atm35_cb	or.b	-26(a2),d1
	bra.s	atm35_cd
atm35_cc	or.b	-25(a2,d5.w),d1
atm35_cd	move.w	d1,d5
	bra.s	atm35_cf
atm35_ce	bsr.s	atm35_c4
atm35_cf	add.w	d4,d4
	beq.s	atm35_d0
	add.w	-2(a4,d4.w),d5
atm35_d0	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
atm35_d1	move.b	-(a4),-(a5)
	dbf	d2,atm35_d1
	bra.s	atm35_d4
atm35_d2	add.b	d7,d7
	bne.s	atm35_d3
	move.b	-(a6),d7
	addx.b	d7,d7
atm35_d3	bcs.s	atm35_dd
	move.b	-(a6),-(a5)
atm35_d4	cmpa.l	a5,a3
	bne.s	atm35_d2
	cmpa.l	a6,a0
	beq.s	atm35_de
atm35_d5	moveq	#0,d6
	bsr	atm35_c4
	beq.s	atm35_d8
	move.b	-(a6),d0
	lea	-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
atm35_d6	cmp.b	d0,d1
	bne.s	atm35_d7
	addq.w	#2,d1
atm35_d7	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,atm35_d6
	st	-27(a2)
	bra.s	atm35_d9
atm35_d8	sf	-27(a2)
atm35_d9	moveq	#0,d6
	bsr	atm35_c4
	beq.s	atm35_db
	lea	-18(a2),a1
	moveq	#$f,d0
atm35_da	move.b	-(a6),(a1)+
	dbf	d0,atm35_da
	st	-28(a2)
	bra.s	atm35_dc
atm35_db	sf	-28(a2)
atm35_dc	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	atm35_d2
atm35_dd	bra	atm35_b6
atm35_de	movea.l	(a7)+,a0
	pea	(a2)
	bsr.s	atm35_e3
	movea.l	(a7)+,a2
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr	atm35_e9
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$8c,d0
	bra.s	atm35_e0
atm35_df	move.b	-(a3),-(a4)
	subq.w	#1,d0
atm35_e0	bne.s	atm35_df
	unlk	a2
atm35_e1	movem.l	(a7)+,a0-a6/d0-d7
	rts

atm35_e2	dc.b	0,' ',0,'`',1,'`',3,'`'
	dc.b	7,'`',$f,'`',$1f,'`',0,1
	dc.b	3,4,5,6,7,8
atm35_e3	move.w	-2(a2),d7
atm35_e4	dbf	d7,atm35_e5
	rts

atm35_e5	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
	lea	32000(a1),a2
atm35_e6	moveq	#3,d6
atm35_e7	move.w	(a1)+,d0
	moveq	#3,d5
atm35_e8	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,atm35_e8
	dbf	d6,atm35_e7
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	atm35_e6
	bra.s	atm35_e4
atm35_e9	lsr.l	#4,d0
	lea	-12(a6),a6
atm35_ea	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,atm35_ea
	rts

packice_21_unpac	movem.l	a0-a6/d0-d7,-(a7)
	cmpi.l	#$49636521,(a0)+
	bne.s	ice2_07
	move.l	(a0)+,d0
	lea	-8(a0,d0.l),a5
	move.l	(a0)+,(a7)
	lea	108(a0),a4
	movea.l	a4,a6
	adda.l	(a7),a6
	movea.l	a6,a3
	movea.l	a6,a1
	lea	l0226(pc),a2
	moveq	#$77,d0
ice2_00	move.b	-(a1),-(a2)
	dbf	d0,ice2_00
	bsr	ice2_0c
	bsr.s	ice2_08
	bsr	ice2_10
	bcc.s	ice2_04
	movea.l	a3,a1
	move.w	#$f9f,d7
ice2_01	moveq	#3,d6
ice2_02	move.w	-(a1),d4
	moveq	#3,d5
ice2_03	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbf	d5,ice2_03
	dbf	d6,ice2_02
	movem.w	d0-d3,(a1)
	dbf	d7,ice2_01
ice2_04	move.l	(a7),d0
	lea	-120(a4),a1
ice2_05	move.b	(a4)+,(a1)+
	dbf	d0,ice2_05
	subi.l	#$10000,d0
	bpl.s	ice2_05
	moveq	#$77,d0
	lea	l0226(pc),a2
ice2_06	move.b	-(a2),-(a3)
	dbf	d0,ice2_06
ice2_07	movem.l	(a7)+,a0-a6/d0-d7
	rts

ice2_08	bsr.s	ice2_10
	bcc.s	ice2_0b
	moveq	#0,d1
	bsr.s	ice2_10
	bcc.s	ice2_0a
	lea	ice2_1e(pc),a1
	moveq	#4,d3
ice2_09	move.l	-(a1),d0
	bsr.s	ice2_13
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice2_09
	add.l	20(a1),d1
ice2_0a	move.b	-(a5),-(a6)
	dbf	d1,ice2_0a
ice2_0b	cmpa.l	a4,a6
	bgt.s	ice2_16
	rts

ice2_0c	moveq	#3,d0
ice2_0d	move.b	-(a5),d7
	ror.l	#8,d7
	dbf	d0,ice2_0d
	rts

ice2_0e	move.w	a5,d7
	btst	#0,d7
	bne.s	ice2_0f
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	ice2_15
ice2_0f	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	ice2_15
ice2_10	add.l	d7,d7
	beq.s	ice2_11
	rts

ice2_11	move.w	a5,d7
	btst	#0,d7
	bne.s	ice2_12
	move.l	-(a5),d7
	addx.l	d7,d7
	rts

ice2_12	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts

ice2_13	moveq	#0,d1
ice2_14	add.l	d7,d7
	beq.s	ice2_0e
ice2_15	addx.w	d1,d1
	dbf	d0,ice2_14
	rts

ice2_16	lea	ice2_1f(pc),a1
	moveq	#3,d2
ice2_17	bsr.s	ice2_10
	dbcc	d2,ice2_17
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice2_18
	bsr.s	ice2_13
ice2_18	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice2_1a
	lea	ice2_20(pc),a1
	moveq	#1,d2
ice2_19	bsr.s	ice2_10
	dbcc	d2,ice2_19
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice2_13
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	ice2_1c
ice2_1a	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	ice2_10
	bcc.s	ice2_1b
	moveq	#8,d0
	moveq	#$40,d2
ice2_1b	bsr.s	ice2_13
	add.w	d2,d1
ice2_1c	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice2_1d	move.b	-(a1),-(a6)
	dbf	d4,ice2_1d
	bra	ice2_08
	dc.b	$7f,$ff,0,$e,0,$ff,0,7
	dc.b	0,7,0,2,0,3,0,1
	dc.b	0,3,0,1
ice2_1e	dc.b	0,0,1,$d,0,0,0,$e
	dc.b	0,0,0,7,0,0,0,4
	dc.b	0,0,0,1
ice2_1f	dc.b	9,1,0,$ff,$ff,8,4,2
	dc.b	1,0
ice2_20	dc.b	$b,4,7,0,1,' ',0,0
	dc.b	0,' '
paste_note_block	movem.l	a1-a5/d0-d3,-(a7)
	movea.l	0(a0),a1
	movea.l	4(a0),a2
	movea.l	40(a0),a3
	move.l	8(a0),d0
	move.w	12(a0),d1
	subq.w	#1,d1
	tst.w	38(a0)
	bne.s	pnb_pattern
pnbtra_loop	bsr	copie_note
	adda.l	d0,a1
	adda.l	d0,a2
	dbf	d1,pnbtra_loop
	bra.s	pnb_fin
pnb_pattern	cmpi.w	#1,38(a0)
	bne.s	pnb_preset
pnbpat_loop1	movea.l	a1,a4
	movea.l	a2,a5
	move.w	34(a0),d2
	subq.w	#1,d2
pnbpat_loop2	bsr	copie_note
	addq.l	#5,a1
	addq.l	#5,a2
	dbf	d2,pnbpat_loop2
	movea.l	a4,a1
	movea.l	a5,a2
	adda.l	d0,a1
	adda.l	d0,a2
	dbf	d1,pnbpat_loop1
	bra.s	pnb_fin
pnb_preset	move.w	36(a0),d2
	subq.w	#1,d2
	movea.l	a1,a4
	movea.l	a2,a5
pnbpre_loop2	move.w	(0.b,a3,d2.w*2),d3
	mulu	#5,d3
	adda.l	d3,a1
	adda.l	d3,a2
	bsr	copie_note
	movea.l	a4,a1
	movea.l	a5,a2
	dbf	d2,pnbpre_loop2
	adda.l	d0,a1
	adda.l	d0,a2
	dbf	d1,pnb_preset
pnb_fin	movem.l	(a7)+,a1-a5/d0-d3
	rts

swap_note_block	movem.l	a1-a5/d0-d3,-(a7)
	movea.l	0(a0),a1
	movea.l	4(a0),a2
	movea.l	40(a0),a3
	move.l	8(a0),d0
	move.w	12(a0),d1
	subq.w	#1,d1
	tst.w	38(a0)
	bne.s	snb_pattern
snbtra_loop	move.l	(a1),d3
	move.l	(a2),(a1)
	move.l	d3,(a2)
	move.b	4(a1),d3
	move.b	4(a2),4(a1)
	move.b	d3,4(a2)
	adda.l	d0,a1
	adda.l	d0,a2
	dbf	d1,snbtra_loop
	bra.s	snb_fin
snb_pattern	cmpi.w	#1,38(a0)
	bne.s	snb_preset
snbpat_loop1	movea.l	a1,a4
	movea.l	a2,a5
	move.w	34(a0),d2
	subq.w	#1,d2
snbpat_loop2	move.l	(a1),d3
	move.l	(a2),(a1)
	move.l	d3,(a2)
	move.b	4(a1),d3
	move.b	4(a2),4(a1)
	move.b	d3,4(a2)
	addq.l	#5,a1
	addq.l	#5,a2
	dbf	d2,snbpat_loop2
	movea.l	a4,a1
	movea.l	a5,a2
	adda.l	d0,a1
	adda.l	d0,a2
	dbf	d1,snbpat_loop1
	bra.s	snb_fin
snb_preset	move.w	36(a0),d2
	subq.w	#1,d2
	movea.l	a1,a4
	movea.l	a2,a5
snbpre_loop2	move.w	(0.b,a3,d2.w*2),d3
	mulu	#5,d3
	adda.l	d3,a1
	adda.l	d3,a2
	move.l	(a1),d3
	move.l	(a2),(a1)
	move.l	d3,(a2)
	move.b	4(a1),d3
	move.b	4(a2),4(a1)
	move.b	d3,4(a2)
	movea.l	a4,a1
	movea.l	a5,a2
	dbf	d2,snbpre_loop2
	adda.l	d0,a1
	adda.l	d0,a2
	dbf	d1,snb_preset
snb_fin	movem.l	(a7)+,a1-a5/d0-d3
	rts

clear_note_block	movem.l	a1-a3/d0-d3,-(a7)
	movea.l	0(a0),a1
	movea.l	40(a0),a3
	move.l	8(a0),d0
	move.w	12(a0),d1
	subq.w	#1,d1
	tst.w	38(a0)
	bne.s	cnb_pattern
cnbtra_loop	bsr	clear_note
	adda.l	d0,a1
	dbf	d1,cnbtra_loop
	bra.s	cnb_fin
cnb_pattern	cmpi.w	#1,38(a0)
	bne.s	cnb_preset
cnbpat_loop1	movea.l	a1,a2
	move.w	34(a0),d2
	subq.w	#1,d2
cnbpat_loop2	bsr	clear_note
	addq.l	#5,a1
	dbf	d2,cnbpat_loop2
	movea.l	a2,a1
	adda.l	d0,a1
	dbf	d1,cnbpat_loop1
	bra.s	cnb_fin
cnb_preset	move.w	36(a0),d2
	subq.w	#1,d2
	movea.l	a1,a2
cnbpre_loop2	move.w	(0.b,a3,d2.w*2),d3
	mulu	#5,d3
	adda.l	d3,a1
	bsr	clear_note
	movea.l	a2,a1
	dbf	d2,cnbpre_loop2
	adda.l	d0,a1
	dbf	d1,cnb_preset
cnb_fin	movem.l	(a7)+,a1-a3/d0-d3
	rts

transpose_note_b	movem.l	a1-a3/d0-d4,-(a7)
	movea.l	0(a0),a1
	move.l	4(a0),d4
	movea.l	40(a0),a3
	move.l	8(a0),d0
	move.w	12(a0),d1
	subq.w	#1,d1
	tst.w	38(a0)
	bne.s	tnb_pattern
tnbtra_loop	bsr	transpose_note
	adda.l	d0,a1
	dbf	d1,tnbtra_loop
	bra.s	tnb_fin
tnb_pattern	cmpi.w	#1,38(a0)
	bne.s	tnb_preset
tnbpat_loop1	movea.l	a1,a2
	move.w	34(a0),d2
	subq.w	#1,d2
tnbpat_loop2	bsr	transpose_note
	addq.l	#5,a1
	dbf	d2,tnbpat_loop2
	movea.l	a2,a1
	adda.l	d0,a1
	dbf	d1,tnbpat_loop1
	bra.s	tnb_fin
tnb_preset	move.w	36(a0),d2
	subq.w	#1,d2
	movea.l	a1,a2
tnbpre_loop2	move.w	(0.b,a3,d2.w*2),d3
	mulu	#5,d3
	adda.l	d3,a1
	bsr	transpose_note
	movea.l	a2,a1
	dbf	d2,tnbpre_loop2
	adda.l	d0,a1
	dbf	d1,tnb_preset
tnb_fin	movem.l	(a7)+,a1-a3/d0-d4
	rts

copie_note	movem.l	a4-a5/d3,-(a7)
	tst.w	30(a0)
	bne.s	cn_masque
	tst.l	(a1)
	bne.s	l00a6
	tst.b	4(a1)
	bne.s	l00a6
	tst.w	32(a0)
	bne.s	cn_fin
l00a6	move.l	(a1),(a2)
	move.b	4(a1),4(a2)
	bra.s	cn_fin
cn_masque	tst.l	(a1)
	bne.s	l00a8
	tst.b	4(a1)
	bne.s	l00a8
	tst.w	32(a0)
	bne.s	cn_fin
l00a8	movea.l	14(a0),a4
	movea.l	18(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	cmp.l	(a5),d3
	bne.s	l00a9
	move.b	4(a1),d3
	and.b	4(a4),d3
	cmp.b	4(a5),d3
	bne.s	l00a9
	movea.l	22(a0),a4
	movea.l	26(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	or.l	(a5),d3
	move.l	d3,(a2)
	move.b	4(a1),d3
	and.b	4(a4),d3
	or.b	4(a5),d3
	move.b	d3,4(a2)
	bra.s	cn_fin
l00a9	tst.w	32(a0)
	bne.s	cn_fin
	clr.l	(a2)
	clr.b	4(a2)
cn_fin	movem.l	(a7)+,a4-a5/d3
	rts

clear_note	movem.l	a4-a5/d3,-(a7)
	tst.w	30(a0)
	beq.s	clrn_sansmasque
	movea.l	14(a0),a4
	movea.l	18(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	cmp.l	(a5),d3
	bne.s	clrn_fin
	move.b	4(a1),d3
	and.b	4(a4),d3
	cmp.b	4(a5),d3
	bne.s	clrn_fin
clrn_sansmasque	clr.l	(a1)
	clr.b	4(a1)
clrn_fin	movem.l	(a7)+,a4-a5/d3
	rts

transpose_note	movem.l	a4-a5/d3,-(a7)
	tst.b	(a1)
	beq.s	tran_fin
	tst.w	30(a0)
	beq.s	tran_sansmasque
	movea.l	14(a0),a4
	movea.l	18(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	cmp.l	(a5),d3
	bne.s	tran_fin
	move.b	4(a1),d3
	and.b	4(a4),d3
	cmp.b	4(a5),d3
	bne.s	tran_fin
tran_sansmasque	moveq	#0,d3
	move.b	(a1),d3
	add.w	d4,d3
	cmp.w	#$53,d3
	ble.s	l00b0
	moveq	#$53,d3
l00b0	cmp.w	#$18,d3
	bge.s	l00b1
	moveq	#$18,d3
l00b1	move.b	d3,(a1)
tran_fin	movem.l	(a7)+,a4-a5/d3
	rts

convert_gtk_2_gt	movem.l	a0-a1/d0,-(a7)
	lea	(0.b,a0,d0.l*4),a0
	lea	0(a0,d0.l),a1
l00b4	clr.b	-(a1)
	move.l	-(a0),-(a1)
	subq.l	#1,d0
	bne.s	l00b4
	movem.l	(a7)+,a0-a1/d0
	rts

convert_ult_2_gt	movem.l	a0-a1/d1-d7,-(a7)
	move.w	d0,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d1
	moveq	#0,d0
	moveq	#$40,d6
cv_ult2gtk_loop2	move.b	(a0),d2
	moveq	#1,d5
	cmp.b	#$fc,d2
	bne.s	l00b7
	move.b	1(a0),d5
	addq.l	#2,a0
	addq.l	#2,d0
l00b7	subq.w	#1,d5
	moveq	#0,d2
	move.b	(a0)+,d3
	beq.s	l00b8
	addi.b	#$17,d3
l00b8	lsl.w	#8,d3
	move.b	(a0)+,d3
	move.w	d3,d2
	swap	d2
	moveq	#0,d7
	cmpi.b	#$99,(a0)
	bne.s	l00b9
	move.w	1(a0),d2
	lsr.w	#6,d2
	addi.w	#$9000,d2
	bra	l00ba
l00b9	moveq	#0,d3
	moveq	#0,d4
	move.b	(a0),d3
	andi.b	#$f,d3
	move.b	1(a0),d4
	bsr	convert_ultfx_2_
	moveq	#0,d3
	moveq	#0,d4
	move.b	(a0),d3
	lsr.b	#4,d3
	move.b	2(a0),d4
	bsr	convert_ultfx_2_
l00ba	addq.l	#3,a0
	addq.l	#5,d0
l00bb	move.l	d2,(a1)
	move.b	d7,4(a1)
	adda.w	d1,a1
	subq.w	#1,d6
	tst.w	d6
	beq.s	cv_ult2gtk_finvo
	dbf	d5,l00bb
	bra	cv_ult2gtk_loop2
cv_ult2gtk_finvo	movem.l	(a7)+,a0-a1/d1-d7
	rts

convert_ultfx_2_	cmp.b	#1,d3
	beq.s	l00be
	cmp.b	#2,d3
	beq.s	l00be
	cmp.b	#3,d3
	beq.s	l00be
	cmp.b	#4,d3
	beq.s	l00be
	cmp.b	#7,d3
	beq.s	l00be
	cmp.b	#$d,d3
	bne.s	l00bf
l00be	lsl.w	#8,d3
	add.w	d4,d3
	move.w	d3,d2
	bra	l00cf
l00bf	tst.b	d3
	bne.s	l00c0
	tst.b	d4
	beq	l00cf
	addi.w	#$1000,d4
	move.w	d4,d2
	bra	l00cf
l00c0	cmp.b	#9,d3
	bne.s	l00c1
	add.w	d4,d4
	add.w	d4,d4
	addi.w	#$9000,d4
	move.w	d4,d2
	bra	l00cf
l00c1	cmp.b	#$a,d3
	bne.s	l00c3
	move.b	d4,d3
	lsr.b	#4,d4
	andi.b	#$f,d3
	sub.w	d3,d4
	bmi.s	l00c2
	addi.w	#$1400,d4
	move.w	d4,d2
	bra	l00cf
l00c2	neg.w	d4
	addi.w	#$1500,d4
	move.w	d4,d2
	bra	l00cf
l00c3	cmp.b	#$b,d3
	bne.s	l00c4
	andi.b	#$f,d4
	lsl.w	#8,d4
	addi.w	#$4000,d4
	move.w	d4,d2
	bra	l00cf
l00c4	cmp.b	#$c,d3
	bne.s	l00c6
	tst.b	d4
	bne.s	l00c5
	move.w	#$2000,d2
	bra	l00cf
l00c5	move.b	d4,d7
	bra	l00cf
l00c6	cmp.b	#$f,d3
	bne.s	l00c7
	cmp.w	#$30,d3
	bge	l00be
	move.w	#$a800,d2
	add.w	d4,d2
	bra.s	l00cf
l00c7	cmp.b	#$e,d3
	bne.s	l00cf
	move.b	d4,d3
	lsr.b	#4,d3
	andi.b	#$f,d4
	cmp.b	#1,d3
	bne.s	l00c8
	addi.w	#$1100,d4
	move.w	d4,d2
	bra.s	l00cf
l00c8	cmp.b	#2,d3
	bne.s	l00c9
	addi.w	#$1200,d4
	move.w	d4,d2
	bra.s	l00cf
l00c9	cmp.b	#8,d3
	bne.s	l00ca
	addi.w	#$aa00,d4
	move.w	d4,d2
	bra.s	l00cf
l00ca	cmp.b	#9,d3
	bne.s	l00cb
	addi.b	#$70,d4
	lsl.w	#8,d4
	move.w	d4,d2
	bra.s	l00cf
l00cb	cmp.b	#$a,d3
	bne.s	l00cc
	addi.w	#$a400,d4
	move.w	d4,d2
	bra.s	l00cf
l00cc	cmp.b	#$b,d3
	bne.s	l00cd
	addi.w	#$a500,d4
	move.w	d4,d2
	bra.s	l00cf
l00cd	cmp.b	#$c,d3
	bne.s	l00ce
	addi.w	#$a00,d4
	move.w	d4,d2
	bra.s	l00cf
l00ce	cmp.b	#$d,d3
	bne.s	l00cf
	addi.w	#$900,d4
	move.w	d4,d2
l00cf	rts

intel_16_bits	movem.l	a0/d0-d1,-(a7)
	lsr.l	#1,d0
l00d1	move.b	1(a0),d1
	move.b	(a0)+,(a0)+
	move.b	d1,-2(a0)
	dbf	d0,l00d1
	movem.l	(a7)+,a0/d0-d1
	rts

convert_s3m_2_gt	movem.l	a0-a3/d0-d5,-(a7)
	move.w	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#$3f,d3
cv_s3m2gtk_loop1	move.b	(a0)+,d1
	beq	cv_s3m2gtk_finli
	move.b	d1,d2
	andi.b	#$1f,d2
	move.b	0(a2,d2.w),d2
	cmp.b	#$ff,d2
	bne.s	l00d6
	btst	#5,d1
	beq.s	l00d4
	addq.l	#2,a0
l00d4	btst	#6,d1
	beq.s	l00d5
	addq.l	#1,a0
l00d5	btst	#7,d1
	beq.s	cv_s3m2gtk_loop1
	addq.l	#2,a0
	bra.s	cv_s3m2gtk_loop1
l00d6	lea	(0.b,a1,d2.w*4),a3
	lea	0(a3,d2.w),a3
	btst	#5,d1
	beq.s	l00da
	moveq	#0,d4
	move.b	(a0)+,d4
	move.b	(a0)+,1(a3)
	cmp.w	#$ff,d4
	bne.s	l00d7
	bra.s	l00da
l00d7	cmp.w	#$fe,d4
	bne.s	l00d8
	move.w	#$2000,2(a3)
	bra.s	l00da
l00d8	move.w	d4,d5
	andi.b	#$f,d4
	lsr.b	#4,d5
	mulu	#$c,d5
	add.w	d5,d4
	cmp.b	#$18,d4
	bge.s	l00d9
	moveq	#0,d4
l00d9	move.b	d4,(a3)
l00da	btst	#6,d1
	beq.s	l00dd
	move.w	#$800,d4
	move.b	(a0)+,d4
	cmp.b	#$ff,d4
	beq.s	l00dd
	add.w	d4,d4
	add.w	d4,d4
	cmp.w	#$2100,d4
	bne.s	l00db
	move.w	d4,2(a3)
	subq.w	#1,d4
l00db	tst.b	d4
	bne.s	l00dc
	move.w	d4,2(a3)
	addq.w	#1,d4
l00dc	move.b	d4,4(a3)
l00dd	btst	#7,d1
	beq	cv_s3m2gtk_loop1
	moveq	#0,d4
	moveq	#0,d5
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	cmp.b	#1,d4
	bne.s	l00de
	addi.w	#$a800,d5
	bra	l00fe
l00de	cmp.b	#2,d4
	bne.s	l00df
	addi.w	#$b00,d5
	bra	l00fe
l00df	cmp.b	#3,d4
	bne.s	l00e0
	addi.w	#$d00,d5
	bra	l00fe
l00e0	cmp.b	#4,d4
	bne.s	l00e4
	move.w	d5,d1
	andi.b	#$f,d1
	bne.s	l00e1
	lsr.b	#2,d5
	andi.b	#$3c,d5
	addi.w	#$1400,d5
	bra	l00fe
l00e1	cmp.b	#$f,d1
	bne.s	l00e2
	lsr.b	#2,d5
	andi.b	#$3c,d5
	addi.w	#$a400,d5
	bra	l00fe
l00e2	move.w	d5,d1
	andi.b	#$f0,d1
	bne.s	l00e3
	andi.b	#$f,d5
	add.b	d5,d5
	add.b	d5,d5
	addi.w	#$1500,d5
	bra	l00fe
l00e3	andi.b	#$f,d5
	add.b	d5,d5
	add.b	d5,d5
	addi.w	#$a500,d5
	bra	l00fe
l00e4	cmp.b	#5,d4
	bne.s	l00e7
	move.w	d5,d1
	andi.w	#$f0,d1
	cmp.b	#$f0,d1
	bne.s	l00e5
	andi.b	#$f,d5
	addi.w	#$1200,d5
	bra	l00fe
l00e5	cmp.b	#$e0,d1
	bne.s	l00e6
	andi.b	#$f,d5
	addi.w	#$ad00,d5
	bra	l00fe
l00e6	addi.w	#$200,d5
	bra	l00fe
l00e7	cmp.b	#6,d4
	bne.s	l00ea
	move.w	d5,d1
	andi.w	#$f0,d1
	cmp.b	#$f0,d1
	bne.s	l00e8
	andi.b	#$f,d5
	addi.w	#$1100,d5
	bra	l00fe
l00e8	cmp.b	#$e0,d1
	bne.s	l00e9
	andi.b	#$f,d5
	addi.w	#$ac00,d5
	bra	l00fe
l00e9	addi.w	#$100,d5
	bra	l00fe
l00ea	cmp.b	#7,d4
	bne.s	l00eb
	addi.w	#$300,d5
	bra	l00fe
l00eb	cmp.b	#8,d4
	bne.s	l00ec
	addi.w	#$400,d5
	bra	l00fe
l00ec	cmp.b	#9,d4
	bne.s	l00ed
	bra	l00fe
l00ed	cmp.b	#$a,d4
	bne.s	l00ee
	addi.w	#$1000,d5
	bra	l00fe
l00ee	cmp.b	#$b,d4
	bne.s	l00f0
	move.w	d5,d4
	andi.w	#$f,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	bmi.s	l00ef
	addi.w	#$1c00,d5
	bra	l00fe
l00ef	subi.w	#$1d00,d5
	neg.w	d5
	bra	l00fe
l00f0	cmp.b	#$c,d4
	bne.s	l00f2
	move.w	d5,d4
	andi.w	#$f,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	bmi.s	l00f1
	addi.w	#$1800,d5
	bra	l00fe
l00f1	subi.w	#$1900,d5
	neg.w	d5
	bra	l00fe
l00f2	cmp.b	#$f,d4
	bne.s	l00f3
	addi.w	#$9000,d5
	bra	l00fe
l00f3	cmp.b	#$11,d4
	bne.s	l00f4
	andi.b	#$f,d5
	addi.b	#$70,d5
	lsl.w	#8,d5
	bra	l00fe
l00f4	cmp.b	#$12,d4
	bne.s	l00f5
	addi.w	#$700,d5
	bra	l00fe
l00f5	cmp.b	#$13,d4
	bne.s	l00fd
	move.b	d5,d4
	andi.b	#$f,d5
	lsl.b	#4,d4
	cmp.b	#2,d4
	bne.s	l00f7
	cmp.b	#7,d5
	bgt.s	l00f6
	lsl.b	#4,d5
	addi.w	#$800,d5
	bra.s	l00fe
l00f6	subi.b	#$10,d5
	neg.b	d5
	addi.w	#$800,d5
l00f7	cmp.b	#3,d4
	bne.s	l00f8
	addi.w	#$c00,d5
	bra.s	l00fe
l00f8	cmp.b	#4,d4
	bne.s	l00f9
	addi.w	#$e00,d5
	bra.s	l00fe
l00f9	cmp.b	#8,d4
	bne.s	l00fa
	addi.b	#$40,d5
	lsl.w	#8,d5
	bra.s	l00fe
l00fa	cmp.b	#$c,d4
	bne.s	l00fb
	addi.w	#$a00,d5
	bra.s	l00fe
l00fb	cmp.b	#$d,d4
	bne.s	l00fc
	addi.w	#$900,d5
	bra.s	l00fe
l00fc	cmp.b	#$e,d4
	bne.s	l00fd
	addi.w	#$a900,d5
	bra.s	l00fe
l00fd	cmp.b	#$14,d4
	bne.s	l00ff
	addi.w	#$f00,d5
l00fe	move.w	d5,2(a3)
l00ff	bra	cv_s3m2gtk_loop1
cv_s3m2gtk_finli	adda.w	d0,a1
	dbf	d3,cv_s3m2gtk_loop1
	movem.l	(a7)+,a0-a3/d0-d5
	rts

teste_icones	movem.l	a0/d3-d4/d1,-(a7)
	mulu	#$c0,d0
	adda.l	d0,a0
	lsr.w	#3,d1
	moveq	#$1f,d0
l0102	move.w	(a0)+,d3
	bmi.s	l0103
	cmp.w	d3,d1
	blt.s	l0103
	move.w	(a0),d4
	cmp.w	d4,d2
	blt.s	l0103
	addi.w	#9,d4
	cmp.w	d4,d2
	bgt.s	l0103
	add.w	2(a0),d3
	cmp.w	d3,d1
	ble.s	l0104
l0103	addq.l	#4,a0
	dbf	d0,l0102
	moveq	#$ff,d0
	movem.l	(a7)+,a0/d3-d4/d1
	rts

l0104	subi.w	#$1f,d0
	neg.w	d0
	movem.l	(a7)+,a0/d3-d4/d1
	rts

convert_mmd1_2_g	movem.l	a0-a2/d0-d6,-(a7)
	mulu	#5,d6
	subq.w	#1,d0
	subq.w	#1,d1
cv_mmd12gtk_loop	move.w	d0,d5
l0107	moveq	#0,d3
	move.b	1(a0),d3
	andi.b	#$3f,d3
	move.b	(a0),d4
	andi.b	#$7f,d4
	beq.s	l0108
	add.b	0(a2,d3.w),d4
l0108	move.b	d4,(a1)+
	move.b	d3,(a1)+
	addq.l	#2,a0
	move.b	(a0)+,d3
	moveq	#0,d4
	move.b	(a0)+,d4
	clr.w	d2
	cmp.b	#1,d3
	beq.s	l0109
	cmp.b	#2,d3
	beq.s	l0109
	cmp.b	#3,d3
	beq.s	l0109
	cmp.b	#4,d3
	beq.s	l0109
	cmp.b	#7,d3
	beq.s	l0109
	cmp.b	#$b,d3
	beq.s	l0109
	cmp.b	#$f,d3
	bne.s	l010a
	tst.b	d4
	beq	l011d
	cmp.w	#$f0,d4
	bgt	l0121
	cmp.w	#$20,d4
	blt	l0126
l0109	lsl.w	#8,d3
	add.w	d3,d4
	move.w	d4,d2
	bra	l0127
l010a	tst.b	d3
	bne.s	l010b
	tst.b	d4
	beq	l0127
	addi.w	#$1000,d4
	move.w	d4,d2
	bra	l0127
l010b	cmp.b	#5,d3
	bne.s	l010d
	move.w	d4,d3
	andi.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	l010c
	addi.w	#$1800,d4
	move.w	d4,d2
	bra	l0127
l010c	move.w	#$1900,d2
	sub.w	d4,d2
	bra	l0127
l010d	cmp.b	#6,d3
	bne.s	l010f
	move.w	d4,d3
	andi.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	l010e
	addi.w	#$1c00,d4
	move.w	d4,d2
	bra	l0127
l010e	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	l0127
l010f	cmp.b	#9,d3
	bne.s	l0110
	addi.w	#$a800,d4
	move.w	d4,d2
	bra	l0127
l0110	cmp.b	#$a,d3
	beq.s	l0111
	cmp.b	#$d,d3
	bne.s	l0113
l0111	move.w	d4,d3
	andi.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	l0112
	addi.w	#$1400,d4
	move.w	d4,d2
	bra	l0127
l0112	move.w	#$1500,d2
	sub.w	d4,d2
	bra	l0127
l0113	cmp.b	#$c,d3
	bne.s	l0114
	add.w	d4,d4
	add.w	d4,d4
	addi.w	#$2000,d4
	move.w	d4,d2
	bra	l0127
l0114	cmp.b	#$11,d3
	bne.s	l0115
	addi.w	#$1100,d4
	move.w	d4,d2
	bra	l0127
l0115	cmp.b	#$12,d3
	bne.s	l0116
	addi.w	#$1200,d4
	move.w	d4,d2
	bra	l0127
l0116	cmp.b	#$15,d3
	bne.s	l0118
	cmp.b	#7,d4
	bgt.s	l0117
	addi.w	#$800,d4
	move.w	d4,d2
	bra	l0127
l0117	move.w	#$810,d2
	sub.w	d4,d2
	bra	l0127
l0118	cmp.b	#$18,d3
	bne.s	l0119
	addi.w	#$a00,d4
	move.w	d4,d2
	bra	l0127
l0119	cmp.b	#$19,d3
	bne.s	l011a
	addi.w	#$9000,d4
	move.w	d4,d2
	bra	l0127
l011a	cmp.b	#$1a,d3
	bne.s	l011b
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	l0127
l011b	cmp.b	#$1b,d3
	bne.s	l011c
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra.s	l0127
l011c	cmp.b	#$1d,d3
	bne.s	l011e
l011d	addi.w	#$d00,d4
	move.w	d4,d2
	bra.s	l0127
l011e	cmp.b	#$1e,d3
	bne.s	l011f
	addi.w	#$aa00,d4
	move.w	d4,d2
	bra.s	l0127
l011f	cmp.b	#$1f,d3
	bne.s	l0126
	move.w	d4,d3
	andi.b	#$f,d3
	beq.s	l0120
	addi.b	#$70,d3
	lsl.w	#8,d3
	move.w	d3,d2
	bra.s	l0127
l0120	lsr.b	#4,d4
	addi.w	#$a00,d4
	move.w	d4,d2
	bra.s	l0127
l0121	cmp.b	#$f1,d4
	bne.s	l0122
	move.w	#$7302,d2
	bra.s	l0127
l0122	cmp.b	#$f2,d4
	bne.s	l0123
	move.w	#$903,d2
	bra.s	l0127
l0123	cmp.b	#$f3,d4
	bne.s	l0124
	move.w	#$7202,d2
	bra.s	l0127
l0124	cmp.b	#$fd,d4
	bne.s	l0125
	move.w	#$3ff,d2
	bra.s	l0127
l0125	cmp.b	#$ff,d4
	bne.s	l0127
	move.w	#$a00,d2
	bra.s	l0127
l0126	clr.w	d2
l0127	move.w	d2,(a1)+
	clr.b	(a1)+
	dbf	d5,l0107
	adda.w	d6,a1
	dbf	d1,cv_mmd12gtk_loop
	movem.l	(a7)+,a0-a2/d0-d6
	rts

stereo_2_mono_on	movem.l	a0-a1/d0-d1,-(a7)
	cmp.b	#2,d1
	beq.s	l012a
l0129	move.b	(a0),(a1)+
	addq.l	#2,a0
	subq.l	#1,d0
	bgt.s	l0129
	bra.s	l012b
l012a	move.w	(a0),(a1)+
	addq.l	#4,a0
	subq.l	#2,d0
	bgt.s	l012a
l012b	movem.l	(a7)+,a0-a1/d0-d1
	rts

stereo_2_mono_av	movem.l	a0-a1/d0-d2,-(a7)
	moveq	#0,d2
	cmp.b	#2,d1
	beq.s	l012e
	moveq	#0,d1
l012d	move.b	(a0)+,d1
	move.b	(a0)+,d2
	add.w	d1,d2
	lsr.w	#1,d2
	move.b	d2,(a1)+
	subq.l	#1,d0
	bgt.s	l012d
	bra.s	l0130
l012e	moveq	#0,d1
l012f	move.w	(a0)+,d1
	move.w	(a0)+,d2
	add.l	d1,d2
	lsr.l	#1,d2
	move.w	d2,(a1)+
	subq.l	#2,d0
	bgt.s	l012f
l0130	movem.l	(a7)+,a0-a1/d0-d2
	rts

signe_sample	movem.l	a0/d0-d2,-(a7)
	extb.l	d1
	moveq	#$80,d2
l0132	add.b	d2,(a0)
	adda.w	d1,a0
	sub.l	d1,d0
	bgt.s	l0132
	movem.l	(a7)+,a0/d0-d2
	rts

convert_nt_2_gtk	movem.l	a0-a3/d0-d4,-(a7)
	lea	nt_pernote(pc),a1
	lea	(0.b,a0,d0.l*4),a0
	lea	0(a0,d0.l),a3
cv_nt2gtk_loop	move.l	-(a0),d1
	moveq	#0,d2
	move.l	d1,d3
	andi.l	#$fff0000,d3
	beq.s	cv_nt2gtk_instr
	swap	d3
	moveq	#$24,d4
	movea.l	a1,a2
l0135	cmp.w	(a2)+,d3
	beq.s	l0136
	addq.w	#1,d4
	cmp.w	#$48,d4
	bne.s	l0135
	moveq	#0,d4
l0136	lsl.w	#8,d4
	swap	d4
	move.l	d4,d2
cv_nt2gtk_instr	move.l	d1,d3
	andi.l	#$f000f000,d3
	lsr.l	#8,d3
	swap	d3
	move.w	d3,d4
	swap	d3
	lsr.b	#4,d3
	add.w	d4,d3
	ext.l	d3
	swap	d3
	add.l	d3,d2
	moveq	#0,d3
	move.w	d1,d3
	lsr.w	#8,d3
	andi.b	#$f,d3
	move.w	d1,d4
	andi.w	#$ff,d4
	bsr	convert_profx_2_
	clr.b	-(a3)
	move.l	d2,-(a3)
	subq.l	#1,d0
	bne	cv_nt2gtk_loop
	movem.l	(a7)+,a0-a3/d0-d4
	rts

convert_669_2_gt	movem.l	a0-a2/d0-d3,-(a7)
	moveq	#$3f,d0
cv_6692gtk_loop1	movea.l	a1,a2
	clr.l	(a1)+
	clr.b	(a1)+
	moveq	#7,d1
cv_6692gtk_loop2	move.b	(a0),d2
	cmp.b	#$ff,d2
	beq.s	cv_6692gtk_fx
	cmp.b	#$fe,d2
	beq.s	cv_6692gtk_vol
	lsr.b	#2,d2
	cmp.b	#$3b,d2
	bgt.s	l013b
	addi.b	#$c,d2
l013b	addi.b	#$c,d2
	move.b	d2,(a1)
	move.w	(a0),d2
	lsr.w	#4,d2
	andi.b	#$3f,d2
	addq.b	#1,d2
	move.b	d2,1(a1)
cv_6692gtk_vol	move.w	#$2000,d2
	move.b	1(a0),d2
	lsl.b	#4,d2
	move.b	d2,4(a1)
	tst.b	d2
	bne.s	cv_6692gtk_fx
	move.w	d2,2(a1)
cv_6692gtk_fx	move.b	2(a0),d2
	cmp.b	#$ff,d2
	beq.s	cv_6692gtk_next
	move.b	d2,d3
	lsr.b	#4,d3
	andi.b	#$f,d2
	bne.s	l013e
	move.b	#1,2(a1)
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
l013e	subq.b	#1,d2
	bne.s	l013f
	move.b	#2,2(a1)
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
l013f	subq.b	#1,d2
	bne.s	l0140
	move.b	#3,2(a1)
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
l0140	subq.b	#1,d2
	bne.s	l0141
	move.b	#4,2(a1)
	lsl.b	#4,d3
	addi.b	#2,d3
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
l0141	subq.b	#1,d2
	bne.s	l0143
	move.b	#8,2(a1)
	cmp.b	#8,d3
	blt.s	l0142
	subi.b	#$10,d3
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
l0142	lsl.b	#4,d3
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
l0143	move.b	#$a8,2(a2)
	move.b	d3,3(a2)
cv_6692gtk_next	addq.l	#3,a0
	addq.l	#5,a1
	dbf	d1,cv_6692gtk_loop2
	dbf	d0,cv_6692gtk_loop1
	movem.l	(a7)+,a0-a2/d0-d3
	rts

convert_mtm_voic	movem.l	a0-a1/d0-d4,-(a7)
	mulu	#5,d0
	subq.w	#1,d1
cv_mtmv2gtk_loop	moveq	#0,d2
	move.w	d2,d4
	move.b	(a0),d2
	lsr.b	#2,d2
	tst.b	d2
	beq.s	l0148
	cmp.b	#$3b,d2
	bgt.s	l0147
	addi.b	#$c,d2
l0147	addi.b	#$c,d2
	lsl.w	#8,d2
l0148	move.w	(a0),d3
	lsr.w	#4,d3
	andi.b	#$3f,d3
	move.b	d3,d2
	swap	d2
	move.b	1(a0),d3
	andi.b	#$f,d3
	move.b	2(a0),d4
	bsr.s	convert_profx_2_
	move.l	d2,(a1)
	clr.b	4(a1)
	addq.l	#3,a0
	adda.w	d0,a1
	dbf	d1,cv_mtmv2gtk_loop
	movem.l	(a7)+,a0-a1/d0-d4
	rts

convert_profx_2_	cmp.b	#1,d3
	beq.s	l014a
	cmp.b	#2,d3
	beq.s	l014a
	cmp.b	#3,d3
	beq.s	l014a
	cmp.b	#4,d3
	beq.s	l014a
	cmp.b	#7,d3
	beq.s	l014a
	cmp.b	#$b,d3
	beq.s	l014a
	cmp.b	#$d,d3
	beq.s	l014a
	cmp.b	#$f,d3
	bne.s	l014b
l014a	move.w	d4,d2
	lsl.w	#8,d3
	add.w	d3,d2
	andi.w	#$fff,d2
	bra	l0162
l014b	tst.b	d3
	bne.s	l014c
	tst.b	d4
	beq	l0162
	addi.w	#$1000,d4
	move.w	d4,d2
	bra	l0162
l014c	cmp.b	#5,d3
	bne.s	l014e
	move.w	d4,d3
	andi.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	l014d
	addi.w	#$1800,d4
	move.w	d4,d2
	bra	l0162
l014d	move.w	#$1900,d2
	sub.w	d4,d2
	bra	l0162
l014e	cmp.b	#6,d3
	bne.s	l0150
	move.w	d4,d3
	andi.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	l014f
	addi.w	#$1c00,d4
	move.w	d4,d2
	bra	l0162
l014f	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	l0162
l0150	cmp.b	#8,d3
	bne.s	l0151
	addi.w	#$400,d3
	lsl.w	#4,d3
	move.w	d3,d2
	bra	l0162
l0151	cmp.b	#9,d3
	bne.s	l0152
	addi.w	#$9000,d4
	move.w	d4,d2
	bra	l0162
l0152	cmp.b	#$a,d3
	bne.s	l0154
	move.w	d4,d3
	andi.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	l0153
	addi.w	#$1400,d4
	move.w	d4,d2
	bra	l0162
l0153	move.w	#$1500,d2
	sub.w	d4,d2
	bra	l0162
l0154	cmp.b	#$c,d3
	bne.s	l0155
	add.w	d4,d4
	add.w	d4,d4
	addi.w	#$2000,d4
	move.w	d4,d2
	bra	l0162
l0155	cmp.b	#$e,d3
	bne	l0162
	move.w	d4,d3
	lsr.b	#4,d3
	andi.b	#$f,d4
	cmp.b	#1,d3
	bne.s	l0156
	addi.w	#$1100,d4
	move.w	d4,d2
	bra	l0162
l0156	cmp.b	#2,d3
	bne.s	l0157
	addi.w	#$1200,d4
	move.w	d4,d2
	bra	l0162
l0157	cmp.b	#4,d3
	bne.s	l0158
	addi.w	#$c00,d4
	move.w	d4,d2
	bra	l0162
l0158	cmp.b	#5,d3
	bne.s	l015a
	cmp.b	#7,d4
	bgt.s	l0159
	addi.w	#$800,d4
	move.w	d4,d2
	bra.s	l0162
l0159	move.w	#$810,d2
	sub.w	d4,d2
	bra.s	l0162
l015a	cmp.b	#7,d3
	bne.s	l015b
	addi.w	#$e00,d4
	move.w	d4,d2
	bra.s	l0162
l015b	cmp.b	#9,d3
	bne.s	l015c
	lsl.w	#8,d4
	addi.w	#$7000,d4
	move.w	d4,d2
	bra.s	l0162
l015c	cmp.b	#$a,d3
	bne.s	l015d
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra.s	l0162
l015d	cmp.b	#$b,d3
	bne.s	l015e
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra.s	l0162
l015e	cmp.b	#$c,d3
	bne.s	l015f
	addi.w	#$a00,d4
	move.w	d4,d2
	bra.s	l0162
l015f	cmp.b	#$d,d3
	bne.s	l0160
	addi.w	#$a00,d4
	move.w	d4,d2
	bra.s	l0162
l0160	cmp.b	#$e,d3
	bne.s	l0161
	addi.w	#$aa00,d4
	move.w	d4,d2
	bra.s	l0162
l0161	clr.w	d2
l0162	rts

affiche_sample	movem.l	a0-a6/d7/d0-d4,-(a7)
	cmp.b	#2,d1
	bne.s	l0164
	lsr.l	#1,d0
	lsr.l	#1,d5
	lsr.l	#1,d6
l0164	move.l	d5,-(a7)
	move.l	d6,-(a7)
	movea.l	adrecr(pc),a1
	mulu	linewidth(pc),d2
	addq.l	#8,d2
	adda.l	d2,a1
	move.w	d4,d2
	lsr.w	#1,d2
	mulu	linewidth(pc),d2
	lea	0(a1,d2.l),a3
	moveq	#0,d2
	move.w	d3,d2
	lsl.w	#4,d2
	subq.w	#1,d2
	moveq	#0,d7
	move.l	d0,d5
	divu.l	d2,d7	d5
	moveq	#0,d6
	divu.l	d2,d7	d6
	moveq	#0,d2
	subq.l	#1,d6
	subx.l	d2,d5
	cmp.b	#2,d1
	beq.s	aff_sam_16bits
	subq.w	#1,d3
	moveq	#0,d0
	moveq	#0,d7
aff_sam_loop1	move.w	d3,-(a7)
	movea.l	a1,a2
	move.w	d4,d2
	subq.w	#1,d2
aff_sam_loop1_1	clr.l	(a2)
	clr.l	4(a2)
	adda.w	linewidth(pc),a2
	dbf	d2,aff_sam_loop1_1
	move.w	#$8000,d2
	moveq	#$f,d1
aff_sam_loop1_2	movea.l	a3,a2
	move.b	0(a0,d0.l),d3
	ext.w	d3
	muls	d4,d3
	asr.l	#8,d3
	tst.w	d3
	bpl.s	aff_sam_positif
	neg.w	d3
l0168	or.w	d2,(a2)
	or.w	d2,6(a2)
	suba.w	linewidth(pc),a2
	dbf	d3,l0168
	bra.s	aff_sam_finsi
aff_sam_positif	or.w	d2,(a2)
	or.w	d2,6(a2)
	adda.w	linewidth(pc),a2
	dbf	d3,aff_sam_positif
aff_sam_finsi	add.l	d6,d7
	addx.l	d5,d0
	lsr.w	#1,d2
	dbf	d1,aff_sam_loop1_2
	addq.l	#8,a1
	addq.l	#8,a3
	move.w	(a7)+,d3
	dbf	d3,aff_sam_loop1
	move.l	(a7)+,d6
	move.l	(a7)+,d5
	movem.l	(a7)+,a0-a6/d7/d0-d4
	rts

aff_sam_16bits	subq.w	#1,d3
	moveq	#0,d0
	moveq	#0,d7
	move.w	d3,-(a7)
	movea.l	a1,a2
	move.w	d4,d2
	subq.w	#1,d2
aff_sam16_loop1_	clr.l	(a2)
	clr.l	4(a2)
	adda.w	linewidth(pc),a2
	dbf	d2,aff_sam16_loop1_
	move.w	#$8000,d2
	moveq	#$f,d1
l016d	movea.l	a3,a2
	move.b	(0.b,a0,d0.l*2),d3
	ext.w	d3
	muls	d4,d3
	asr.l	#8,d3
	tst.w	d3
	bpl.s	aff_sam_positif
	neg.w	d3
l016e	or.w	d2,(a2)
	or.w	d2,6(a2)
	suba.w	linewidth(pc),a2
	dbf	d3,l016e
	bra.s	aff_sam_finsi
aff_sam16_positi	or.w	d2,(a2)
	or.w	d2,6(a2)
	adda.w	linewidth(pc),a2
	dbf	d3,aff_sam16_positi
	add.l	d6,d7
	addx.l	d5,d0
	lsr.w	#1,d2
	dbf	d1,l016d
	addq.l	#8,a1
	addq.l	#8,a3
	move.w	(a7)+,d3
	dbf	d3,aff_sam_loop1
	move.l	(a7)+,d6
	move.l	(a7)+,d5
	movem.l	(a7)+,a0-a6/d7/d0-d4
	rts

affiche_pattern	movem.l	a0-a6/d0-d7,-(a7)
	movea.l	a0,a6
	move.w	6(a6),d2
	move.w	d2,d3
	lsr.w	#1,d2
	move.w	d2,d6
	sub.w	d2,d0
	move.w	d0,d2
	add.w	d0,d0
	add.w	d0,d0
	add.w	d2,d0
	muls	(a6),d0
	adda.l	d0,a1
	subq.w	#1,d3
aff_pat_loop_y	lea	1(a2),a0
	move.l	a2,-(a7)
	tst.w	d2
	bmi	aff_pat_blanc
	cmp.w	2(a6),d2
	bge	aff_pat_blanc
	lea	table_byte2char(pc),a2
	move.b	(0.b,a2,d2.w*2),d1
	moveq	#9,d0
	cmp.w	d6,d3
	bne.s	l0172
	moveq	#8,d0
l0172	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(1.b,a2,d2.w*2),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0
	lea	nom_notes(pc),a4
	moveq	#0,d4
affploop_x	lea	patligcol(pc),a3
	movea.l	a1,a5
	moveq	#0,d7
	move.w	(8.b,a6,d4.w*2),d0
	adda.w	d0,a5
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a5
	tst.b	(a5)
	beq.s	l0174
	move.b	(a5),d7
	subi.w	#$18,d7
	move.l	(0.b,a4,d7.w*4),(a3)+
	bra.s	l0175
l0174	move.l	#$2d2d2d20,(a3)+
l0175	addq.l	#1,a5
	subq.l	#1,a3
	moveq	#0,d1
	move.b	(a5)+,d1
	cmp.w	#$f,d1
	bgt.s	l0176
	subi.w	#$10,d1
l0176	move.w	(0.b,a2,d1.w*2),(a3)+
	tst.w	72(a6)
	bne.s	l0177
	subq.l	#5,a3
	moveq	#9,d0
	cmp.w	d6,d3
	bne	l017f
	moveq	#8,d0
	bra	l017c
l0177	moveq	#0,d1
	move.b	(a5)+,d1
	move.w	(0.b,a2,d1.w*2),(a3)+
	move.b	(a5)+,d1
	move.w	(0.b,a2,d1.w*2),(a3)+
	subq.l	#1,a3
	subq.l	#8,a3
	cmpi.w	#2,72(a6)
	beq.s	l0178
	moveq	#9,d0
	cmp.w	d6,d3
	bne	l017e
	moveq	#8,d0
	bra.s	l017b
l0178	move.w	#$2020,9(a3)
	tst.b	(a5)
	beq.s	l017a
	moveq	#0,d1
	move.b	(a5)+,d1
	cmp.w	#$f,d1
	bgt.s	l0179
	subi.w	#$10,d1
l0179	move.w	(0.b,a2,d1.w*2),9(a3)
l017a	moveq	#9,d0
	cmp.w	d6,d3
	bne.s	l017d
	moveq	#8,d0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
l017b	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
l017c	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	move.b	(a3),d1
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0
	bra.s	l0180
l017d	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
l017e	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
l017f	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a3)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a3),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0
l0180	addq.w	#1,d4
	cmp.w	4(a6),d4
	blt	affploop_x
	bra.s	aff_pat_suite_y
aff_pat_blanc	moveq	#$20,d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0
	move.w	4(a6),d4
	subi.w	#1,d4
affpblancloop_x	cmpi.w	#2,72(a6)
	bne.s	l0183
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
l0183	tst.w	72(a6)
	beq.s	l0184
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
l0184	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0
	dbf	d4,affpblancloop_x
aff_pat_suite_y	movea.l	(a7)+,a2
	addq.w	#1,d2
	move.w	linewidth(pc),d4
	add.w	d4,d4
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d4
	adda.w	d4,a2
	move.w	(a6),d4
	adda.w	d4,a1
	add.w	d4,d4
	add.w	d4,d4
	adda.w	d4,a1
	dbf	d3,aff_pat_loop_y
	movem.l	(a7)+,a0-a6/d0-d7
	bsr	affiche_curseur
	rts

affiche_curseur	movem.l	a2/a0/d0-d3,-(a7)
	move.w	6(a0),d0
	andi.b	#$fe,d0
	move.w	d0,d3
	add.w	d0,d0
	add.w	d3,d0
	mulu	linewidth(pc),d0
	adda.l	d0,a2
	lsl.w	#3,d1
	move.w	d1,d3
	add.w	d1,d1
	tst.w	72(a0)
	beq.s	l0187
	add.w	d1,d1
	cmpi.w	#2,72(a0)
	bne.s	l0187
	add.w	d3,d1
l0187	add.w	d3,d1
	adda.w	d1,a2
	lea	curs_x_table(pc),a0
	adda.w	(0.b,a0,d2.w*2),a2
	moveq	#$ff,d0
	move.w	linewidth(pc),d1
	move.b	d0,(a2)
	adda.w	d1,a2
	move.b	d0,(a2)
	adda.w	d1,a2
	move.b	d0,(a2)
	adda.w	d1,a2
	move.b	d0,(a2)
	adda.w	d1,a2
	move.b	d0,(a2)
	adda.w	d1,a2
	move.b	d0,(a2)
	movem.l	(a7)+,a2/a0/d0-d3
	rts

cadre_centre	movem.l	d0-d3,-(a7)
	move.w	#9,6(a0)
	move.w	d0,4(a0)
	bsr	dessine_cadre_in
	add.w	0(a0),d0
	add.w	0(a0),d0
	movea.l	a1,a2
	addq.w	#2,d0
l0189	subq.w	#1,d0
	tst.b	(a2)+
	bne.s	l0189
	move.w	d0,d2
	move.w	2(a0),d3
	addq.w	#2,d3
	move.b	11(a0),d0
	move.b	10(a0),d1
	bsr	affchaine_trans_
	movem.l	(a7)+,d0-d3
	rts

dessine_cadre_in	movem.l	a0-a3/d0-d7,-(a7)
	movea.l	adrecr(pc),a1
	move.w	2(a0),d0
	muls	linewidth(pc),d0
	adda.l	d0,a1
	move.w	4(a0),d6
	move.w	6(a0),d7
	move.w	0(a0),d0
	bclr	#0,d0
	lsl.w	#2,d0
	adda.w	d0,a1
	move.b	8(a0),d0
	lsr.w	#1,d0
	scs	d2
	lsr.w	#1,d0
	scs	d3
	lsr.w	#1,d0
	scs	d4
	lsr.w	#1,d0
	scs	d5
	move.w	linewidth(pc),d1
	subq.w	#6,d1
	movea.l	a1,a3
	btst	#0,1(a0)
	beq.s	descadr_paire
	addq.l	#1,a1
	movea.l	a1,a3
descadr_impaire	movea.l	a3,a2
	move.w	d7,d0
descadr_imploop	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	adda.w	d1,a2
	dbf	d0,descadr_imploop
	subq.w	#1,d6
	bmi.s	descadr_fondfin
	addq.l	#7,a3
descadr_paire	movea.l	a3,a2
	move.w	d7,d0
descadr_ploop	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	adda.w	d1,a2
	dbf	d0,descadr_ploop
	addq.l	#1,a3
	dbf	d6,descadr_impaire
descadr_fondfin	move.b	10(a0),d0
	lsr.w	#1,d0
	scs	d2
	lsr.w	#1,d0
	scs	d3
	lsr.w	#1,d0
	scs	d4
	lsr.w	#1,d0
	scs	d5
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	move.b	11(a0),d0
	lsr.w	#1,d0
	scs	d2
	lsr.w	#1,d0
	scs	d3
	lsr.w	#1,d0
	scs	d4
	lsr.w	#1,d0
	scs	d5
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	movea.l	a1,a2
	move.w	4(a0),d6
	btst	#0,1(a0)
	beq.s	descadr_paire2
descadr_impaire2	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	descadr_bordhfin
descadr_paire2	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	subq.l	#5,a2
	dbf	d6,descadr_impaire2
	addq.l	#6,a2
descadr_bordhfin	lea	-7(a2),a3
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	movea.l	a1,a2
	move.w	6(a0),d0
	muls	linewidth(pc),d0
	adda.l	d0,a2
	move.w	4(a0),d6
	btst	#0,1(a0)
	beq.s	descadr_paire3
descadr_impaire3	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	l0195
descadr_paire3	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	subq.l	#5,a2
	dbf	d6,descadr_impaire3
l0195	movea.l	a3,a2
	moveq	#$fe,d0
	moveq	#1,d1
	move.w	linewidth(pc),d6
	subq.w	#6,d6
	move.w	6(a0),d7
descadr_borddloo	tst.b	d2
	beq.s	l0197
	or.b	d1,(a2)
	bra.s	l0198
l0197	and.b	d0,(a2)
l0198	addq.l	#2,a2
	tst.b	d3
	beq.s	l0199
	or.b	d1,(a2)
	bra.s	l019a
l0199	and.b	d0,(a2)
l019a	addq.l	#2,a2
	tst.b	d4
	beq.s	l019b
	or.b	d1,(a2)
	bra.s	l019c
l019b	and.b	d0,(a2)
l019c	addq.l	#2,a2
	tst.b	d5
	beq.s	l019d
	or.b	d1,(a2)
	bra.s	l019e
l019d	and.b	d0,(a2)
l019e	adda.w	d6,a2
	dbf	d7,descadr_borddloo
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	movea.l	a1,a2
	moveq	#$7f,d0
	moveq	#$80,d1
	move.w	6(a0),d7
descadr_bordgloo	tst.b	d2
	beq.s	l01a0
	or.b	d1,(a2)
	bra.s	l01a1
l01a0	and.b	d0,(a2)
l01a1	addq.l	#2,a2
	tst.b	d3
	beq.s	l01a2
	or.b	d1,(a2)
	bra.s	l01a3
l01a2	and.b	d0,(a2)
l01a3	addq.l	#2,a2
	tst.b	d4
	beq.s	l01a4
	or.b	d1,(a2)
	bra.s	l01a5
l01a4	and.b	d0,(a2)
l01a5	addq.l	#2,a2
	tst.b	d5
	beq.s	l01a6
	or.b	d1,(a2)
	bra.s	l01a7
l01a6	and.b	d0,(a2)
l01a7	adda.w	d6,a2
	dbf	d7,descadr_bordgloo
	suba.w	linewidth(pc),a2
	move.b	9(a0),d6
	lsr.w	#1,d6
	scs	d2
	lsr.w	#1,d6
	scs	d3
	lsr.w	#1,d6
	scs	d4
	lsr.w	#1,d6
	scs	d5
	tst.b	d2
	beq.s	l01a8
	or.b	d1,(a2)
	bra.s	l01a9
l01a8	and.b	d0,(a2)
l01a9	addq.l	#2,a2
	tst.b	d3
	beq.s	l01aa
	or.b	d1,(a2)
	bra.s	l01ab
l01aa	and.b	d0,(a2)
l01ab	addq.l	#2,a2
	tst.b	d4
	beq.s	l01ac
	or.b	d1,(a2)
	bra.s	l01ad
l01ac	and.b	d0,(a2)
l01ad	addq.l	#2,a2
	tst.b	d5
	beq.s	l01ae
	or.b	d1,(a2)
	bra.s	l01af
l01ae	and.b	d0,(a2)
l01af	movea.l	a3,a2
	moveq	#$fe,d0
	moveq	#1,d1
	tst.b	d2
	beq.s	l01b0
	or.b	d1,(a2)
	bra.s	l01b1
l01b0	and.b	d0,(a2)
l01b1	addq.l	#2,a2
	tst.b	d3
	beq.s	l01b2
	or.b	d1,(a2)
	bra.s	l01b3
l01b2	and.b	d0,(a2)
l01b3	addq.l	#2,a2
	tst.b	d4
	beq.s	l01b4
	or.b	d1,(a2)
	bra.s	l01b5
l01b4	and.b	d0,(a2)
l01b5	addq.l	#2,a2
	tst.b	d5
	beq.s	l01b6
	or.b	d1,(a2)
	bra.s	l01b7
l01b6	and.b	d0,(a2)
l01b7	movem.l	(a7)+,a0-a3/d0-d7
	rts

dessine_cadre_ex	movem.l	a0-a3/d0-d7,-(a7)
	movea.l	adrecr(pc),a1
	move.w	2(a0),d0
	muls	linewidth(pc),d0
	adda.l	d0,a1
	move.w	4(a0),d6
	move.w	6(a0),d7
	move.w	0(a0),d0
	bclr	#0,d0
	lsl.w	#2,d0
	adda.w	d0,a1
	move.b	8(a0),d0
	lsr.w	#1,d0
	scs	d2
	lsr.w	#1,d0
	scs	d3
	lsr.w	#1,d0
	scs	d4
	lsr.w	#1,d0
	scs	d5
	move.w	linewidth(pc),d1
	subq.w	#6,d1
	movea.l	a1,a3
	btst	#0,1(a0)
	beq.s	descadrext_paire
	addq.l	#1,a1
	movea.l	a1,a3
descadrext_impai	movea.l	a3,a2
	move.w	d7,d0
descadrext_implo	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	adda.w	d1,a2
	dbf	d0,descadrext_implo
	subq.w	#1,d6
	bmi.s	descadrext_fondf
	addq.l	#7,a3
descadrext_paire	movea.l	a3,a2
	move.w	d7,d0
descadrext_ploop	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	adda.w	d1,a2
	dbf	d0,descadrext_ploop
	addq.l	#1,a3
	dbf	d6,descadrext_impai
descadrext_fondf	move.b	10(a0),d0
	lsr.w	#1,d0
	scs	d2
	lsr.w	#1,d0
	scs	d3
	lsr.w	#1,d0
	scs	d4
	lsr.w	#1,d0
	scs	d5
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	move.b	11(a0),d0
	lsr.w	#1,d0
	scs	d2
	lsr.w	#1,d0
	scs	d3
	lsr.w	#1,d0
	scs	d4
	lsr.w	#1,d0
	scs	d5
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	movea.l	a1,a2
	suba.w	linewidth(pc),a2
	move.w	4(a0),d6
	btst	#0,1(a0)
	beq.s	l01bf
l01be	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	descadrext_bordh
l01bf	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	subq.l	#5,a2
	dbf	d6,l01be
descadrext_bordh	movea.l	a2,a3
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	movea.l	a1,a2
	move.w	6(a0),d0
	addq.w	#1,d0
	muls	linewidth(pc),d0
	adda.l	d0,a2
	move.w	4(a0),d6
	btst	#0,1(a0)
	beq.s	l01c2
l01c1	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	l01c3
l01c2	move.b	d2,(a2)
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	subq.l	#5,a2
	dbf	d6,l01c1
l01c3	movea.l	a3,a2
	moveq	#$7f,d0
	moveq	#$80,d1
	move.w	linewidth(pc),d6
	subq.w	#6,d6
	move.w	6(a0),d7
descadrext_bordd	tst.b	d2
	beq.s	l01c5
	or.b	d1,(a2)
	bra.s	l01c6
l01c5	and.b	d0,(a2)
l01c6	addq.l	#2,a2
	tst.b	d3
	beq.s	l01c7
	or.b	d1,(a2)
	bra.s	l01c8
l01c7	and.b	d0,(a2)
l01c8	addq.l	#2,a2
	tst.b	d4
	beq.s	l01c9
	or.b	d1,(a2)
	bra.s	l01ca
l01c9	and.b	d0,(a2)
l01ca	addq.l	#2,a2
	tst.b	d5
	beq.s	l01cb
	or.b	d1,(a2)
	bra.s	l01cc
l01cb	and.b	d0,(a2)
l01cc	adda.w	d6,a2
	dbf	d7,descadrext_bordd
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	movea.l	a1,a2
	btst	#0,1(a0)
	beq.s	l01cd
	addq.l	#6,a2
l01cd	subq.l	#7,a2
	moveq	#$fe,d0
	moveq	#1,d1
	move.w	6(a0),d7
descadrext_bordg	tst.b	d2
	beq.s	l01cf
	or.b	d1,(a2)
	bra.s	l01d0
l01cf	and.b	d0,(a2)
l01d0	addq.l	#2,a2
	tst.b	d3
	beq.s	l01d1
	or.b	d1,(a2)
	bra.s	l01d2
l01d1	and.b	d0,(a2)
l01d2	addq.l	#2,a2
	tst.b	d4
	beq.s	l01d3
	or.b	d1,(a2)
	bra.s	l01d4
l01d3	and.b	d0,(a2)
l01d4	addq.l	#2,a2
	tst.b	d5
	beq.s	l01d5
	or.b	d1,(a2)
	bra.s	l01d6
l01d5	and.b	d0,(a2)
l01d6	adda.w	d6,a2
	dbf	d7,descadrext_bordg
	suba.w	linewidth(pc),a2
	move.b	9(a0),d6
	lsr.w	#1,d6
	scs	d2
	lsr.w	#1,d6
	scs	d3
	lsr.w	#1,d6
	scs	d4
	lsr.w	#1,d6
	scs	d5
	tst.b	d2
	beq.s	l01d7
	or.b	d1,(a2)
	bra.s	l01d8
l01d7	and.b	d0,(a2)
l01d8	addq.l	#2,a2
	tst.b	d3
	beq.s	l01d9
	or.b	d1,(a2)
	bra.s	l01da
l01d9	and.b	d0,(a2)
l01da	addq.l	#2,a2
	tst.b	d4
	beq.s	l01db
	or.b	d1,(a2)
	bra.s	l01dc
l01db	and.b	d0,(a2)
l01dc	addq.l	#2,a2
	tst.b	d5
	beq.s	l01dd
	or.b	d1,(a2)
	bra.s	l01de
l01dd	and.b	d0,(a2)
l01de	movea.l	a3,a2
	moveq	#$7f,d0
	moveq	#$80,d1
	tst.b	d2
	beq.s	l01df
	or.b	d1,(a2)
	bra.s	l01e0
l01df	and.b	d0,(a2)
l01e0	addq.l	#2,a2
	tst.b	d3
	beq.s	l01e1
	or.b	d1,(a2)
	bra.s	l01e2
l01e1	and.b	d0,(a2)
l01e2	addq.l	#2,a2
	tst.b	d4
	beq.s	l01e3
	or.b	d1,(a2)
	bra.s	l01e4
l01e3	and.b	d0,(a2)
l01e4	addq.l	#2,a2
	tst.b	d5
	beq.s	l01e5
	or.b	d1,(a2)
	bra.s	l01e6
l01e5	and.b	d0,(a2)
l01e6	movem.l	(a7)+,a0-a3/d0-d7
	rts

affchaine_trans	movem.l	a0/d0-d3,-(a7)
	movea.l	adrecr(pc),a0
	muls	linewidth(pc),d3
	adda.l	d3,a0
	moveq	#0,d1
	lsl.w	#1,d2
	bclr	#2,d2
	bne.s	l01ed
	bclr	#1,d2
	bne.s	l01ea
	adda.w	d2,a0
l01e8	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6
	addq.l	#1,a0
l01e9	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6
	addq.l	#7,a0
	bra.s	l01e8
l01ea	adda.w	d2,a0
l01eb	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6_dec
	addq.l	#1,a0
l01ec	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6_dec
	addq.l	#7,a0
	bra.s	l01eb
l01ed	bclr	#1,d2
	bne.s	l01ee
	adda.w	d2,a0
	addq.l	#1,a0
	bra.s	l01e9
l01ee	adda.w	d2,a0
	addq.l	#1,a0
	bra.s	l01ec
affchaine1_fin	movem.l	(a7)+,a0/d0-d3
	rts

affchaine_trans_	move.w	d0,-(a7)
	move.l	a2,-(a7)
	movea.l	a1,a2
	movem.l	a0/d0-d3,-(a7)
	movea.l	adrecr(pc),a0
	muls	linewidth(pc),d3
	adda.l	d3,a0
	moveq	#0,d1
	lsl.w	#1,d2
	bclr	#2,d2
	bne.s	l01f6
	bclr	#1,d2
	bne.s	l01f3
	adda.w	d2,a0
l01f1	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr
	addq.l	#1,a0
l01f2	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr
	addq.l	#7,a0
	bra.s	l01f1
l01f3	adda.w	d2,a0
l01f4	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr_d
	addq.l	#1,a0
l01f5	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr_d
	addq.l	#7,a0
	bra.s	l01f4
l01f6	bclr	#1,d2
	bne.s	l01f7
	adda.w	d2,a0
	addq.l	#1,a0
	bra.s	l01f2
l01f7	adda.w	d2,a0
	addq.l	#1,a0
	bra.s	l01f5
affchaine2_fin	movem.l	(a7)+,a0/d0-d3
	movea.l	a2,a1
	move.w	d1,d0
	bsr	affchaine_trans
	movea.l	(a7)+,a2
	move.w	(a7)+,d0
	rts

affchaine_notran	movem.l	a0/d0-d3,-(a7)
	movea.l	adrecr(pc),a0
	muls	linewidth(pc),d3
	adda.l	d3,a0
	moveq	#0,d1
	lsl.w	#2,d2
	bclr	#2,d2
	bne.s	l01fc
	adda.w	d2,a0
l01fa	move.b	(a1)+,d1
	beq.s	affchaine3_fin
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
l01fb	move.b	(a1)+,d1
	beq.s	affchaine3_fin
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bra.s	l01fa
l01fc	adda.w	d2,a0
	addq.l	#1,a0
	bra.s	l01fb
affchaine3_fin	movem.l	(a7)+,a0/d0-d3
	rts

	movem.l	a0/d0-d3,-(a7)
	movea.l	adrecr(pc),a0
	muls	linewidth(pc),d3
	adda.l	d3,a0
	moveq	#0,d1
	lsl.w	#2,d2
	bclr	#2,d2
	bne.s	l0200
	adda.w	d2,a0
l01fe	move.b	(a1)+,d1
	beq.s	affchaine4_fin
	bsr	affcar8x6_plan
	addq.l	#1,a0
l01ff	move.b	(a1)+,d1
	beq.s	affchaine4_fin
	bsr	affcar8x6_plan
	addq.l	#7,a0
	bra.s	l01fe
l0200	adda.w	d2,a0
	addq.l	#1,a0
	bra.s	l01ff
affchaine4_fin	movem.l	(a7)+,a0/d0-d3
	rts

affcar8x6	movem.l	a0-a1/d0-d5,-(a7)
	lea	fonte8x6(pc),a1
	move.w	linewidth(pc),d3
affcar1_bra	subq.w	#6,d3
	add.w	d1,d1
	adda.w	d1,a1
	add.w	d1,d1
	adda.w	d1,a1
	moveq	#5,d1
affcar1_loop	move.w	d0,d2
	move.b	(a1)+,d4
	move.w	d4,d5
	not.w	d5
	and.b	d5,(a0)
	lsr.w	#1,d2
	bcc.s	affcar1_suitea
	or.b	d4,(a0)
affcar1_suitea	addq.l	#2,a0
	and.b	d5,(a0)
	lsr.w	#1,d2
	bcc.s	affcar1_suiteb
	or.b	d4,(a0)
affcar1_suiteb	addq.l	#2,a0
	and.b	d5,(a0)
	lsr.w	#1,d2
	bcc.s	affcar1_suitec
	or.b	d4,(a0)
affcar1_suitec	addq.l	#2,a0
	and.b	d5,(a0)
	lsr.w	#1,d2
	bcc.s	affcar1_suited
	or.b	d4,(a0)
affcar1_suited	adda.w	d3,a0
	dbf	d1,affcar1_loop
	movem.l	(a7)+,a0-a1/d0-d5
	rts

affcar8x6_dec	movem.l	a0-a2/d0-d7,-(a7)
	lea	fonte8x6(pc),a1
	move.w	linewidth(pc),d3
affcar2_bra	subq.w	#6,d3
	add.w	d1,d1
	adda.w	d1,a1
	add.w	d1,d1
	adda.w	d1,a1
	lea	1(a0),a2
	move.w	a0,d1
	btst	#0,d1
	beq.s	affcar2_suite2
	addq.l	#6,a2
affcar2_suite2	moveq	#5,d1
affcar2_loop	move.w	d0,d2
	move.b	(a1)+,d4
	move.w	d4,d6
	lsr.b	#4,d4
	lsl.b	#4,d6
	move.w	d4,d5
	move.w	d6,d7
	not.w	d5
	not.w	d7
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	#1,d2
	bcc.s	affcar2_suitea
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suitea	addq.l	#2,a0
	addq.l	#2,a2
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	#1,d2
	bcc.s	affcar2_suiteb
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suiteb	addq.l	#2,a0
	addq.l	#2,a2
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	#1,d2
	bcc.s	affcar2_suitec
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suitec	addq.l	#2,a0
	addq.l	#2,a2
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	#1,d2
	bcc.s	affcar2_suited
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suited	adda.w	d3,a0
	adda.w	d3,a2
	dbf	d1,affcar2_loop
	movem.l	(a7)+,a0-a2/d0-d7
	rts

affcar8x6_ombr	movem.l	a0-a1/d0-d5,-(a7)
	move.w	linewidth(pc),d3
	adda.w	d3,a0
	lea	fonte8x6_ombr(pc),a1
	bra	affcar1_bra
affcar8x6_ombr_d	movem.l	a0-a2/d0-d7,-(a7)
	move.w	linewidth(pc),d3
	adda.w	d3,a0
	lea	fonte8x6_ombr(pc),a1
	bra	affcar2_bra
affcar8x6nt_ombr	movem.l	a0-a2/d0-d2,-(a7)
	move.w	linewidth(pc),d2
	lea	fonte8x6_ombr(pc),a1
	andi.w	#$ff,d1
	add.w	d1,d1
	adda.w	d1,a1
	add.w	d1,d1
	adda.w	d1,a1
	move.w	#3,d1
affcar5_loop	movea.l	a0,a2
	lsr.w	#1,d0
	bcc.s	l0215
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1),(a2)
	subq.l	#5,a1
	bra.s	l0216
l0215	clr.b	(a2)
	adda.w	d2,a2
	clr.b	(a2)
	adda.w	d2,a2
	clr.b	(a2)
	adda.w	d2,a2
	clr.b	(a2)
	adda.w	d2,a2
	clr.b	(a2)
	adda.w	d2,a2
	clr.b	(a2)
l0216	addq.l	#2,a0
	dbf	d1,affcar5_loop
	movem.l	(a7)+,a0-a2/d0-d2
	rts

affcar8x6_plan	movem.l	a0-a2/d0-d2,-(a7)
	move.w	linewidth(pc),d2
	lea	fonte8x6_ombr(pc),a1
	andi.w	#$ff,d1
	add.w	d1,d1
	adda.w	d1,a1
	add.w	d1,d1
	adda.w	d1,a1
	move.w	#3,d1
affcar6_loop	lsr.w	#1,d0
	bcc.s	l0219
	movea.l	a0,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1)+,(a2)
	adda.w	d2,a2
	move.b	(a1),(a2)
	subq.l	#5,a1
l0219	addq.l	#2,a0
	dbf	d1,affcar6_loop
	movem.l	(a7)+,a0-a2/d0-d2
	rts

fabrique_fonte_o	movem.l	a1-a2/d1-d2,-(a7)
	lea	fonte8x6(pc),a2
	lea	fonte8x6_ombr(pc),a1
	move.w	#$80,d2
fabrfnt_loop	move.b	(a2)+,d1
	lsr.b	#1,d1
	move.b	d1,(a1)+
	move.b	(a2)+,d1
	lsr.b	#1,d1
	move.b	d1,(a1)+
	move.b	(a2)+,d1
	lsr.b	#1,d1
	move.b	d1,(a1)+
	move.b	(a2)+,d1
	lsr.b	#1,d1
	move.b	d1,(a1)+
	move.b	(a2)+,d1
	lsr.b	#1,d1
	move.b	d1,(a1)+
	move.b	(a2)+,d1
	lsr.b	#1,d1
	move.b	d1,(a1)+
	dbf	d2,fabrfnt_loop
	movem.l	(a7)+,a1-a2/d1-d2
	rts

	data
fonte8x6	dcb.w	3
	dc.b	$10,'8|',$fe,'8888'
	dc.b	$fe,'|8',$10,$c0,$f0,$fc,$f0
	dc.b	$c0,0,$c,'<',$fc,'<',$c,0
	dc.b	'D(',$10,'(D',0,0,'x'
	dc.b	$fc,$fc,'x',0,$fc,$fc,$fc,$fc
	dc.b	$fc,$fc,0,0,0,0,$a8,0
	dcb.w	72
	dc.b	'000',0,'0',0,'ll'
	dc.b	'H',0,0,0,'H',$fc,'H',$fc
	dc.b	'H',0,'0|',$f0,'<',$f8,'0'
	dc.b	$cc,$d8,'0l',$cc,0,'p',$d8
	dc.b	't',$d8,'l',0,'00 ',0
	dc.b	0,0,$18,'000',$18,0
	dc.b	'0',$18,$18,$18,'0',0,'l8'
	dc.b	$fc,'8l',0,'00',$fc,'0'
	dc.b	'0',0,0,0,0,'00 '
	dc.b	0,0,$fc,0,0,0,0,0
	dc.b	0,'00',0,$c,$18,'0`'
	dc.b	$c0,0,'x',$cc,$dc,$ec,'x',0
	dc.b	'0p00',$fc,0,'x',$cc
	dc.b	$18,'p',$fc,0,$f8,$c,'8',$c
	dc.b	$f8,0,'8x',$d8,$fc,$18,0
	dc.b	$fc,$c0,$f8,$c,$f8,0,'x',$c0
	dc.b	$f8,$cc,'x',0,$fc,$c,$18,'0'
	dc.b	'0',0,'x',$cc,'x',$cc,'x',0
	dc.b	'x',$cc,'|',$c,'x',0,'00'
	dc.b	0,'00',0,'00',0,'0'
	dc.b	'0 ',$18,'0`0',$18,0
	dc.b	0,$fc,0,$fc,0,0,'`0'
	dc.b	$18,'0`',0,$f8,$c,'8',0
	dc.b	'0',0,'x',$cc,$dc,$c0,'x',0
	dc.b	'x',$cc,$cc,$fc,$cc,0,$f8,$cc
	dc.b	$f8,$cc,$f8,0,'|',$c0,$c0,$c0
	dc.b	'|',0,$f0,$d8,$cc,$cc,$f8,0
	dc.b	$fc,$c0,$f0,$c0,$fc,0,$fc,$c0
	dc.b	$f0,$c0,$c0,0,'|',$c0,$dc,$cc
	dc.b	'|',0,$cc,$cc,$fc,$cc,$cc,0
	dc.b	'x000x',0,'|',$c
	dc.b	$c,$cc,'x',0,$cc,$d8,$f0,$d8
	dc.b	$cc,0,$c0,$c0,$c0,$c0,$fc,0
	dc.b	$84,$cc,$fc,$cc,$cc,0,$cc,$ec
	dc.b	$fc,$dc,$cc,0,'x',$cc,$cc,$cc
	dc.b	'x',0,$f8,$cc,$f8,$c0,$c0,0
	dc.b	'x',$cc,$cc,$cc,'x',$c,$f8,$cc
	dc.b	$f8,$cc,$cc,0,'x',$c0,'x',$c
	dc.b	$f8,0,$fc,'0000',0
	dc.b	$cc,$cc,$cc,$cc,'x',0,$cc,$cc
	dc.b	$cc,'x0',0,$cc,$cc,$fc,$cc
	dc.b	$84,0,$cc,'x0x',$cc,0
	dc.b	$cc,$cc,'x00',0,$fc,$18
	dc.b	'0`',$fc,0,'x```'
	dc.b	'x',0,$c0,'`0',$18,$c,0
	dc.b	'x',$18,$18,$18,'x',0,$10,'8'
	dc.b	'l',0,0,0,0,0,0,0
	dc.b	$fc,0,'`0',$18,0,0,0
	dc.b	0,'x',$c,$fc,'|',0,$c0,$f8
	dc.b	$cc,$cc,$f8,0,0,'x',$c0,$c0
	dc.b	'|',0,$c,'|',$cc,$cc,'|',0
	dc.b	0,'x',$fc,$c0,'|',0,'<`'
	dc.b	$f8,'``',0,0,'|',$cc,'|'
	dc.b	$8c,'x',$c0,$f8,$cc,$cc,$cc,0
	dc.b	'0',0,'000',0,$c,0
	dc.b	$c,$c,$cc,'x',$c0,$d8,$f0,$d8
	dc.b	$cc,0,'00008',0
	dc.b	0,'H',$fc,$fc,$cc,0,0,$f8
	dc.b	$cc,$cc,$cc,0,0,'x',$cc,$cc
	dc.b	'x',0,0,$f8,$cc,$cc,$f8,$c0
	dc.b	0,'|',$cc,$cc,'|',$c,0,$f8
	dc.b	$cc,$c0,$c0,0,0,'|',$e0,$1c
	dc.b	$f8,0,'`',$f8,'``8',0
	dc.b	0,$cc,$cc,$cc,'x',0,0,$cc
	dc.b	$cc,'x0',0,0,$cc,$fc,$fc
	dc.b	'H',0,0,$cc,'xx',$cc,0
	dc.b	0,$cc,$cc,'|',$c,$f8,0,$fc
	dc.b	$18,'p',$fc,0,'80`0'
	dc.b	'8',0,'00000',0
	dc.b	'p0',$18,'0p',0,0,0
	dc.b	'l',$d8,0,0,0,$10,'8l'
	dc.b	'|',0
nom_notes	dc.b	'C-0 C#0 '
	dc.b	'D-0 D#0 '
	dc.b	'E-0 F-0 '
	dc.b	'F#0 G-0 '
	dc.b	'G#0 A-0 '
	dc.b	'A#0 B-0 '
	dc.b	'C-1 C#1 '
	dc.b	'D-1 D#1 '
	dc.b	'E-1 F-1 '
	dc.b	'F#1 G-1 '
	dc.b	'G#1 A-1 '
	dc.b	'A#1 B-1 '
	dc.b	'C-2 C#2 '
	dc.b	'D-2 D#2 '
	dc.b	'E-2 F-2 '
	dc.b	'F#2 G-2 '
	dc.b	'G#2 A-2 '
	dc.b	'A#2 B-2 '
	dc.b	'C-3 C#3 '
	dc.b	'D-3 D#3 '
	dc.b	'E-3 F-3 '
	dc.b	'F#3 G-3 '
	dc.b	'G#3 A-3 '
	dc.b	'A#3 B-3 '
	dc.b	'C-4 C#4 '
	dc.b	'D-4 D#4 '
	dc.b	'E-4 F-4 '
	dc.b	'F#4 G-4 '
	dc.b	'G#4 A-4 '
	dc.b	'A#4 B-4 '
	dc.b	'C-5 C#5 '
	dc.b	'D-5 D#5 '
	dc.b	'E-5 F-5 '
	dc.b	'F#5 G-5 '
	dc.b	'G#5 A-5 '
	dc.b	'A#5 B-5 '
	dc.b	'C-6 C#6 '
	dc.b	'D-6 D#6 '
	dc.b	'E-6 F-6 '
	dc.b	'F#6 G-6 '
	dc.b	'G#6 A-6 '
	dc.b	'A#6 B-6 '
	dc.b	'C-7 C#7 '
	dc.b	'D-7 D#7 '
	dc.b	'E-7 F-7 '
	dc.b	'F#7 G-7 '
	dc.b	'G#7 A-7 '
	dc.b	'A#7 B-7 '
curs_x_table	dc.b	0,$14,0,$1d,0,'$',0,'%'
	dc.b	0,',',0,'-',0,'4',0,'5'
	dc.b	0,'<'
nt_pernote	dc.b	3,'X',3,'(',2,$fa,2,$d0
	dc.b	2,$a6,2,$80,2,'\',2,':'
	dc.b	2,$1a,1,$fc,1,$e0,1,$c5
	dc.b	1,$ac,1,$94,1,'}',1,'h'
	dc.b	1,'S',1,'@',1,'.',1,$1d
	dc.b	1,$d,0,$fe,0,$f0,0,$e2
	dc.b	0,$d6,0,$ca,0,$be,0,$b4
	dc.b	0,$aa,0,$a0,0,$97,0,$8f
	dc.b	0,$87,0,$7f,0,'x',0,'q'
	dc.b	' 0 1 2 3'
	dc.b	' 4 5 6 7'
	dc.b	' 8 9 A B'
	dc.b	' C D E F'
table_byte2char	dc.b	'00010203'
	dc.b	'04050607'
	dc.b	'08090A0B'
	dc.b	'0C0D0E0F'
	dc.b	'10111213'
	dc.b	'14151617'
	dc.b	'18191A1B'
	dc.b	'1C1D1E1F'
	dc.b	'20212223'
	dc.b	'24252627'
	dc.b	'28292A2B'
	dc.b	'2C2D2E2F'
	dc.b	'30313233'
	dc.b	'34353637'
	dc.b	'38393A3B'
	dc.b	'3C3D3E3F'
	dc.b	'40414243'
	dc.b	'44454647'
	dc.b	'48494A4B'
	dc.b	'4C4D4E4F'
	dc.b	'50515253'
	dc.b	'54555657'
	dc.b	'58595A5B'
	dc.b	'5C5D5E5F'
	dc.b	'60616263'
	dc.b	'64656667'
	dc.b	'68696A6B'
	dc.b	'6C6D6E6F'
	dc.b	'70717273'
	dc.b	'74757677'
	dc.b	'78797A7B'
	dc.b	'7C7D7E7F'
	dc.b	'80818283'
	dc.b	'84858687'
	dc.b	'88898A8B'
	dc.b	'8C8D8E8F'
	dc.b	'90919293'
	dc.b	'94959697'
	dc.b	'98999A9B'
	dc.b	'9C9D9E9F'
	dc.b	'A0A1A2A3'
	dc.b	'A4A5A6A7'
	dc.b	'A8A9AAAB'
	dc.b	'ACADAEAF'
	dc.b	'B0B1B2B3'
	dc.b	'B4B5B6B7'
	dc.b	'B8B9BABB'
	dc.b	'BCBDBEBF'
	dc.b	'C0C1C2C3'
	dc.b	'C4C5C6C7'
	dc.b	'C8C9CACB'
	dc.b	'CCCDCECF'
	dc.b	'D0D1D2D3'
	dc.b	'D4D5D6D7'
	dc.b	'D8D9DADB'
	dc.b	'DCDDDEDF'
	dc.b	'E0E1E2E3'
	dc.b	'E4E5E6E7'
	dc.b	'E8E9EAEB'
	dc.b	'ECEDEEEF'
	dc.b	'F0F1F2F3'
	dc.b	'F4F5F6F7'
	dc.b	'F8F9FAFB'
	dc.b	'FCFDFEFF'
	bss
adrecr	ds.l	1
linewidth	ds.w	1
patligcol	ds.b	12
fonte8x6_ombr	ds.b	768
ice2_21	ds.b	120
l0226	ds.b	164
zuend	end
