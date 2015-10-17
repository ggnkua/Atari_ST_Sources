	***********************************
	* Creation des fichiers de levels *
	*    pour le jeu: BLASTERS MEN    *
	*     (c) 1993 Cyril COGORDAN     *
	***********************************

	opt o+,w-

	include d:\falcon.lib
	output e:\blasters.men\make_lvl.prg

disk_dur	equ 1	0=disquette/1=disque dur

	section text

	jsr load_all
	jsr save_all
	clr.w -(sp)
	trap #1

load_all	lea tmp_map+2,a0
	lea tmp_atc,a1
	move.w #99,d5
load_alls1	lea nom_level,a5
	ifne disk_dur
	move.l #"MAP"<<8,ext_level
	elseif
	move.l #".MAP",ext_level
	endc
	move.l a0,a6
	move.l #488,d6
	jsr load
	tst.w d0
	bmi.s load_alls99
	ifne disk_dur
	move.l #"ATC"<<8,ext_level
	elseif
	move.l #".ATC",ext_level
	endc
	lea nom_level,a5
	move.l a1,a6
	move.l #240,d6
	jsr load
	tst.w d0
	bmi.s load_alls2
	addq.w #1,tmp_map
	lea 488(a0),a0
	lea 240(a1),a1
	addq.b #1,num_level+1
	cmp.b #"9"+1,num_level+1
	bne.s load_alls2
	move.b #"0",num_level+1
	addq.b #1,num_level
load_alls2	dbra d5,load_alls1
load_alls99	rts

save_all	lea nom_map,a5
	lea tmp_map,a6
	move.w #488,d6
	mulu (a6),d6
	addq.w #2,d6
	jsr save
	lea nom_atb,a5
	lea tmp_atc,a6
	move.w #240,d6
	mulu tmp_map,d6
	jmp save

;
; Charge un fichier A5 de D6 octets a l'adresse A6
;
load	movem.l a0-a1,-(sp)
	print txt_load
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
fin_load	movem.l (sp)+,a0-a1
	rts

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

	section data

nom_map	dc.b "all_lvl.map",0
nom_atb	dc.b "all_lvl.atb",0

	ifne disk_dur
nom_level	dc.b "e:\blasters.men\levels.map\level_"
num_level	dc.b "00."
ext_level	dc.b "MAP",0
	elseif
nom_level	dc.b "\levels.map\level_"
num_level	dc.b "00"
ext_level	dc.b ".MAP",0
	endc

txt_load	dc.b "Loading : ",0
txt_save	dc.b "Saving : ",0
txt_lf	dc.b $0A,$0D,0

	even

	section bss

tmp_map	ds.w 1
	ds.b 100*488

tmp_atc	ds.b 100*240

	end
