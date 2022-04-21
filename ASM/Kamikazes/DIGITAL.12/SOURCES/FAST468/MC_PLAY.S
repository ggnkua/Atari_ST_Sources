**** Player de module 4,6 ou 8 voies au DSP ***
**** Vous pouvez jouer des modules Amiga, Fastracker (PC) ou
**** Digital TRacker ancien format...

***** En Rouge = le temps du 68030
***** En bleu + Rouge = le temps DSP !!

**** MC JEE / KAMIKAZES

NB_VOIE	equ 8	;Nombre de voies du module
OLD_FA0X	equ 0	;Si le module est un ancien digital tracker +4 (sinon 0)

Debut	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1		shrink memory
	lea	12(sp),sp

	bsr do_note
	bsr init_adc

	move.w #113,-(sp)
	trap #14
	addq.w #2,sp
	move.w d0,ability

	move.l #buffer_dsp,-(sp)
	move.w ability,-(sp)
	pea fname
	move.w #108,-(sp)
	trap #14
	add.w #12,sp
	
	move.l #buff,p_module
	bsr init_mod
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	move.l d0,old_sp
	addq.w #6,sp
	
	
	bsr joue

.wait	cmp.b #$39,$fffffc02.w
	bne.s .wait
	
	bsr jouepas
	
	move.l old_sp,-(sp)
	move.w #32,-(sp)
	trap #1
	addq.w #6,sp
	
	clr.w -(sp)
	trap #1
	
	
Var_global	dc.l digit1
	dc.l digit2
	dc.l volume_table
	dc.l note_table
dsp_on	dc.l 1




**** L'init du mod est babare mais le principe est la...
***
**
*	
init_mod:	move.l p_module,a0
	lea 42(a0),a3		;pointe description instr
	lea $3b8(a0),a5		;position
	lea ($43C+OLD_FA0X)(a0),a4		;pattern
	move.w #31,nbr+variable
	move.l a5,adr_pos+variable
	move.l a4,adr_patt+variable
	moveq #$7f,d0
	moveq #0,d1
.next	cmp.b (a5)+,d1
	bhi.s .sup
	move.b -1(a5),d1
.sup	dbra d0,.next
	addq.w #1,d1	;Nombre de pattern
	moveq #0,d2
	mulu len_pat(pc),d1
	
	lea (a4),a2		;Debut patterns
	add.l d1,a4		;debut instrument
	
	lea sample+variable(pc),a5	
	move.w nbr+variable(pc),d7
	subq.w #1,d7
.next_inst	move.l a4,(a5)+	;adresse instrument	4(0)
	moveq #0,d0
	move.w (a3),d0
	add.l d0,d0		;len en octet
	move.l d0,(a5)+	;longueur instrument	8(4)
	move.b 2(a3),(a5)+	;Finetune
	move.b 3(a3),(a5)+	;Volume		10(8)
	moveq #0,d1
	move.w 4(a3),d1
	add.l d1,d1		;repeat start en octet
	move.l d1,(a5)+	;repeat start instrument14(10)	
	moveq #0,d2
	move.w 6(a3),d2
	add.l d2,d2		;repeat len en octet	18(14)
	cmp.l #2,d2
	bne.s .repeat
	clr.l d2
	move.l d0,-4(a5)	;Repeat start = len instr
	subq.l #1,-4(a5)
.repeat	cmp.l d0,d2		;Compare len et rep len
	ble.s .okrepl
	move.l d0,d2
.okrepl	cmp.l -4(a5),d0		;Compare rep start et len
	bge.s .okreps
	move.l d0,-4(a5)	;Len instr - rep len dans rep start
	sub.l d2,-4(a5)
.okreps	move.l d2,(a5)+		;repeat len instrument
	add.l d0,a4		;adresse instr suivant
	add.l #5000,a4		;+ place pour le repeat
	lea 30(a3),a3
	dbra d7,.next_inst
	
	move.w nbr+variable(pc),d7
	move.w d7,d6
	mulu #5000,d6
	subq.w #1,d7
	sub.l d6,a4		;fin du module...
.next_ist2	move.l -(a5),d2	;repeat len
	move.l -(a5),d1	;repeat start
	move.w -(a5),d0
	move.l -(a5),d0	;len
	move.l -(a5),a1	;adresse instr
	lea (a4),a2
	
	add.l d0,a1
	move.l d0,d5	;Copie l'instrument
	beq.s .null
	subq.l #1,d5
.cop1	move.b -(a2),-(a1)
	dbra d5,.cop1
	
.null	lea (a1),a2		;+
	add.l d0,a1
	add.l d1,a2		;debut repeat
	lea (a2),a0	
	
	subq.l #1,d2
	move.l d2,d3
	move.w #4999,d4
.copie	move.b (a2)+,(a1)+	;copie le repeat
	subq.l #1,d3
	bpl.s .not_f_r
	move.l d2,d3
	move.l a0,a2
.not_f_r	dbra d4,.copie
	
	sub.l d0,a4
	dbra d7,.next_ist2
	
suite	lea speed+variable(pc),a0
	move.b #6,(a0)+		;vitesse
	move.b #0,(a0)+	;Cpt
	move.w #125,(a0)+	;Tempo
	move.b #0,(a0)+	;Songpos
	move.l adr_pos+variable(pc),a4		
	move.b -1(a4),d0
	move.b d0,(a0)+	;Songrep
	move.b -2(a4),d0
	move.b d0,(a0)+	;Nbsongpos
	addq.w #1,a0
	clr.w (a0)+		;Pattpos
	
	bsr Raz_sound_mod
	rts
	
Raz_sound_mod
	move.l Var_global(pc),a0
	move.l (Var_global+4)(pc),a1
	move.w #1999,d7
.eff	clr.l (a0)+
	clr.l (a1)+
	dbra d7,.eff

	lea data_voice(pc),a1
	move.w nb_voie(pc),d7
.init	move.l sample+variable(pc),adr_instr(a1)
	move.l sample+variable(pc),adr_actuel(a1)
	move.w #$100,note_actuel(a1)
	add.w #end2,a1
	dbra d7,.init
	rts


**********************************
*  PLAYER DE MODULES !!!!!!!!!!! *
**********************************
joue	lea $ffff8900.w,a0
	moveq #0,d2	
	MOVE.L Var_global(pc),D0
	move.l d0,d1
	add.l #1000*4,d0
	
	clr.b 1(a0)		;OFF
	movep.l d1,1(a0)	;adr deb
	movep.l d0,$D(a0)	;adr fin
	
	moveq #3,d7		;Freq
	bsr Sdma_freq
	st f_first
	move.w #$503,(a0)		;PLay & Repeat
	
	lea player(pc),a0
	move.l $13C.w,-4(a0)
	move.l a0,$13C.w
	
	bset #7,$fffffa07.w	;Let's go
	bset #7,$fffffa13.w
	RTS

jouepas	lea $ffff8900.w,a0
	clr.b 1(a0)
	bclr #7,$fffffa07.w
	bclr #7,$fffffa13.w
	move.l (player-4)(pc),$13C.w
	move.w #1,-(sp)
	move.w #140,-(sp)
	trap #14
	addq.w #4,sp
	RTS
	
;d7 =freq
Sdma_freq	lea $ffff8900.w,a0
	and.b #$F0,$34(a0)
	or.b #1,$34(a0)
	and.b #$F0,$35(a0)
	or.b #1,$35(a0)
;	or.w d7,$20(a0)
	rts

	dc.l 0
player	bclr #7,$fffffa0f.w
	movem.l d0-d7/a0-a6,-(sp)
	move.l #$F0000000,$ffff9800.w
	move.w #$F00,$ffff8240.w
	move.l Var_global(pc),d0
	move.l (Var_global+4)(pc),Var_global
	move.l d0,Var_global+4
	
	move.l Var_global(pc),d1
	move.l #4000,d0
	lea $ffff8900.w,a0
	bclr #7,1(a0)
	or.l #$3000000,d1
	movep.l d1,1(a0)
	ADD.L D0,D1
	movep.l d1,$D(a0)
	bsr songplay
	moveq #0,d0
	move.w nb_voie,d0
	addq.w #1,d0
	tst.b f_first
	beq.s .at_write
	sf f_first
	bset #14,d0
.at_write	btst #1,$ffffa202.w
	beq.s .at_write
	move.l d0,$ffffa204.w
	bsr calc_voice_dsp
	move.l #$F0,$ffff9800.w
	move.w #$00F,$ffff8240.w
dsp?	btst #3,$ffffa202.w
	bne.s dsp?
	move.w #-1,$ffff8240.w
	move.l #-1,$ffff9800.w
	movem.l (sp)+,d0-d7/a0-a6
	rte
	
f_first	dc.w 0

**** Si vous n'aimez pas mon player, vous pouvez toujours changer...
***
**
*

songplay	lea variable,a6
	move.b speed(a6),d0
	subq.b #1,cpt(a6)		;Cpt song
	bpl no_new_note
	subq.b #1,d0
	move.b d0,cpt(a6)
	
	***Calcule l'adresse pattern
.get_note	
	move.l adr_patt(a6),a0
	
	move.l adr_pos(a6),a1
	moveq #0,d0
	move.b songpos(a6),d0
	move.b (a1,d0.w),d0		;Numero pattern
	mulu len_pat,d0
	add.l d0,a0
	add.w pattpos(a6),a0
	
	lea data_voice,a1
	lea sample(a6),a2
	
	***Lit les notes de la pattern
	
	sf pass_e6(a6)
	
	move.w nb_voie,d7
.next_track	move.l (a0)+,ligne(a1)		;Note pattern
	***Prend l'instrument
	bfextu ligne(a1){16:4},d6	;No Instrument
	move.w ligne(a1),d5
	bfextu d5{18:2},d0
	lsl.w #4,d0
	add.w d0,d6
	bfclr d5{18:2}
.pas_31	tst.w d6
	beq.s .no_new_instr
	subq.w #1,d6
	mulu #end_inst,d6
	move.l (a2,d6.w),adr_instr(a1)	;Adresse instr
	move.l len_inst(a2,d6.w),len_instr(a1)	;len instr
	move.b fine_inst(a2,d6.w),fine_tune(a1)		;Volume instr
	move.b vol_inst(a2,d6.w),d0
	and.w #$FF,d0
	move.b d0,vol_instr(a1)		;Volume actuel
	move.w d0,vol_actuel(a1)	
	move.l repstart_inst(a2,d6.w),rep_start(a1)	;Repeat start
	move.l replen_inst(a2,d6.w),rep_len(a1)	;Repeat len
.no_new_instr
	*Prend la commande pour portamento
	move.b (2+ligne)(a1),d6
	and.w #$f,d6
	***Prend la note
	tst.w d5			;Note ?
	beq .no_note
	move.w (2+ligne)(a1),d0
	and.w #$FF0,d0
	cmp.w #$E50,d0		;Set Fine tune ?
	bne.s .nosetf
	move.b (3+ligne)(a1),d0
	and.w #$F,d0
	move.b d0,fine_tune(a1) 
.nosetf	cmp.b #5,d6
	beq.s .set_port
	cmp.b #3,d6			;3 SET Portamento
	bne.s .set_note
.set_port	move.w d5,port_dest(a1)
	clr.b port_dir(a1)
	cmp.w note(a1),d5
	beq.s .set_0
	bge.s .no_note
	move.b #1,port_dir(a1)
	bra.s .no_note
.set_0	clr.w port_dest(a1)
	bra.s .no_note
.set_note	lea a_arp,a4	;cherche correspondance dans le tableau
	moveq #35,d0
.cher	cmp.w (a4)+,d5
	dbeq d0,.cher
	tst.w d0
	bmi.s .set	
	subq.w #2,a4
	moveq #0,d0
	move.b fine_tune(a1),d0
	mulu #72,d0
	add.l d0,a4
	move.w (a4),d5		;Note avec le Fine tune
.set	tst.l len_instr(a1)
	bne.s .inst_on
	clr.w d5
.inst_on	move.w d5,note(a1)		;Met la note
	move.w d5,note_actuel(a1)
	clr.b cpt_vib(a1)
	move.l adr_instr(a1),adr_actuel(a1)
.no_note	***Gestion de la commande
	tst.b d6
	beq .no_comm
	moveq #0,d0
	move.b (3+ligne)(a1),d0
	cmp.b #$9,d6		*** 9
	bne.s .pas_9
	bsr do_phase9
.pas_9	cmp.b #$b,d6		*** B
	bne.s .pas_B
	subq.b #1,d0
	move.b d0,songpos(a6)
	move.w #$3f0,pattpos(a6)
.pas_B	cmp.b #$f,d6		*** F
	bne.s .pas_F
	and.b #$1F,d0		;Speed normal
	move.b d0,speed(a6)
	subq.b #1,d0
	move.b d0,cpt(a6)
.pas_F	
	cmp.b #$c,d6		*** C
	bne.s .pas_C
	cmp.w #$40,d0
	ble.s .vol_ok
	move.w #$40,d0
.vol_ok	move.b d0,vol_instr(a1)
	move.w d0,vol_actuel(a1)
.pas_C	cmp.b #$d,d6		*** D
	bne.s .pas_D
	move.w len_pat,d0
	sub.w lg_lig_pat,d0
	move.w d0,pattpos(a6)
.pas_D	cmp.b #$E,d6
	bne.s .pas_E
	bsr do_extend_cmd
.pas_E			
.no_comm	add.w #end2,a1
	dbra d7,.next_track
	
	move.w len_pat,d0
	*** Passe a la ligne suivante...
	move.w lg_lig_pat,d1
	add.w d1,pattpos(a6)
	
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
	bne.s .end
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

no_new_note	lea data_voice,a1
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
	dc.l do_null,do_null,do_volslide,do_null,do_null,do_null,do_extend_cmd,do_null


**********************
* Gestion des effets *
**********************

do_port	tst.b d0
	beq.s .slide
	clr.b 3(a1)
	move.b d0,port_vit(a1)	;vitesse
.slide	tst.w port_dest(a1)
	beq.s .end
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
.ok	move.w note(a1),note_actuel(a1)
.end	rts
	
** Arpeggio  No 0
do_arp	moveq #0,d1
	move.b cpt(a1),d1
	divu #3,d1
	swap d1
	tst.w d1
	beq.s .arp2
	cmp.w #2,d1
	beq.s .arp1
	lsr.b #4,d0
	bra.s .arp3
.arp1	and.w #$F,d0
.arp3	lea a_arp,a0
	moveq #0,d3
	move.b fine_tune(a1),d3
	mulu #72,d3
	lea (a0,d3.w),a0	;pointe sur la bonne table
	move.w note(a1),d2
	moveq #36,d3
.cher	cmp.w (a0)+,d2
	dbeq d3,.cher
	move.w -2(a0,d0.w*2),note_actuel(a1)
	bra.s .end
.arp2	move.w note(a1),note_actuel(a1)
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
	move.b d0,d3
	and.b #$F,d0
	beq.s .vibskip
	and.b #$F0,d2
	or.b d0,d2
.vibskip	move.b d3,d0
	and.b #$F0,d0
	beq.s .vibskip2
	and.b #$F,d2
	or.b d0,d2
.vibskip2	move.b d2,data_vib(a1)

.ne	move.b cpt_vib(a1),d1
	lsr.w #2,d1
	and.w #$1f,d1
	moveq #0,d2
	move.b wave_type(a6),d2
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
.vib_set	moveq #$f,d1
	and.b data_vib(a1),d1
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
	move.w vit_pdown(a1),d0
	bsr do_pdown
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
	
do_phase9	tst.b d0
	BEQ.B .reutilise
	MOVE.B D0,data_phase9(a1)
.reutilise	MOVE.B data_phase9(a1),D0
	bfextu d0{24:8},d0
	LSL.W #8,D0
	CMP.l len_instr(a1),D0
	bhi.s .rep
	ADD.L D0,adr_actuel(a1) 
	RTS
.rep	move.l len_instr(a1),d0
	subq.l #1,d0
	add.l adr_instr(a1),d0
	move.l d0,adr_actuel(a1)
	clr.l len_instr(a1)
	RTS

do_extend_cmd
	move.w d0,d1
	lsr.w #4,d1
	and.w #$F,d0
	jsr ([rout2s,d1.w*4])	
	rts

rout2s	dc.l do_null,do_finepup,do_finepdown,do_setgliss,do_setvib
	dc.l do_setfinetune,do_jumploop,do_settrem,do_null,do_retrig,do_volfineup
	dc.l do_volfinedown,do_notecut,do_notedelay,do_pattdelay,do_funk
	
do_finepup	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end
	bsr do_pup
.end	rts

do_finepdown
	move.b speed(a6),d1
	subq.b #1,d1
	cmp.b cpt(a6),d1
	bne.s .end
	bsr do_pdown
.end	rts
	
do_setgliss	and.b #$F0,glissfunk(a6)
	or.b d0,glissfunk(a6)
	rts

do_setvib	and.b #$F0,wave_type(a6)
	or.b d0,wave_type(a6)
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
	and.b #$F,wave_type(a6)
	or.b d0,wave_type(a6)
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

do_notecut	clr.b vol_instr(a1)
	clr.w vol_actuel(a1)
	rts
	
do_notedelay 
	rts

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

do_funk	rts

	
	
********************
* CALCULE LA NOTE  *
********************
	
calc_voice_dsp
	move.l $44e.w,p_ecran
	lea $ffffa206.w,a1
	
	lea data_voice(pc),a5
	move.w nb_voie,d7
.lp	movem.l d7/a5,-(sp)
	bsr do_voice_dsp
	movem.l (sp)+,d7/a5
	add.w #end2,a5
	dbra d7,.lp
	rts
	

do_voice_dsp 
	move.l adr_actuel(a5),a0
	
	move.w note_actuel(A5),D4
	btst #1,$ffffa202.w
	beq.s *-6
	move.l (note_table,d4.w*4),$ffffa204.w
	
	btst #0,$ffffa202.w
	beq.s *-6
	move.l $ffffa204.w,d0	;Nombre d'octets a envoyer...-1 !
	move.l d0,d3
	lsr.w #1,d0
	addq.w #1,d0
.envoi	move.w (a0)+,(a1)
	dbra d0,.envoi
	
	move.w vol_actuel(A5),D4
	swap d4
	clr.w d4
	btst #1,$ffffa202.w
	beq.s *-6
	move.l d4,$ffffa204.w
	
	add.l adr_actuel(a5),d3	
	move.l d3,d1
	sub.l adr_instr(a5),d3		;longueur qui a ete joue
	
	CMP.L len_instr(a5),D3		;compare les longueurs...
	BLT.S .SUP03		;Inferieur alors pas encore repeat
	moveq #0,d4
	sub.l len_instr(a5),d3
	tst.l rep_len(a5)
	beq.s .nul03
	divul.l rep_len(a5),d4:d3	;Divise par replen
.nul03	move.l rep_start(a5),d1		;Repeat
	add.l adr_instr(a5),d1
	add.l d4,d1			;+ce qui est deja joue
.SUP03	MOVE.L d1,adr_actuel(A5)
	RTS
	
Erreur_bus_conv	
	movem.l d0-d7/a0-a6,-(sp)
	lea chaine,a1
	moveq #7,d6
.loop_c	rol.l #4,d0
	move.l d0,d1
	and.w #$F,d1
	cmp.b #10,d1
	blo.s .dec
	add.b #'A'-'9'-1,d1
.dec	add.b #'0',d1
	move.b d1,(a1)+
	dbra d6,.loop_c
	
	move.l p_ecran,a2
	lea chaine,a1
	moveq #0,d0
	moveq #7,d7
.aff	move.b (a1)+,d0
	sub.b #$20,d0
	lea (font,d0.w*8),a0
I	SET 0
	rept 8
	move.b (a0)+,I(a2)
I	SET I+160
	endr
	add.w #16,a2
	dbra d7,.aff
	add.l #10*160,p_ecran
	movem.l (sp)+,d0-d7/a0-a6
	rts

p_ecran	dc.l 0
	
chaine	dc.l 0,0,0,0
	
do_note:	lea note_table+($390*4),a0
	move.l #$38f,d2
	moveq #72,d3	;71 a 50 KHZ...
.loop	tst.l d2
	BEQ.S	.stop
	MOVE.L	D3,D0	;$11D
	moveq #0,D1		;$0
	divul.l d2,d1:d0
	move.l #$7F1E2958,d4
	divu.l d2,d1:d4
	lsr.l #8,d4
	lsr.l #1,d4
	move.l d4,-(a0)
	dbra d2,.loop
.stop	clr.l -(a0)
	rts


**** Notez que la moitie des trucs ne servent a rien !!!
***
**
*
init_adc	
	move.w #1,-(sp)	;16 Bits
	move.w #$84,-(sp)
	trap #14
	addq.w #4,sp
	
	clr.W	-(A7)	;Track play record 0,0
	clr.W	-(A7)
	MOVE.W	#$85,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	clr.W	-(A7)	;Input from
	MOVE.W	#5,-(A7)
	MOVE.W	#$82,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	clr.W	-(A7)	;Montrack 0
	MOVE.W	#$86,-(A7)
	TRAP	#14
	ADDQ.L	#4,A7
	
	move.w #2,-(sp)	;Matrix
	move.w #4,-(sp)
	move.w #$82,-(sp)
	trap #14
	addq.w #6,sp
	
	move.w 	#1,-(sp)
	move.w 	#1,-(sp)
	move.w 	#0,-(sp)
	move.w 	#4,-(sp)
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
	move.w 	#1,-(sp)
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
	
	MOVEq	#0,D0
	MOVEq	#1,D1
	BSR	SDMA_INT
	
	move.w #1,-(sp)	;16 Bits
	move.w #$84,-(sp)
	trap #14
	addq.w #4,sp
	RTS
	
SDMA_INT	MOVE.W	D1,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	#$87,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	RTS


	rsreset
index_inst		rs.l 1	;index de l'instrument ds la table des blks...
len_inst		rs.l 1	;longueur
fine_inst		rs.b 1	;finetune
vol_inst		rs.b 1	;volume
repstart_inst	rs.l 1	;Repeat start
replen_inst		rs.l 1	;Repeat len
end_inst		rs.b 1


	rsreset
adr_pos		rs.l 1	;ADR pos et pattern pour le module...
adr_patt		rs.l 1
nbr		rs.w 1
sample		rs.b 31*end_inst	; !!! Ne pas separer...

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
wave_type		rs.b 1
loop_pos		rs.w 1	;Position pour le loop
break_pos		rs.w 1	;Position pour le break
loop_cpt		rs.b 1	;Compteur pour le loop
pass_e6		rs.b 1
glissfunk		rs.b 1
		rs.b 1
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
old_note		rs.w 1
old_calc		rs.w 1
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
adr_actuel		rs.l 1
end2		rs.b 1

	SECTION DATA
nb_voie	dc.w NB_VOIE-1	;!!
len_pat	dc.w $100*NB_VOIE	;Longueur d'une pattern
lig_pat 	dc.w 64		; !!
base	dc.w 0		; !!  Ne pas dissocier ces champs
lg_lig_pat  dc.w 4*NB_VOIE	;!!!!
_thefreq	dc.w 512,2		;!!!

; Table des fine tune
	dc.w 0,0,0
a_arp	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113
;1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113
;2
	dc.w 844,796,752,709,670,632,597,563,532,502,474,447
	dc.w 422,398,376,355,335,316,298,282,266,251,237,224
	dc.w 211,199,188,177,167,158,149,141,133,125,118,112
;3
	dc.w 838,791,746,704,665,628,592,559,528,498,470,444
	dc.w 419,395,373,352,332,314,296,280,264,249,235,222
	dc.w 209,198,187,176,166,157,148,140,132,125,118,111
;4
	dc.w 832,785,741,699,660,623,588,555,524,495,467,441
	dc.w 416,392,370,350,330,312,294,278,262,247,233,220
	dc.w 208,196,185,175,165,156,147,139,131,124,117,110
;5
	dc.w 826,779,736,694,655,619,584,551,520,491,463,437
	dc.w 413,390,368,347,328,309,292,276,260,245,232,219
	dc.w 206,195,184,174,164,155,146,138,130,123,116,109
;6
	dc.w 820,774,730,689,651,614,580,547,516,487,460,434
	dc.w 410,387,365,345,325,307,290,274,258,244,230,217
	dc.w 205,193,183,172,163,154,145,137,129,122,115,109
;7
	dc.w 814,768,725,684,646,610,575,543,513,484,457,431
	dc.w 407,384,363,342,323,305,288,272,256,242,228,216
	dc.w 204,192,181,171,161,152,144,136,128,121,114,108
;-8
	dc.w 907,856,808,762,720,678,640,604,570,538,508,480
	dc.w 453,428,404,381,360,339,320,302,285,269,254,240
	dc.w 226,214,202,190,180,170,160,151,143,135,127,120
;-7
	dc.w 900,850,802,757,715,675,636,601,567,535,505,477
	dc.w 450,425,401,379,357,337,318,300,284,268,253,238
	dc.w 225,212,200,189,179,169,159,150,142,134,126,119
;-6
	dc.w 894,844,796,752,709,670,632,597,563,532,502,474
	dc.w 447,422,398,376,355,335,316,298,282,266,251,237
	dc.w 223,211,199,188,177,167,158,149,141,133,125,118
;-5
	dc.w 887,838,791,746,704,665,628,592,559,528,498,470
	dc.w 444,419,395,373,352,332,314,296,280,264,249,235
	dc.w 222,209,198,187,176,166,157,148,140,132,125,118
;-4
	dc.w 881,832,785,741,699,660,623,588,555,524,494,467
	dc.w 441,416,392,370,350,330,312,294,278,262,247,233
	dc.w 220,208,196,185,175,165,156,147,139,131,123,117
;-3
	dc.w 875,826,779,736,694,655,619,584,551,520,491,463
	dc.w 437,413,390,368,347,328,309,292,276,260,245,232
	dc.w 219,206,195,184,174,164,155,146,138,130,123,116
;-2
	dc.w 868,820,774,730,689,651,614,580,547,516,487,460
	dc.w 434,410,387,365,345,325,307,290,274,258,244,230
	dc.w 217,205,193,183,172,163,154,145,137,129,122,115
;-1
	dc.w 862,814,768,725,684,646,610,575,543,513,484,457
	dc.w 431,407,384,363,342,323,305,288,272,256,242,228
	dc.w 216,203,192,181,171,161,152,144,136,128,121,114

Funktable 	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

a_sin	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

	EVEN

variable	ds.b end	
data_voice	ds.b 32*end2
	
	EVEN

ability	dc.w 0
fname	dc.b $30+NB_VOIE,'voies.LOD',0
font
	EVEN
buff	
;	incbin 'e:\modules\jester.mod'
	incbin 'd:\shock.spc\temp\passage.mod'
	SECTION BSS
f_buff		ds.w 2500*31
buffer_dsp		ds.l 1024
old_sp		ds.l 1
p_module		ds.l 1
e_module		ds.l 1
buffer		ds.l 2
digit1		ds.l 6000
digit2		ds.l 6000
volume_table	ds.w 256*65
note_table		ds.l $390
	ds.l 1024
mystack