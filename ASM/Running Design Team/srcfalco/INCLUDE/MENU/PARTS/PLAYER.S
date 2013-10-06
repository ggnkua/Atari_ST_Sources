
Init_all
		move.l 	#digit1,d7
		addq.l 	#4,d7
		and.b 	#$FC,d7
		move.l 	d7,buffer
		move.l 	#digit2,d7
		addq.l 	#4,d7
		and.b 	#$FC,d7
		move.l 	d7,buffer+4

		moveq 	#62,d0
		jsr 	Init_all_instr

		lea 	data_voice,a1
		moveq 	#31,d7
.init		move.l 	(tab_adr_blk+129*4),adr_instr(a1)
		clr.l 	sspl_pos(a1)
		move.b 	#$FF,data_phase8(a1)
		add.w 	#end2,a1
		dbra 	d7,.init
	
		lea 	speed+variable,a0
		move.b 	#6,(a0)+		;vitesse
		move.b 	#0,(a0)+		;Cpt
		move.w 	#125,(a0)+		;Tempo
		clr.b 	(a0)+			;Songpos
		clr.b 	(a0)+			;Songrep
		move.b 	#1,(a0)+		;Nbsongpos
		addq.w 	#1,a0
		clr.w 	(a0)+			;Pattpos
	
		move.w 	#64,vol_mod+variable+2

		rts

;---------------

Init_all_instr
		lea 	sample+variable,a0
		move.l 	#129*4,d1
.init_sample 	move.l 	d1,index_inst(a0)
		clr.l 	len_inst(a0)
		clr.l 	repstart_inst(a0)
		move.w 	#$0040,fine_inst(a0)
		move.l 	#2,replen_inst(a0)
		sf 	fine_inst(a0)
		sf 	name_inst(a0)
		sf 	type_inst(a0)			;signee
		move.b 	base+1,(type_inst+1)(a0)	;8 bits
		move.w 	#(12*4),midi_inst(a0)		;DO octave 4
		move.l 	#8363,frq_inst(a0)
		clr.l 	repstart_inst(a0)
		clr.l 	replen_inst(a0)
		add.w 	#end_inst,a0
		addq.w 	#4,d1
		dbra 	d0,.init_sample

		rts

;---------------

Run_super	
		pea 	(a0)
		move.w 	#$26,-(sp)
		trap 	#14
		addq.w 	#6,sp

		rts

;---------------
	
; d7 = freq

Sdma_freq	
		lea 	$ffff8900.w,a0
		move.w 	$3a(a0),-(sp)
		move.w 	#-1,$3a(a0)
		btst 	#7,d7		;Frq non STE ?
		bne.s 	.non
		and.b 	#%11110000,$ffff8935.w
		and.w 	#$FFFC,$20(a0)
		or.w 	d7,$20(a0)
		bra.s 	.suite
.non		bclr 	#7,d7
		and.b 	#%11110000,$ffff8935.w
		or.b 	d7,$ffff8935.w
.suite		move.w 	d7,_thefreq+2
		clr.w 	_thefreq
		cmp.w 	#3,d7
		bne.s 	.n50
		move.w 	#$200,_thefreq
.n50		cmp.w 	#4,d7
		bne.s 	.n20
		move.w 	#$400,_thefreq
.n20		move.w 	(sp)+,$3a(a0)

		rts

;---------------

joue	
		lea $ffff8900.w,a0
		moveq #0,d2	
		MOVE.L buffer,D0
		move.l d0,d1
		add.l #2002*2,d0	;*2 pour 2 TRACKS
	
		clr.b 1(a0)		;OFF
		movep.l d1,1(a0)	;adr deb
		movep.l d0,$D(a0)	;adr fin
	
		lea player(pc),a0
		move.l $13C.w,-4(a0)
		move.l a0,$13C.w
	
		bset #7,$fffffa07.w	;Let's go
		bset #7,$fffffa13.w
	
		st f_max+1
		moveq #2,d7		;Freq
		bsr Sdma_freq
		move.w #$303,0(a0)		;PLay & Repeat

		rts

;---------------

jouepas	
		move.w #1,-(sp)
		move.w #140,-(sp)
		trap #14
		addq.w #4,sp
		lea $ffff8900.w,a0
		clr.b 1(a0)
		bclr #7,$fffffa07.w
		bclr #7,$fffffa13.w
		move.l player-4,$13C.w

		rts

;---------------

		dc.l 	0		;Recoit l'adresse du TIMER A

player
		bclr #7,$fffffa0f.w
		movem.l d0-d7/a0-a6,-(sp)
		move.l buffer,d1
		lea Tempo_tab,a0
		add.w _thefreq,a0
		moveq #0,d0
		move.w Tempo_sng+variable,d0
		move.w (a0,d0.w*2),d0
		lsl.w #2,d0
		lea $ffff8900.w,a0
		ADD.L D0,D1
		movep.w d1,$11(a0)
		swap d1
		move.b d1,$f(a0)
		move.b #3,1(a0)
	
		ifne TEMPS
		not.l $ffff9800.w
		not.w $ffff8240.w
		endc
		and.w #$F8FF,SR
		moveq #0,d0
		move.w nb_voie,d0
		bset #13,d0
		tst.b base
		bne.s .no_div
		bclr #13,d0
		lsr.l #1,d0		;Divise par deux si pas stereo...
.no_div		tst.b f_max+1
		beq.s .no_beg
		bset #14,d0
		sf f_max+1
.no_beg	
;	bset #15,d0		;Pour tout couper !!!

.at_write	btst #1,$ffffa202.w
	beq.s .at_write
	move.l d0,$ffffa204.w	;General...
	moveq #0,d0
	move.w nb_voie,d0
	tst.b f_max
	beq.s .no_mv0
	moveq #4,d0
.no_mv0	tst.b base
	beq.s .passte
	add.w d0,d0
.passte	lsl.w #5,d0
	move.l d0,$ffffa204.w	;Pour le volume...
	jsr songplay	;Si on coupe tout, on enleve ces
	jsr Analyse_voices	;deux jsr...
.end	
	ifne TEMPS
	not.l $ffff9800.w
	not.w $ffff8240.w
	endc
	movem.l (sp)+,d0-d7/a0-a6
	rte

songplay	lea variable,a6
	move.b speed(a6),d0
	
	subq.b #1,cpt(a6)		;Cpt song
	bpl no_new_note
	
	subq.b #1,d0
	move.b d0,cpt(a6)
	tst.b patt_delay2(a6)
	beq.s .get_note
	jsr no_new_note
	bra .dskip
	
	***Calcule l'adresse pattern
.get_note	
	lea nb_lig_patt,a0
	
	move.l tab_adr_blk,a1
	moveq #0,d0
	move.b songpos(a6),d0
	move.b (a1,d0.w),d0		;Numero pattern
	tst.b 2(a0,d0.w*4)		;Pattern existe ??
	beq .end
	move.w (a0,d0.w*4),d4		
	move.w d4,lig_pat		;Nombre de ligne
	mulu lg_lig_pat,d4
	move.w d4,len_pat		;Longueur pattern
	
	move.l (tab_adr_blk+4,d0.w*4),a0
	add.w pattpos(a6),a0
	
	lea data_voice,a1
	lea sample(a6),a2
	
	***Lit les notes de la pattern
	
	clr.w d4
	sf pass_e6(a6)
	move.w nb_voie,d7
.next_track	move.l (a0)+,ligne(a1)		;Note pattern
	***Prend l'instrument
	tst.l stereo_put?
	beq.s .no_st_put
	move.l stereo_put?,ligne(a1)
	clr.l stereo_put?
.no_st_put	bfextu ligne(a1){14:6},d6	;No Instrument
	moveq #0,d5
	move.b ligne(a1),d5
.pas_31	tst.w d6
	beq .no_new_instr
	subq.w #1,d6
	clr.l spl_offset2(a1)
	mulu #end_inst,d6
	move.l (tab_adr_blk.l,[a2,d6.w]),adr_instr(a1)	;Adresse instr
	move.l len_inst(a2,d6.w),len_instr(a1)	;len instr
	move.b fine_inst(a2,d6.w),fine_tune(a1)	;Volume instr
	move.l frq_inst(a2,d6.w),freq_inst(a1)
	move.w type_inst(a2,d6.w),typ_inst(a1)
	move.w midi_inst(a2,d6.w),mid_inst(a1)
	btst #0,type_inst(a2,d6.w)
	beq.s .no_st
	btst #0,d7
	beq.s .set_r
	move.l ligne(a1),stereo_put?
	bclr #7,typ_inst(a1)	;Left
	bra.s .no_st
.set_r	bset #7,typ_inst(a1)	;Right
.no_st	move.b vol_inst(a2,d6.w),d0
	and.w #$FF,d0
	move.b d0,vol_instr(a1)		;Volume actuel
	move.w d0,vol_actuel(a1)
	clr.l old_calc(a1)
	move.l repstart_inst(a2,d6.w),rep_start(a1)	;Repeat start
	move.l replen_inst(a2,d6.w),rep_len(a1)	;Repeat len
.no_new_instr
	bfextu ligne(a1){8:6},d6	;Second Volume 
	beq.s .no_new_volume
	move.b d6,vol_instr(a1)		;Volume actuel
	move.w d6,vol_actuel(a1)
.no_new_volume	
	*Prend la commande pour portamento
	move.b (2+ligne)(a1),d6
	and.w #$f,d6
	***Prend la note
	move.l #a_arp,ad_note(a1)
	move.w d5,d0
	beq.s .note_raz
	and.w #$F,d0
	subq.w #1,d0	;Note...
	lsr.w #4,d5
	subq.w #2,d5	;Octave
	mulu #12,d5
	add.w d5,d0
	lea (a_arp,d0.w*2),a4
	move.w (a4),d5
	move.l a4,ad_note(a1)
.note_raz	move.w d5,note_brut(a1)
	move.w d5,ligne(a1)
	tst.w d5			;Note ?
	beq .no_note
	move.w (2+ligne)(a1),d0
	and.w #$FF0,d0
	cmp.w #$E50,d0		;Set Fine tune ?
	bne.s .nosetf
	move.b (3+ligne)(a1),fine_tune(a1)
	and.b #$F,fine_tune(a1)
.nosetf	cmp.b #$9,d6		*** 9
	bne.s .pas_90
	move.b (3+ligne)(a1),d0
	bsr do_phase9
	bra.s .set_note
.pas_90	cmp.b #5,d6			*** 5
	beq.s .set_port
	cmp.b #3,d6			*** 3 SET Portamento
	bne.s .set_note
.set_port	bsr Set_port
	bra.s .no_note
.set_note	moveq #0,d0		;cherche correspondance dans le tableau
	move.b fine_tune(a1),d0
	mulu #24*6,d0
	move.l ad_note(a1),a4
	add.l d0,a4
	move.w (a4),d5		;Note avec le Fine tune
.set	tst.l len_instr(a1)
	bne.s .inst_on
	clr.w d5
.inst_on	move.w d5,note(a1)		;Met la note
	move.w d5,note_actuel(a1)
	clr.b cpt_vib(a1)
	move.l spl_offset2(a1),sspl_pos(a1)
.no_note	***Gestion de la commande
	tst.b d6
	beq .no_comm
	moveq #0,d0
	move.b (3+ligne)(a1),d0
	cmp.b #$8,d6		*** 8
	bne.s .pas_8	
	move.b d0,data_phase8(a1)
.pas_8	cmp.b #$b,d6		*** B
	bne.s .pas_B
	subq.b #1,d0
	move.b d0,songpos(a6)
	st f_break(a6)
	clr.w break_pos(a6)
.pas_B	cmp.b #$f,d6		*** F
	bne.s .pas_F
	cmp.b #33,d0		;Est ce un Tempo ??
	blo.s .no_tempo
	move.w d0,Tempo_sng(a6)
	bra.s .pas_F
.no_tempo	and.b #$1F,d0		;Speed normal
	move.b d0,speed(a6)
	subq.b #1,d0
	move.b d0,cpt(a6)
.pas_F	cmp.b #$c,d6		*** C
	bne.s .pas_C
	cmp.w #$40,d0
	ble.s .vol_ok
	move.w #$40,d0
.vol_ok	tst.b vol_mod(a6)
	beq.s .vol_it
	move.w d0,(vol_mod+2)(a6)
	bra.s .pas_C	
.vol_it	move.b d0,vol_instr(a1)
	move.w d0,vol_actuel(a1)
.pas_C	cmp.b #$d,d6		*** D
	bne.s .pas_D
	move.w len_pat,d0
	sub.w lg_lig_pat,d0
	move.w d0,pattpos(a6)
.pas_D	cmp.b #$E,d6		*** E
	bne.s .pas_E
	bsr do_extend_cmd
.pas_E			
.no_comm	add.w #end2,a1
	addq.w #1,d4
	dbra d7,.next_track
	
.dskip	move.w len_pat,d0
	*** Passe a la ligne suivante...
	move.w lg_lig_pat,d1
	add.w d1,pattpos(a6)
	tst.b loc_break(a6)
	beq.s .no_loc_brk
	move.b loc_pos(a6),songpos(a6)
	move.w loc_lig(a6),pattpos(a6)
	sf loc_break(a6)
.no_loc_brk	
	
	move.b patt_delay(a6),d2
	beq.s .no_time2
	move.b d2,patt_delay2(a6)
	clr.b patt_delay(a6)
.no_time2	tst.b patt_delay2(a6)
	beq.s .no_delay
	subq.b #1,patt_delay2(a6)
	beq.s .no_delay
	sub.w d1,pattpos(a6)
.no_delay	tst.b f_break(a6)		;Break ?
	beq.s .no_break
	sf f_break(a6)
	move.w break_pos(a6),d2		;Position du break
	mulu lg_lig_pat,d2
	move.w d2,pattpos(a6)		;Change
.no_break	cmp.w pattpos(a6),d0
	bne.s .not_loop
	clr.w pattpos(a6)
	addq.b #1,songpos(a6)		
	and.b #$7F,songpos(a6)
	move.b nbsongpos(a6),d0
	cmp.b songpos(a6),d0
	bhi.s .not_loop
	move.b songrep(a6),songpos(a6)
.not_loop	
.end	
.end_adr	rts

no_new_note lea data_voice,a1
	lea routs,a5
	move.w nb_voie,d7
.next	move.w 2(a1),d0
	and.w #$fff,d0
	beq.s .end
	move.b 2(a1),d6
	moveq #0,d0
	move.b 3(a1),d0
	and.w #$f,d6
	jsr ([a5,d6.w*4])
.end	add.w #end2,a1
	dbra d7,.next
	
.end_nnn	rts
	
routs	dc.l do_arp,do_pup,do_pdown,do_port,do_vibrato,do_pdown2,do_vibrato2,do_tremolo
	dc.l do_phase8,do_null,do_volslide,do_null,do_null,do_null,do_extend_cmd2,do_null


**********************
* Gestion des effets *
**********************

Set_port	move.w (a1),d2
	and.w #$fff,d2
	moveq #0,d0
	move.b fine_tune(a1),d0
	mulu #24*6,d0
	lea (a_arp,d0.l),a4
	moveq #0,d0
.stploop	cmp.w (a4,d0.w),d2
	bhs.s .stpfound
	addq.w #2,d0
	cmp.w #24*6,d0
	blo.s .stploop
	moveq #36*2,d0
.stpfound	move.b fine_tune(a1),d2
	and.b #8,d2
	beq.s .stpgoss
	tst.w d0
	beq.s .stpgoss
	subq.w #2,d0
.stpgoss	move.w (a4,d0.W),d2
	move.w  d2,port_dest(a1)
	move.w note(a1),d0
	clr.b port_dir(a1)
	cmp.w d0,d2
	beq.s .clear
	bge.s .end
	move.b #1,port_dir(a1)
.end	rts

.clear	clr.w port_dest(a1)
	rts	


do_port	tst.b d0
	beq.s do_portno
	clr.b 3(a1)
	move.b d0,port_vit(a1)	;vitesse
do_portno	tst.w port_dest(a1)
	beq.s .end
	moveq #0,d0
	move.b port_vit(a1),d0
	tst.b port_dir(a1)
	bne.s .mysub
	add.w d0,note(a1)
	move.w port_dest(a1),d1
	cmp.w note(a1),d1
	bgt.s .ok
	move.w port_dest(a1),note(a1)
	clr.w port_dest(a1)
	bra.s .ok
.mysub	sub.w d0,note(a1)
	move.w port_dest(a1),d1
	cmp.w note(a1),d1
	blt.s .ok
	move.w port_dest(a1),note(a1)
	clr.w port_dest(a1)
.ok	move.w note(a1),d2
	move.b glissfunk(a1),d0
	and.b #$0f,D0
	beq.s .glissskip
	moveq #0,d0
	move.b fine_tune(a1),d0
	mulu #24*6,d0
	lea a_arp,a0
	add.l d0,a0
	moveq #0,d0
.glissloop	cmp.w (a0,d0.W),d2
	bhs.s .glissfound
	addq.w #2,d0
	cmp.w #24*4,d0
	blo.s .glissloop
	moveq #36*2,d0
.glissfound	move.w (a0,d0.W),d2
.glissskip	move.w d2,note_actuel(a1)
.end	rts
	
** Arpeggio  No 0
do_arp	tst.b d0
	beq .end
	moveq #0,d1
	move.b speed+variable,d1
	sub.b cpt+variable,d1
	divu #3,d1
	swap d1
	cmp.w #2,d1
	beq.s .arp2
	cmp.w #1,d1
	bne.s .arp_set
.arp1	lsr.b #4,d0
	bra.s .arp3
.arp2	and.w #$F,d0
.arp3	moveq #0,d3
	move.b fine_tune(a1),d3
	mulu #24*6,d3
	lea (a_arp,d3.w),a0	;pointe sur la bonne table
	move.w note(a1),d2
	moveq #71,d3
.cher	cmp.w (a0)+,d2
	bhs.s .met
	dbra d3,.cher
.met	move.w -2(a0,d0.w*2),note_actuel(a1)
	bra.s .end
.arp_set	move.w note(a1),note_actuel(a1)
.end	rts


do_volslide	moveq #0,d2
	move.b vol_instr(a1),d2
	move.b d0,d1
	and.w #$f,d1
	lsr.w #4,d0
	beq.s do_volsdwn
do_volsup	add.w d0,d2
	cmp.w #$40,d2
	ble.s pas_aA
	move.w #$40,d2
	bra.s pas_aA
do_volsdwn	sub.w d1,d2
	bpl.s pas_aA
	clr.w d2
pas_aA	move.b d2,vol_instr(a1)
	move.w d2,vol_actuel(a1)
do_null	rts
	
* Portamento Up No 1

do_pup	sub.w d0,note(a1)
	cmp.w #$71,note(a1)
	bge.s .ok
	move.w #$71,note(a1)
.ok	move.w note(a1),note_actuel(a1)
	rts
	
* Portamento Down No 2
do_pdown	move.w d0,vit_pdown(a1)		;sauve vitesse
	add.w d0,note(a1)
	cmp.w #$358,note(a1)
	ble.s .ok
	move.w #$358,note(a1)
.ok	move.w note(a1),note_actuel(a1)
	rts

do_vibrato	lea a_sin,a0
	tst.b d0
	beq.s .ne
	move.b data_vib(a1),d2
	and.b #$F,d0
	beq.s .vibskip
	and.b #$F0,d2
	or.b d0,d2
.vibskip	move.b 3(a1),d0
	and.b #$F0,d0
	beq.s .vibskip2
	and.b #$F,d2
	or.b d0,d2
.vibskip2	move.b d2,data_vib(a1)

.ne	moveq #0,d1
	move.b cpt_vib(a1),d1
	lsr.w #2,d1
	and.w #$1f,d1
	moveq #0,d2
	move.b wave_type(a1),d2
	and.b #$3,d2
	beq.s .vib_sinus
	lsl.b #3,d1
	cmp.b #1,d2
	beq.s .vib_rampdown
	move.b #255,d0   ;<=
	bra.s .vib_set
.vib_rampdown
	tst.b cpt_vib(a1)	
	bpl.s .vib_rampdown2
	move.b #255,d0
	sub.b d1,d0
	bra.s .vib_set
.vib_rampdown2
	move.b d1,d0
	bra.s .vib_set	
.vib_sinus	move.b (a0,d1.w),d0
.vib_set	move.b data_vib(a1),d1
	and.w #15,d1
	mulu d1,d0
	lsr.w #7,d0			;6->7 le 29/07/93
	move.w note(a1),d1
	tst.b cpt_vib(a1)
	bmi.s .down
	add.w d0,d1
	bra.s .set
.down	sub.w d0,d1
.set	move.w d1,note_actuel(a1)
	move.b data_vib(a1),d0
	lsr.w #2,d0
	and.w #$3C,d0
	add.b d0,cpt_vib(a1)
	rts
	
do_pdown2	bsr do_volslide
	jsr do_portno
	rts
	
do_vibrato2	bsr do_volslide
	moveq #0,d0
	bsr do_vibrato
	rts

do_tremolo	lea a_sin,a0
	tst.b d0
	beq.s .ne
	move.b d0,data_tre(a1)
.ne	move.b cpt_tre(a1),d1
	lsr.w #2,d1
	and.w #$1f,d1
	move.b (a0,d1.w),d0
	moveq #$f,d1
	and.b data_tre(a1),d1
	mulu d1,d0
	lsr.w #6,d0
	moveq #0,d1
	move.b vol_instr(a1),d1
	tst.b cpt_tre(a1)
	bmi.s .down
	add.w d0,d1
	cmp.w #$40,d1
	ble.s .set
	move.w #$40,d1
	bra.s .set
.down	sub.w d0,d1
	bpl.s .set
	clr.w d1
.set	move.w d1,vol_actuel(a1)
	move.b data_tre(a1),d0
	and.b #$F0,d0
	lsr.b #2,d0
	add.b d0,cpt_tre(a1)
	rts
	
do_phase9	and.l #$FF,d0
	tst.b d0
	beq.s .reutilise
	move.b d0,data_phase9(a1)
.reutilise	move.b data_phase9(a1),D0
	lsl.l #8,D0
	add.l spl_offset2(a1),d0
	cmp.l len_instr(a1),D0
	blo.s .ok
	move.l len_instr(a1),d0
	moveq #1,d1
	cmp.b #16,(typ_inst+1)(a1)
	bne.s .no
	add.w d1,d1
.no	btst #0,typ_inst(a1)
	beq.s .no2
	add.w d1,d1
.no2	sub.l d1,d0
.ok	move.l d0,spl_offset2(a1)
	RTS

do_phase8	tst.b d0
	beq.s .nostore
	move.b d0,data_phase8(a1)
.nostore	move.b data_phase8(a1),d0
	rts

do_extend_cmd
	move.w d0,d1
	lsr.w #4,d1
	and.w #$F,d0
	jsr ([rout2s,d1.w*4])	
	rts
	
do_extend_cmd2
	move.w d0,d1
	and.w #$F0,d1
	and.w #$F,d0
	cmp.w #$c0,d1	;note cut
	beq.s .note_cut
	cmp.w #$90,d1	;note retrig
	beq do_retrig
	cmp.w #$d0,d1	;note delay
	beq.s .note_delay
	rts

.note_delay	move.w note_brut(a1),d1
	beq.s .end
	sub.b speed(a6),d0	
	addq.b #1,d0
	add.b cpt(a6),d0
	bne.s .end
	moveq #0,d0		;cherche correspondance dans le tableau
	move.b fine_tune(a1),d0
	mulu #24*6,d0
	move.l ad_note(a1),a4
	add.l d0,a4
	move.w (a4),d5		;Note avec le Fine tune
.set	tst.l len_instr(a1)
	bne.s .inst_on
	clr.w d5
.inst_on	move.w d5,note(a1)		;Met la note
	move.w d5,note_actuel(a1)
	move.l spl_offset2(a1),sspl_pos(a1)
	rts

.note_cut	sub.b speed(a6),d0	
	addq.b #1,d0
	add.b cpt(a6),d0
	bne.s .end
	clr.b vol_instr(a1)
	clr.w vol_actuel(a1)
.end	rts
	
rout2s	dc.l do_maxvol,do_finepup,do_finepdown,do_setgliss,do_setvib
	dc.l do_setfinetune,do_jumploop,do_settrem,do_genvol,do_retrig,do_volfineup
	dc.l do_volfinedown,do_notecut,do_notedelay,do_pattdelay,do_funk
	
do_finepup	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end
	bsr do_pup
.end	rts

do_maxvol	tst.b d0
	beq.s .off
	cmp.b #1,d0
	beq.s .onmax
	cmp.b #2,d0
	beq.s .set_vol
	cmp.b #3,d0
	beq.s .set_max
	rts
	
.set_vol	st vol_mod+variable
	rts
	
.set_max	sf vol_mod+variable
	rts

.off	sf f_max
	rts

.onmax	st f_max
	rts

f_max	dc.w $FF00

do_genvol	rts

do_finepdown
	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end
	bsr do_pdown
.end	rts
	
do_setgliss	and.b #$F0,glissfunk(a1)
	or.b d0,glissfunk(a1)
	rts

do_setvib	and.b #$F0,wave_type(a1)
	or.b d0,wave_type(a1)
	rts

do_setfinetune
	move.b d0,fine_tune(a1)
	rts
	
do_jumploop	tst.b pass_e6(a6)
	bne.s .end
	st pass_e6(a6)
	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end		
	tst.b d0
	beq.s .set_loop
	tst.b loop_cpt(a6)
	beq.s .set_cpt
	subq.b #1,loop_cpt(a6)
	beq.s .end
.do_loop	move.w loop_pos(a6),break_pos(a6)
	st f_break(a6)
	rts

.set_cpt	move.b d0,loop_cpt(a6)
	bra.s .do_loop

.set_loop	moveq #0,d2
	move.w pattpos(a6),d2
	divu lg_lig_pat,d2
	move.w d2,loop_pos(a6)
.end	rts

do_settrem	lsl.b #4,d0
	and.b #$F,wave_type(a1)
	or.b d0,wave_type(a1)
	rts
	
do_retrig	
	rts

do_volfineup	
	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end		
	moveq #0,d2
	move.b vol_instr(a1),d2
	bsr do_volsup
.end	rts

do_volfinedown
	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end		
	moveq #0,d2
	move.b vol_instr(a1),d2
	move.w d0,d1
	bsr do_volsdwn
.end	rts

do_notecut	tst.b d0
	bne.s .end
	clr.b vol_instr(a1)
	clr.w vol_actuel(a1)
.end	rts
	
do_notedelay 
	sub.b speed(a6),d0
	add.b cpt(a6),d0
	beq.s .end		
	move.w note_brut(a1),d0
	and.w #$fff,D0
	beq.s .end
	lea a_arp,a4	;cherche correspondance dans le tableau
	moveq #36,d1
.cher	cmp.w (a4)+,d0
	dbeq d1,.cher
	tst.w d1
	bmi.s .end
	subq.w #2,a4
	moveq #0,d0
	move.b fine_tune(a1),d0
	mulu #24*6,d0
	add.l d0,a4
;	move.l adr_instr(a1),adr_actuel(a1)
	move.w (a4),note(a1)
	move.w (a4),note_actuel(a1)
.end	rts

do_pattdelay
	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end		
	tst.b patt_delay2(a6)
	bne.s .end
	addq.b #1,d0
	move.b d0,patt_delay(a6)
.end	rts

do_funk	

	rts

	
********************
* CALCULE LA NOTE  *
********************
	
****** DSP

calc_voice2	rts
	
Des_Stereo	dc.l data_voice+(0*end2),0,data_voice+(1*end2),1
	dc.l data_voice+(3*end2),3,data_voice+(2*end2),2
	dc.l data_voice+(4*end2),4,data_voice+(5*end2),5
	dc.l data_voice+(7*end2),7,data_voice+(6*end2),6
	dc.l data_voice+(8*end2),8,data_voice+(9*end2),9
	dc.l data_voice+(11*end2),11,data_voice+(10*end2),10
	dc.l data_voice+(12*end2),12,data_voice+(13*end2),13
	dc.l data_voice+(15*end2),15,data_voice+(14*end2),14
	dc.l data_voice+(16*end2),16,data_voice+(17*end2),17
	dc.l data_voice+(19*end2),19,data_voice+(18*end2),18
	dc.l data_voice+(20*end2),20,data_voice+(21*end2),21
	dc.l data_voice+(23*end2),23,data_voice+(22*end2),22
	dc.l data_voice+(24*end2),24,data_voice+(25*end2),25
	dc.l data_voice+(27*end2),27,data_voice+(26*end2),26
	dc.l data_voice+(28*end2),28,data_voice+(29*end2),29
	dc.l data_voice+(31*end2),31,data_voice+(30*end2),30
	
Des_Stereo_st
I	SET 0
	rept 32
	dc.l data_voice+(I*end2),I
I	SET I+1
	endr
	
Analyse_voices
	lea Tempo_tab,a1
	add.w _thefreq,a1
	move.w Tempo_sng+variable,d6
	move.w (a1,d6.w*2),d6
	move.w d6,nb_loop+variable
	
	moveq #0,d7
	move.w nb_voie,d7
	lea precalc_voice,a1
	lea Des_Stereo,a0
	tst.b base
	beq .loop
	lea Des_Stereo_st,a0
.loop	move.l (a0)+,a5
	move.l #$80,d0
	lea $ffffa206.w,a2
	cmp.b #16,(typ_inst+1)(a5)
	beq .16bits
	lea 1(a2),a2
	lsl.l #8,d0
.16bits	move.l a2,(a1)+ 	;adresse dsp...
	move.l d0,(a1)+	;decalage...
	clr.l d4
	move.w vol_actuel(a5),d4
	move.l f_hp,d0
	move.l (a0)+,d1
	btst d1,d0
	bne.s .no
	clr.w vol_actuel(a5)
	clr.w d4
.no	tst.b base
	beq.s .no_base1
	moveq #0,d0
	move.b data_phase8(a5),d0
	and.b #$F,d0
	addq.w #1,d0
	move.w d4,d1
	mulu d0,d4
	lsr.l #4,d4
	mulu vol_mod+variable+2,d4
	lsr.l #6,d4
	move.l d4,(a1)+	;volume du sample
	moveq #0,d0
	move.b data_phase8(a5),d0
	lsr.w #4,d0
	addq.w #1,d0
	mulu d0,d1
	lsr.l #4,d1
	mulu vol_mod+variable+2,d1
	lsr.l #6,d1
	move.l d1,(a1)+
	bra.s .suite
.no_base1	mulu vol_mod+variable+2,d4
	lsr.l #6,d4
	move.l d4,(a1)+		;volume du sample
.suite	
	move.l old_calc(a5),(a1)+
	clr.l d2
	clr.l d3
	move.l #50066,d1
	cmp.w #2,_thefreq+2
	bne.s .c50
	move.l #25033,d1
.c50	cmp.w #4,_thefreq+2
	bne.s .c25
	move.l #20770,d1
.c25	mulu note_actuel(A5),d1
	beq.s .nul_note
	move.l freq_inst(a5),d2
	move.w mid_inst(a5),d0
	sub.w #24,d0
	bpl.s .ok_midi
	clr.w d0
.ok_midi	move.w (a_arp,d0.w*2),d0
	mulu d0,d2		;Frq base * Note base
	clr.l d0
	divu.l d1,d0:d2	;Entier dans d2
	divu.l d1,d0:d3	;Reel dans d3
.nul_note	move.l d3,(a1)+	;Partie reelle du pas...
	move.l d2,(a1)+ 	;Partie entiere du pas
	move.l adr_instr(a5),d4
	add.l sspl_pos(a5),d4
	move.l d4,(a1)+	;Adresse instr

	clr.l d4
	MOVE.W nb_loop+variable,D4
	subq.w #1,d4
	move.l d4,(a1)+	;Nombre d'iterations
	addq.w #1,d4
	lsr.l #3,d4		
	subq.w #1,d4
	move.w d4,(a1)+	;/16
	move.w typ_inst(a5),(a1)+
	
	MOVE.W nb_loop+variable,D4
	and.w #7,d4
	lsl.w #3,d4
	add.w #10,d4
	neg.w d4
	move.w d4,(a1)+	;Modulo 16
	move.w #2,(a1)+	;Pour le JUMP !!!
	dbra d7,.loop
	
	tst.b base
	bne.s .st
	jsr New_calc_voice
	bra.s .suite2
.st	jsr New_calc_voice_st
.suite2
	ifne TEMPS
	move.l #$ffff00,$ffff9800.w
	endc
	moveq #0,d7
	move.w nb_voie,d7
	lea result_voice,a1
	lea Des_Stereo,a0
	tst.b base
	beq .result
	lea Des_Stereo_st,a0
.result	move.l (a0)+,a5
	addq.w #4,a0
	move.l (a1)+,old_calc(a5)
	move.l (a1)+,d3
	move.l #258,d4
	cmp.b #8,(typ_inst+1)(a5)
	beq.s .8bits
	add.l d3,d3
	add.l d4,d4
.8bits	btst #0,typ_inst(a5)
	beq.s .mono
	add.l d3,d3
	add.l d4,d4
.mono	add.l sspl_pos(a5),d3
	move.l d3,d1		;longueur qui a ete joue
	sub.l len_instr(a5),d3
	bmi.s .SUP03
	cmp.l #4,rep_len(a5)
	bls.s .nul03
	divul.l rep_len(a5),d4:d3	;Divise par replen
	move.l rep_start(a5),d1		;Repeat
	add.l d4,d1			;+ce qui est deja joue
.SUP03	MOVE.L d1,sspl_pos(A5)
	dbra d7,.result
	rts

.nul03	move.l rep_start(a5),d1		;Repeat
	add.l d4,d1			;+ce qui est deja joue
	MOVE.L d1,sspl_pos(A5)
	clr.w note_actuel(a5)
	dbra d7,.result
	rts
	
New_calc_voice
	moveq #0,d7
	move.w nb_voie,d7
	lea precalc_voice,a1
	lea $ffffa204.w,a2
	lea -2(a2),a3
	lea 2(a2),a5
	lea result_voice,a6
.loop_voice	move.l (a1)+,a0	;adresse dsp
	btst #1,(a3)
	beq.s *-4
	move.l (a1)+,(a2)	;Envoi le decalage
	move.l (a1)+,(a2)	;Envoi le volume
	move.l (a1)+,d6	;old calc
	move.l (a1)+,d1	;Prend la partie relle du pas
	move.l (a1)+,d0	;Partie entiere du pas
	clr.l d3
	move.l (a1)+,a4	;Adresse du sample
	btst #1,(a3)
	beq.s *-4
	move.l (a1)+,(a2)	;Envoi le nombre d'it...
	move.w (a1)+,d5
	btst #1,(a3)
	beq.s *-4
	move.w (a1)+,d2
	cmp.b #16,d2
	beq .16
	btst #8,d2
	bne .st8
.loop_send	
	rept 8
	move.b (a4,d3.l),(a0)
	add.l d1,d6
	addx.l d0,d3
	endr
	dbra d5,.loop_send
	clr.w d5
	move.w (a1)+,d2
	jmp (pc,d2.w)
	bra .next
.st8	btst #15,d2
	beq.s .loop_sendst8
	addq.w #1,a4
.loop_sendst8
	rept 8
	move.b (a4,d3.l*2),(a0)
	add.l d1,d6
	addx.l d0,d3
	endr
	dbra d5,.loop_sendst8
	clr.w d5
	move.w (a1)+,d2
	jmp (pc,d2.w)
	bra .next
.16	btst #8,d2
	bne .st16
.loop_send16 
	rept 8
	move.w (a4,d3.l*2),(a0)
	add.l d1,d6
	addx.l d0,d3
	endr
	dbra d5,.loop_send16
	clr.w d5
	move.w (a1)+,d2
	jmp (pc,d2.w)
	bra .next
.st16	btst #15,d2
	beq.s .loop_sendst16
	addq.w #2,a4
.loop_sendst16
	rept 8
	move.w (a4,d3.l*4),(a0)
	add.l d1,d6
	addx.l d0,d3
	endr
	dbra d5,.loop_sendst16
	clr.w d5
	move.w (a1)+,d2
	jmp (pc,d2.w)
.next	move.l d6,(a6)+
	move.l d3,(a6)+
	dbra d7,.loop_voice
	rts
	
New_calc_voice_st
	moveq #0,d7
	move.w nb_voie,d7
	lea precalc_voice,a1
	lea $ffffa204.w,a2
	lea -2(a2),a3
	lea 2(a2),a5
	lea result_voice,a6
.loop_voice	move.l (a1)+,a0	;adresse dsp
	move.l (a1)+,(a2)	;Envoi le decalage
	move.l (a1)+,(a2)	;Envoi le volume
	move.l (a1)+,(a2)	;Envoi le volume
	move.l (a1)+,d6	;old calc
	move.l (a1)+,d1	;Prend la partie relle du pas
	move.l (a1)+,d0	;Partie entiere du pas
	clr.l d3
	move.l (a1)+,a4	;Adresse du sample
	btst #1,(a3)
	beq.s *-4
	move.l (a1)+,(a2)	;Envoi le nombre d'it...
	move.w (a1)+,d5
	btst #1,(a3)
	beq.s *-4
	move.w (a1)+,d2
	cmp.b #16,d2
	beq.s .16
	btst #1,(a3)
	beq.s *-4
.loop_send	
	rept 8
	move.b (a4,d3.l),(a0)
	add.l d1,d6
	addx.l d0,d3
	endr
	dbra d5,.loop_send
	clr.w d5
	move.w (a1)+,d2
	jmp (pc,d2.w)
	bra .next
.16	
	rept 8
	move.w (a4,d3.l*2),(a0)
	add.l d1,d6
	addx.l d0,d3
	endr
	dbra d5,.16
	clr.w d5
	move.w (a1)+,d2
	jmp (pc,d2.w)
.next	move.l d6,(a6)+
	move.l d3,(a6)+
	dbra d7,.loop_voice
	rts
	
do_note:	lea tab_convert+($390*4),a0
	lea a_arp+24,a2
	move.w #$38f,d2
	moveq #0,d6		;Compte les demi-tons
	move.w #$1F00,d5	;Pour new format !!!	
.loop	tst.w d2
	beq.s .stop
	move.l d5,-(a0)
	cmp.w (a2),d2
	bne.s .no_oct
	addq.w #2,a2
	add.w #$100,d5
	subq.w #1,d6
	bpl.s .no
	and.w #$F000,d5
	or.w #$100,d5	;Note commence a 1 !!!
	add.w #$1000,d5	;Octave suivant !!!
	moveq #11,d6
.no	move.l d5,(a0)
.no_oct	dbra d2,.loop
.stop	clr.l -(a0)
	rts

;---------------	

init_adc
		move.l	$ffff8938.w,-(sp)
		move.w	#1,-(sp)
		move.w	#140,-(sp)
		trap	#14
		addq.w	#4,sp
		move.l	(sp)+,$ffff8938.w

		bsr	PUT_OFF

		move.w	#1,-(sp)
		move.w	#1,-(sp)
		move.w	#137,-(sp)
		trap	#14
		addq.w	#6,sp

		clr.w	-(sp)		; 2 tracks stereo
		clr.w	-(sp)
		move.w	#$85,-(sp)
		trap	#14
		addq.w	#6,sp
					
	move.W	#%00,-(A7)	;Input from
	MOVE.W	#5,-(A7)
	MOVE.W	#$82,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	clr.W	-(A7)	;Input from
	MOVE.W	#6,-(A7)
	MOVE.W	#$82,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	move.W	#0,-(A7)	;Montrack 0
	MOVE.W	#$86,-(A7)
	TRAP	#14
	ADDQ.L	#4,A7
	
	move.w #2,-(sp)	;Matrix
	move.w #4,-(sp)
	move.w #$82,-(sp)
	trap #14
	addq.w #6,sp
	
	move.w 	#1,-(sp)
	move.w 	#0,-(sp)
	move.w 	#0,-(sp)
	move.w 	#4,-(sp)	;2 DSPRCV    8  DAC
	move.w 	#0,-(sp)
	move.w 	#$8b,-(sp)
	trap 	#14
	lea 	12(sp),sp
	
	move.w #2,-(sp)	;Matrix
	move.w #4,-(sp)
	move.w #$82,-(sp)
	trap #14
	addq.w #6,sp
	
	move.w 	#1,-(sp)
	move.w 	#0,-(sp)
	move.w 	#0,-(sp)
	move.w 	#8,-(sp)
	move.w 	#1,-(sp)
	move.w 	#$8b,-(sp)
	trap 	#14
	lea 	12(sp),sp
	
	move.w #1,-(sp)
	move.w #1,-(sp)
	move.w #137,-(sp)
	trap #14
	addq.w #6,sp
	
	MOVE.W	#3,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$87,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	move.w #1,-(sp)	;16 Bits
	move.w #$84,-(sp)
	trap #14
	addq.w #4,sp
	
	RTS

;---------------

PUT_OFF
		clr.w	-(sp)
		move.w	#$88,-(sp)
		trap	#14
		addq.w	#4,sp
		rts

;---------------

SDMA_INT
		move.w	d1,-(sp)
		clr.w	-(sp)
		move.w	#$87,-(sp)
		trap	#14
		addq.w	#6,sp
		rts

;---------------

; Reconstruit le repeat apres modif de itlenght,restart ou replen
; ou chargement d'un sample

Redo_repeat	
	movem.l d0-d7/a0-a6,-(sp)
	move.w d1,d6
	lea variable,a5
	move.w d6,d1
	add.w #128,d1
	subq.w #1,d6
	mulu #end_inst,d6
	lea sample(a5,d6.w),a0
	
	move.l (tab_adr_blk.l,d1.w*4),a1	;adresse instr
	move.l len_inst(a0),d0		;len
	move.l repstart_inst(a0),d1	;repeat start
	move.l replen_inst(a0),d2	;repeat len
	move.w type_inst(a0),d3		;Type instr
	lea (a1),a2
	lea (a1,d0.l),a1		;Fin instr
	add.l d1,a2			;debut repeat
	lea (a2),a0	
	
	subq.l #1,d2
	cmp.b #16,d3	;16 bits
	beq.s .16
	move.w #1249,d4
	subq.l #1,d0
	cmp.l d1,d0
	beq.s .no_repeat8
	move.l d2,d3
.copie	
	rept 4
	move.b (a2)+,(a1)+	;copie le repeat
	subq.l #1,d3
	bpl.s *+6
	move.l d2,d3
	move.l a0,a2
	endr
	dbra d4,.copie
	movem.l (sp)+,d0-d7/a0-a6
	rts
	
.16	move.w #1249,d4
	subq.l #2,d0
	cmp.l d1,d0
	beq .no_repeat16
	move.l d2,d3
.copie16	
	rept 4
	move.w (a2)+,(a1)+	;copie le repeat
	subq.l #1,d3
	bpl.s *+6
	move.l d2,d3
	move.l a0,a2
	endr
	dbra d4,.copie16
	movem.l (sp)+,d0-d7/a0-a6
	rts	

; Cette routine centralise le DMA sonore x => 0
.no_repeat8	moveq #0,d0
	move.b (a2),d0
	beq.s .raz8
	bmi.s .neg8
	sub.w d0,d4
	subq.w #1,d0
.central8	
	rept 4
	move.b d0,(a1)+
	endr
	dbra d0,.central8
	moveq #0,d0
.raz8	
	rept 4
	move.b d0,(a1)+
	endr
	dbra d4,.raz8
	movem.l (sp)+,d0-d7/a0-a6
	rts
	
.neg8	ext.w d0
	neg.w d0
	sub.w d0,d4
	subq.w #1,d0
.central82	
	rept 4
	move.b d0,d1
	neg.b d1
	move.b d1,(a1)+
	endr
	dbra d0,.central82
	moveq #0,d0
	bra.s .raz8
	
.no_repeat16
	moveq #0,d0
	move.b (a2),d0
	beq.s .raz16
	bmi.s .neg16
	sub.w d0,d4
	subq.w #1,d0
.central16	
	rept 4
	move.w d0,(a1)+
	endr
	dbra d0,.central16
	moveq #0,d0
.raz16	
	rept 4
	move.w d0,(a1)+
	endr
	dbra d4,.raz16
	movem.l (sp)+,d0-d7/a0-a6
	rts
	
.neg16	ext.w d0
	neg.w d0
	sub.w d0,d4
	subq.w #1,d0
.central162	
	rept 4
	move.b d0,d1
	neg.b d1
	ext.w d1
	move.w d1,(a1)+
	endr
	dbra d0,.central162
	moveq #0,d0
	bra.s .raz16

; Pour definitions des instruments...(du mod et du buff)
	rsreset
index_inst		rs.l 1	;index de l'instrument ds la table des blks...
len_inst		rs.l 1	;longueur
fine_inst		rs.b 1	;finetune
vol_inst		rs.b 1	;volume
repstart_inst	rs.l 1	;Repeat start
replen_inst		rs.l 1	;Repeat len
name_inst		rs.w 11	;22 octets pour le nom...
type_inst		rs.w 1	;.B hight : 0 = MONO 1 = STEREO
			;.B low : 8,12,16 bits
midi_inst		rs.l 1	;Note midi
frq_inst		rs.l 1	;Frequence en millier de hz
end_inst		rs.b 1
	
	rsreset
adr_pos		rs.l 1	;ADR pos et pattern pour le module...
adr_patt		rs.l 1
nbr		rs.w 1
sample		rs.b 64*end_inst	; !!! Ne pas separer...

speed		rs.b 1	; !!!
cpt		rs.b 1	; !!!
Tempo_sng		rs.w 1	; !!!!
songpos		rs.b 1	; !!!!
songrep		rs.b 1	; !!!
nbsongpos		rs.w 1	; !!!
pattpos		rs.w 1	; !!!!

nb_loop		rs.w 1
patt_delay2		rs.b 1
patt_delay		rs.b 1
f_break		rs.b 1	;Flag pour break
loop_pos		rs.w 1	;Position pour le loop
break_pos		rs.w 1	;Position pour le break
loop_cpt		rs.b 1	;Compteur pour le loop
pass_e6		rs.b 1
loc_break		rs.b 1
loc_pos		rs.w 1
loc_lig		rs.w 1
vol_mod		rs.l 1
end		rs.b 1

	rsreset
ligne		rs.l 1
adr_instr		rs.l 1
len_instr		rs.l 1
fine_tune		rs.b 1
vol_instr		rs.b 1
rep_start		rs.l 1
rep_len		rs.l 1
note		rs.w 1
note_brut		rs.w 1
old_calc		rs.l 1
vit_pdown		rs.w 1
data_vib		rs.b 1	***Vibrato
cpt_vib		rs.b 1
data_tre		rs.b 1	***Tremolo
cpt_tre		rs.b 1
port_vit		rs.b 1	***Portamento
port_dir		rs.b 1
port_dest		rs.w 1
data_phase8		rs.b 1	***8 et 9 Phase effets
data_phase9		rs.b 1

note_actuel		rs.w 1
vol_actuel		rs.w 1
sspl_pos		rs.l 1
glissfunk		rs.b 1
wave_type		rs.b 1
freq_inst		rs.l 1
typ_inst		rs.w 1
mid_inst		rs.w 1
spl_offset2		rs.l 1
ad_note		rs.l 1
end2		rs.b 1

;--------------------------------------

kilo		dc.l	10
nb_voie		dc.w	7
f_hp		dc.l	-1
len_pat		dc.w	$800
lig_pat		dc.w	64,64
base		dc.w	8
lg_lig_pat	dc.w	32,32
_thefreq	dc.w	512,3,3
decalage	dc.l	$008000
offset_voie	dc.l	0
nb_voie_max	dc.w	7
stereo_put?	dc.l	0
memoire		dcb.l	9*2

;---------------

		ifne menuedata_load

Tempo_tab	
		incbin	"include\menu\tempo.tab"

		dc.w 0,0,0

a_arp		dc.w 856*2,808*2,762*2,720*2,678*2,640*2,604*2,570*2,538*2,508*2,480*2,453*2
		dc.w 856,808,762,720,678,640,604,570,538,508,480,453
		dc.w 428,404,381,360,339,320,302,285,269,254,240,226
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
		dc.w 107,101,095,090,085,080,076,071,068,063,060,057
		dc.w 053,050,048,045,042,040,038,035,034,031,030,029
;1
		dc.w 850*2,802*2,757*2,715*2,674*2,637*2,601*2,567*2,535*2,505*2,477*2,450*2
		dc.w 850,802,757,715,674,637,601,567,535,505,477,450
		dc.w 425,401,379,357,337,318,300,284,268,253,239,225
		dc.w 213,201,189,179,169,159,150,142,134,126,119,113
		dc.w 106,100,094,089,084,079,075,071,067,063,059,057
		dc.w 106/2,100/2,094/2,089/2,084/2,079/2,075/2,071/2,067/2,063/2,059/2,057/2
;2
		dc.w 844*2,796*2,752*2,709*2,670*2,632*2,597*2,563*2,532*2,502*2,474*2,447*2
		dc.w 844,796,752,709,670,632,597,563,532,502,474,447
		dc.w 422,398,376,355,335,316,298,282,266,251,237,224
		dc.w 211,199,188,177,167,158,149,141,133,125,118,112
		dc.w 105,099,094,088,083,079,075,070,066,062,059,056
		dc.w 105/2,099/2,094/2,088/2,083/2,079/2,075/2,070/2,066/2,062/2,059/2,056/2
;3
		dc.w 838*2,791*2,746*2,704*2,665*2,628*2,592*2,559*2,528*2,498*2,470*2,444*2
		dc.w 838,791,746,704,665,628,592,559,528,498,470,444
		dc.w 419,395,373,352,332,314,296,280,264,249,235,222
		dc.w 209,198,187,176,166,157,148,140,132,125,118,111
		dc.w 105,099,093,088,083,078,074,070,066,062,059,055
		dc.w 105/2,099/2,093/2,088/2,083/2,078/2,074/2,070/2,066/2,062/2,059/2,055/2
;4
		dc.w 832*2,785*2,741*2,699*2,660*2,623*2,588*2,555*2,524*2,495*2,467*2,441*2
		dc.w 832,785,741,699,660,623,588,555,524,495,467,441
		dc.w 416,392,370,350,330,312,294,278,262,247,233,220
		dc.w 208,196,185,175,165,156,147,139,131,124,117,110
		dc.w 104,098,093,087,082,078,073,069,065,062,059,055
		dc.w 104/2,098/2,093/2,087/2,082/2,078/2,073/2,069/2,065/2,062/2,059/2,055/2
;5
		dc.w 826*2,779*2,736*2,694*2,655*2,619*2,584*2,551*2,520*2,491*2,463*2,437*2
		dc.w 826,779,736,694,655,619,584,551,520,491,463,437
		dc.w 413,390,368,347,328,309,292,276,260,245,232,219
		dc.w 206,195,184,174,164,155,146,138,130,123,116,109
		dc.w 103,097,092,087,082,077,073,069,065,000,058,054
		dc.w 103/2,097/2,092/2,087/2,082/2,077/2,073/2,069/2,065/2,000/2,058/2,054/2
;6
		dc.w 820*2,774*2,730*2,689*2,651*2,614*2,580*2,547*2,516*2,487*2,460*2,434*2
		dc.w 820,774,730,689,651,614,580,547,516,487,460,434
		dc.w 410,387,365,345,325,307,290,274,258,244,230,217
		dc.w 205,193,183,172,163,154,145,137,129,122,115,109
		dc.w 102,096,092,086,082,077,072,068,065,061,057,054
		dc.w 102/2,096/2,092/2,086/2,082/2,077/2,072/2,068/2,065/2,061/2,057/2,054/2
;7
		dc.w 814*2,768*2,725*2,684*2,646*2,610*2,575*2,543*2,513*2,484*2,457*2,431*2
		dc.w 814,768,725,684,646,610,575,543,513,484,457,431
		dc.w 407,384,363,342,323,305,288,272,256,242,228,216
		dc.w 204,192,181,171,161,152,144,136,128,121,114,108
		dc.w 102,095,091,085,081,076,072,068,064,060,057,054
		dc.w 102/2,095/2,091/2,085/2,081/2,076/2,072/2,068/2,064/2,060/2,057/2,054/2
;-8
		dc.w 907*2,856*2,808*2,762*2,720*2,678*2,640*2,604*2,570*2,538*2,508*2,480*2
		dc.w 907,856,808,762,720,678,640,604,570,538,508,480
		dc.w 453,428,404,381,360,339,320,302,285,269,254,240
		dc.w 226,214,202,190,180,170,160,151,143,135,127,120
		dc.w 113,107,101,095,090,085,080,075,072,067,064,060
		dc.w 113/2,107/2,101/2,095/2,090/2,085/2,080/2,075/2,072/2,067/2,064/2,060/2
;-7
		dc.w 900*2,850*2,802*2,757*2,715*2,675*2,636*2,601*2,567*2,535*2,505*2,477*2
		dc.w 900,850,802,757,715,675,636,601,567,535,505,477
		dc.w 450,425,401,379,357,337,318,300,284,268,253,238
		dc.w 225,212,200,189,179,169,159,150,142,134,126,119
		dc.w 113,106,100,095,090,084,080,075,071,067,063,060
		dc.w 113/2,106/2,100/2,095/2,090/2,084/2,080/2,075/2,071/2,067/2,063/2,060/2
;-6
		dc.w 894*2,844*2,796*2,752*2,709*2,670*2,632*2,597*2,563*2,532*2,502*2,474*2
		dc.w 894,844,796,752,709,670,632,597,563,532,502,474
		dc.w 447,422,398,376,355,335,316,298,282,266,251,237
		dc.w 223,211,199,188,177,167,158,149,141,133,125,118
		dc.w 112,105,100,094,089,083,079,074,070,066,063,059
		dc.w 112/2,105/2,100/2,094/2,089/2,083/2,079/2,074/2,070/2,066/2,063/2,059/2
;-5
		dc.w 887*2,838*2,791*2,746*2,704*2,665*2,628*2,592*2,559*2,528*2,498*2,470*2
		dc.w 887,838,791,746,704,665,628,592,559,528,498,470
		dc.w 444,419,395,373,352,332,314,296,280,264,249,235
		dc.w 222,209,198,187,176,166,157,148,140,132,125,118
		dc.w 111,104,099,094,088,083,078,074,070,066,062,059
		dc.w 111/2,104/2,099/2,094/2,088/2,083/2,078/2,074/2,070/2,066/2,062/2,059/2
;-4
		dc.w 881*2,832*2,785*2,741*2,699*2,660*2,623*2,588*2,555*2,524*2,494*2,467*2
		dc.w 881,832,785,741,699,660,623,588,555,524,494,467
		dc.w 441,416,392,370,350,330,312,294,278,262,247,233
		dc.w 220,208,196,185,175,165,156,147,139,131,123,117
		dc.w 110,104,098,093,087,082,078,073,069,065,061,058
		dc.w 110/2,104/2,098/2,093/2,087/2,082/2,078/2,073/2,069/2,065/2,061/2,058/2
;-3
		dc.w 875*2,826*2,779*2,736*2,694*2,655*2,619*2,584*2,551*2,520*2,491*2,463*2
		dc.w 875,826,779,736,694,655,619,584,551,520,491,463
		dc.w 437,413,390,368,347,328,309,292,276,260,245,232
		dc.w 219,206,195,184,174,164,155,146,138,130,123,116
		dc.w 109,103,097,092,087,082,077,073,069,065,061,058
		dc.w 109/2,103/2,097/2,092/2,087/2,082/2,077/2,073/2,069/2,065/2,061/2,058/2
;-2
		dc.w 868*2,820*2,774*2,730*2,689*2,651*2,614*2,580*2,547*2,516*2,487*2,460*2
		dc.w 868,820,774,730,689,651,614,580,547,516,487,460
		dc.w 434,410,387,365,345,325,307,290,274,258,244,230
		dc.w 217,205,193,183,172,163,154,145,137,129,122,115
		dc.w 108,102,096,091,086,081,077,072,068,064,061,057
		dc.w 108/2,102/2,096/2,091/2,086/2,081/2,077/2,072/2,068/2,064/2,061/2,057/2
;-1
		dc.w 862*2,814*2,768*2,725*2,684*2,646*2,610*2,575*2,543*2,513*2,484*2,457*2
		dc.w 862,814,768,725,684,646,610,575,543,513,484,457
		dc.w 431,407,384,363,342,323,305,288,272,256,242,228
		dc.w 216,203,192,181,171,161,152,144,136,128,121,114
		dc.w 108,101,096,090,085,080,076,072,068,064,060,057
		dc.w 108/2,101/2,096/2,090/2,085/2,080/2,076/2,072/2,068/2,064/2,060/2,057/2

a_arp_end
		endc

Funktable 	dc.b 	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

a_sin		dc.b 	$00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		dc.b 	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

my_arp_null	dc.b 	0

		dc.b	 $21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21
my_arp		dc.b	 $21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c
		dc.b	 $31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c
		dc.b	 $41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c
		dc.b	 $51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c
		dc.b	 $61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c
		dc.b	 $71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c
		dc.b	 $7c,$7c,$7c,$7c,$7c,$7c,$7c,$7c,$7c,$7c,$7c,$7c

		cnop 0,4

;--------------------------------------

		ifne menuedata_load

s_sr		ds.w	 1
s_pc		ds.w	 1
s_register	ds.l	 16
f_freq_change	ds.b	 1
		ds.b	 1
name_mod	ds.w	 11		; Nom du module...
base_frq	ds.l	 1
base_bit	ds.l	 1
buffer		ds.l	 2
digit1		ds.l	 2000
digit2		ds.l	 2000
tab_convert	ds.l	 $390
convert_note	ds.l	 16
hexa_dec	ds.l	 16
precalc_voice	ds.l	 17*32
result_voice	ds.l	 4*32
table_patt	ds.b	 128
table_patt2	ds.b 	128		;Sert pour sauver un .MOD
list_inst	ds.w	 128		;Sert pour sauver chunk inst
nb_lig_patt	ds.l 	128		;Nombre de ligne pour chaque pattern
					;Et indique si la pattern est cree...

***** Decrit toutes les variables du player...

variable	ds.b 	end	
data_voice	ds.b	32*end2

		endc