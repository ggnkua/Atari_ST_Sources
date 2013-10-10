	*******************************
	* prg de decoupage de sprites *
	*   (c) 1993 Cyril COGORDAN   *
	*******************************

	opt o+,w-

	include d:\falcon.lib

	section text

              jsr load_pic
	jsr dec_pic
	jsr get_bomb
	jsr get_boum
	jsr get_mecs
	jsr get_rip
	jsr save_bomb
	jsr save_boum
	jsr save_rip
	jsr save_decor
	jsr save_mecs
	clr.w -(sp)
	trap #1

get_boum	lea tmp_boum,a1
	moveq #0,d0
	bra.s get_bombs1

get_mecs	lea tmp_mecs,a1
	lea tampon_pic2+(32*160),a0
	moveq #3,d0
	bra.s get_bombs1

get_rip	lea tmp_rip,a1
	moveq #0,d0
	bra.s get_bombs1

get_bomb	lea tampon_pic2+(16*160),a0
	lea tmp_bomb,a1
	moveq #7,d0		8 pseudos
get_bombs1	v_init offset,0
	rept 16
	move.l offset+0(a0),(a1)+
	move.l offset+4(a0),(a1)+
	v_inc offset,160
	endr
	addq.w #8,a0
	dbra d0,get_bombs1
	rts

dec_pic	lea tampon_pic,a5
	lea tampon_pic2,a3
	jmp decomp_pc1

load_pic	lea nom_pic,a5
	lea tampon_pic,a6
	move.l #32066,d6
	jmp load

save_bomb	lea nom_bomb,a5
	lea tmp_bomb,a6
	move.l #(end_bomb-tmp_bomb),d6
	jmp save

save_boum	lea nom_boum,a5
	lea tmp_boum,a6
	move.l #(end_boum-tmp_boum),d6
	jmp save

save_mecs	lea nom_mecs,a5
	lea tmp_mecs,a6
	move.l #(end_mecs-tmp_mecs),d6
	jmp save

save_rip	lea nom_rip,a5
	lea tmp_rip,a6
	move.l #(end_rip-tmp_rip),d6
	jmp save

;
; Charge un fichier A5 de D6 octets a l'adresse A6
;
load	print txt_load
	print (a5)
	print txt_lf
	clr.w -(sp)
	pea (a5)
	move.w #$3d,-(sp)
	trap #1
	add.l #8,sp
	tst.w d0
	bmi fin_load
	move.w d0,d7
	pea (a6)
	move.l d6,-(sp)
	move.w d7,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bmi fin_load
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
fin_load	rts
;
; Sauve un fichier A5 a l'adresse A6 de D6 octets
;
save	print txt_save
	print (a5)
	print txt_lf
	clr.w -(sp)
	pea (a5)
	move.w #$3c,-(sp)
	trap #1
	add.l #8,sp
	tst.w d0
	bmi fin_save
	move.w d0,d7
	pea (a6)
	move.l d6,-(sp)
	move.w d7,-(sp)
	move.w #$40,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bmi fin_save
	cmp.l d6,d0
	bne.s fin_save
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
fin_save	rts
;
; D‚compacte une image PC1 avec source=A5 et destination=A3
;
decomp_pc1	add.l #34,a5		passe la palette
	move.l #$c7,d4
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

nom_pic	dc.b "e:\blasters.men\gfx\sprites.pc1",0
nom_bomb	dc.b "e:\blasters.men\files\bombes.spr",0
nom_boum	dc.b "e:\blasters.men\files\boum.spr",0
nom_mecs	dc.b "e:\blasters.men\files\mecs.spr",0
nom_rip	dc.b "e:\blasters.men\files\r_i_p.spr",0
txt_load	dc.b "Loading : ",0
txt_save	dc.b "Saving : ",0
txt_lf	dc.b $0A,$0D,0

	even

	section bss

null	ds.b 32

tampon_pic	ds.b 32066
tampon_pic2	ds.b 32000

tmp_bomb	ds.b 8*16*8
end_bomb	equ *

tmp_boum	ds.b 8*16
end_boum	equ *

tmp_mecs	ds.b 8*16*4
end_mecs	equ *

tmp_rip	ds.b 8*16
end_rip	equ *

	end
