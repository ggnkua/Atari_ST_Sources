
p_buff		dc.l	0
type_patt_dt	dc.l	0

;---------------

Init_module

; a0: pointer module

		clr.l	base_frq
		cmpi.l	#"D.T.",(a0)
		bne	.error
		move.l	a0,p_buff
		jsr	Read_Digital_Tracker
		tst.b	d0
		bne	.error

		lea	data_voice,a0
		moveq	#31,d0
.init_dt_voie
		clr.w	vit_pdown(a0)
		clr.b	data_vib(a0)
		clr.b	cpt_vib(a0)
		clr.b	data_tre(a0)
		clr.b	cpt_tre(a0)
		clr.b	port_vit(a0)
		clr.b	port_dir(a0)
		clr.w	port_dest(a0)
		move.b	#$ff,data_phase8(a0)
		clr.b	data_phase9(a0)
		add.w	#end2,a0
		dbra	d0,.init_dt_voie

		tst.l	base_frq
		beq.s	.no_change
		lea	sample+variable,a0
		moveq	#62,d0
.ch		move.l	base_frq,frq_inst(a0)
		adda.w	#end_inst,a0
		dbra	d0,.ch

.no_change	
		sf	d0

		rts


.error
		st	d0

		rts

;---------------

Read_Digital_Tracker

	lea Header_chunk,a2
.tq_head
	jsr	paint_init_point10
	tst.l (a2)
	bmi .end
	movem.l (a2)+,d0/a1
	cmp.l ([p_buff]),d0
	bne.s .tq_head
	jsr (a1)
	tst.b d0
	bne .error
	lea Header_chunk,a2
	bra.s .tq_head
.end	sf d0
	rts
	
.error	st d0
	rts

nb_sequ_DT	dc.w 0	;Longueur de la sequence-1
nb_voie_DT	dc.w 0	
nb_patt_DT	dc.w 0	;Nombre de patterns lus par DT -1
nb_inst_DT	dc.w 0	;Nombre d'inst lus par DT -1
type_sm_DT	dc.w 0

Header_chunk
	DC.B 'D.T.'
	dc.l Read_chunkdt
	dc.b 'S.Q.'
	dc.l Read_chunkseq
	dc.b 'PATT'
	dc.l Read_chunkpatt
	dc.b 'INST'
	dc.l Read_chunkinst
	dc.b 'DAPT'
	dc.l Read_chunkdapt
	dc.b 'DAIT'
	dc.l Read_chunkdait
	dc.b 'DSNG'
	dc.l Read_chunksng
	DC.L -1

Read_chunkdt
	move.l p_buff,a0
	move.l 4(a0),d0
	addq.l #8,d0
	add.l d0,p_buff
	addq.w #8,a0
	move.w 2(a0),d1
	bne.s .set_base
	moveq #8,d1
.set_base	move.w d1,base
	addq.w #6,a0
	moveq #125,d1
	moveq #6,d0
	tst.w (a0)+
	beq.s .no_speed
	move.w -2(a0),d0
.no_speed	tst.w (a0)+
	beq.s .no_temp
	move.w -2(a0),d1
.no_temp	move.b d0,speed+variable
	move.w d1,Tempo_sng+variable
	move.l (a0)+,base_frq
	tst.b -10(a0)
	beq.s .no_multi
	clr.l base_frq
.no_multi	lea name_mod,a1
	moveq #19,d0
.cp_sname	move.b (a0)+,(a1)+
	dbra d0,.cp_sname
.end	sf d0
	rts
	
.error	st d0
	rts
	
Read_chunkseq
	move.l p_buff,a0
	move.l 4(a0),d0
	addq.l #8,d0
	add.l d0,p_buff
	addq.w #8,a0
	
	move.w (a0)+,d0
	move.b d0,nbsongpos+variable
	move.w (a0)+,d0
	move.b d0,songrep+variable	;Position de repeat
	clr.b songpos+variable
	clr.w pattpos+variable
	move.l (a0)+,d0		;Reservee
	move.l a0,tab_adr_blk		;Adresse sequence
	sf d0
	rts
	
Read_chunkpatt
	move.l p_buff,a0
	move.l 4(a0),d0
	addq.l #8,d0
	add.l d0,p_buff
	addq.w #8,a0
	
	moveq #0,d0
	move.w (a0)+,d0	;nombre de voies...
	move.w (a0)+,d1
	subq.w #1,d1
	move.w d1,nb_patt_DT	;Nombre de patterns
	cmp.l #'2.04',(a0)+	;Version pattern ?
	bne.s .old
	move.w #1,type_patt_dt
.old	move.w d0,nb_voie_temp
	subq.w #1,d0
	move.w d0,nb_voie_DT
	cmp.w nb_voie,d0
	beq .end
	move.l d1,-(sp)
	move.l d0,d1
	jsr Number_voice
	move.l (sp)+,d1
.end	sf d0
	rts

; D1 contient le nombre de voies voulues... - 1
Number_voice
	move.l d1,d2
	addq.w #1,d2
	lsl.w #2,d2		;Taille d'une ligne...
	move.w d2,lg_lig_pat
	lsl.w #6,d2
	move.w d2,len_pat
	move.w d1,nb_voie
	move.w d1,nb_voie_temp
	rts
	
nb_voie_temp	dc.w 0


Read_chunksng
 	sf d0
 	rts
	
Read_chunkinst
	move.l p_buff,a0
	move.l 4(a0),d0
	addq.l #8,d0
	add.l d0,p_buff
	addq.w #8,a0
	
	move.w (a0)+,d1
	subq.w #1,d1
	move.w d1,nb_inst_DT	;nombre d'inst
	moveq #0,d2
.next	lea (sample+variable+4,d2.w),a1	;Ne copie pas
	addq.w #4,a0
	move.w #((end_inst-4)/2)-1,d0
.loop_it	move.w (a0)+,(a1)+
	dbra d0,.loop_it
	tst.w (midi_inst+sample+variable,d2.w)
	bne.s .ok_mid
	move.w #12*4,(midi_inst+sample+variable,d2.w)
.ok_mid	add.w #end_inst,d2
	dbra d1,.next
 	sf d0
 	rts
 	
Read_chunkdapt
 	move.l p_buff,a0
	move.l 4(a0),d0
	addq.l #8,d0
	add.l d0,p_buff
	addq.w #8,a0
	
	move.l (a0)+,d2	;Canaux on/off (non utilis‚ pour l'instant)
	move.w (a0)+,d1	;Numero de la pattern
	move.w (a0)+,d3	;Nombre de lignes
	move.w d3,(nb_lig_patt,d1.w*4)
	st (nb_lig_patt+2,d1.w*4)	;Pattern cree !!
	
	addq.w #1,d1
	move.l a0,(tab_adr_blk.l,d1.w*4)
	jsr Convert_new_format
	sf d0
 	rts

; d1 = numero de la pattern
Convert_new_format
	cmp.w #1,type_patt_dt
	beq .end
	movem.l d0-d5/a0-a2,-(sp)
	lea tab_convert+2,a2	
	move.w (nb_lig_patt-4,d1.w*4),d3
	move.w nb_voie,d0
	addq.w #1,d0
	mulu d0,d3
	move.l (tab_adr_blk.l,d1.w*4),a1
	moveq #18,d1
	moveq #2,d2
	move.w d3,-(sp)
	lsr.w #3,d3
	subq.w #1,d3
	bmi .reste
.voc	
	rept 8
	move.w (a1),d5
	bfextu d5{d1:d2},d4
	bfclr d5{d1:d2}
	or.w (a2,d5.w*4),d4
	move.w d4,(a1)+
	addq.w #2,a1
	endr
	dbra d3,.voc
.reste	move.w (sp)+,d3
	and.w #7,d3
	subq.w #1,d3
	bmi.s .suite
.voc2	move.w (a1),d5
	bfextu d5{d1:d2},d4
	bfclr d5{d1:d2}
	or.w (a2,d5.w*4),d4
	move.w d4,(a1)+
	addq.w #2,a1
	dbra d3,.voc2
.suite	movem.l (sp)+,d0-d5/a0-a2
.end	rts


Read_chunkdait
	move.l p_buff,a0
	move.l 4(a0),d0
	addq.l #8,d0
	add.l d0,p_buff
	addq.w #8,a0
	move.w (a0)+,d1	;Numero de l'inst
	move.w d1,d4
	addq.w #1,d1
	mulu #end_inst,d4
	move.w (sample+variable+type_inst,d4.w),d6
	add.w #128,d1
	move.l #256,d3
	move.l (sample+variable+len_inst,d4.w),d0
	beq.s .inst_null
	add.l #5000-256,d3
	cmp.b #8,d6
	beq.s .inst_null
	add.l #5000,d3
.inst_null	add.l d3,d0
	move.l a0,(tab_adr_blk.l,d1.w*4)
	move.l p_end,d2
	move.l d2,a1
	lea (a1,d3.l),a2
	sub.l p_buff,d2	;Nombre d'octet a remuer...
	addq.l #4,d2
	and.b #$FC,d2
	lsr.l #2,d2
	move.l d2,d4
	lsr.l #3,d2
	subq.l #1,d2
	bmi.s .stop
.tq	
	rept 8
	move.l -(a1),-(a2)
	endr
	subq.l #1,d2
	bpl.s .tq

.stop	and.l #7,d4
	beq.s .rien
	subq.l #1,d4
.lp	move.l -(a1),-(a2)
	dbra d4,.lp
.rien	add.l d3,p_buff
	add.l d3,p_end
	cmp.l #256,d3
	beq.s .end
	sub.w #128,d1
	jsr Redo_repeat
.end	sf d0
	rts

;---------------

		include "include\menu\parts\player.s"

;--------------------------------------

		ifne menuedata_load

		ds.l	1
tab_adr_blk	ds.l	500
end_tab_adr	ds.l	1
tab_size_blk	ds.l	500

		endc



