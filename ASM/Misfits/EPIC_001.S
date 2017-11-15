*************************************************************************************
*						*
*************************************************************************************
*  format pattern	:  1 note = 2 octets			*
*						*
*	_ 1er octet	: 0   -> $60  = note			*
*		: $62 + instr = utilisation canal bruit		*
*			sans modification du canal son	*
*		: $63 + vol   = modification volume sonore	*
*		: $64 + speed = modification de la vitesse pour la	*
*			prochaine note		*
*		: $70 -> $7F  = portamento haut		*
*		: $80 -> $8F  = portamento bas		*
*						*
*	_ 2e octet	: 4 bits forts   : volume sonore		*
*		: 4 bits faibles : numero d'instrument		*
*************************************************************************************

LONG_DATS	equ	24		longueur datas pr 1 voie

START	macro
	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	lea	pile,a7
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move	#0,-(sp)
	move	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
         
	section bss
         
	even
         
	ds.l	200
pile
	section	text
	endm

BMOVE	macro
	
	lea \1,a0
	lea \2,a1
	move.l \3,d0
	move.b (a0)+,(a1)+
	subq.l #1,d0
	dc.w $66fa	bne.s s1
	endm

NNOP	macro
	dcb.w \1,$4e71
	endm
	
SAVEPAL	macro
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,\1
	endm

LOADPAL	macro
	movem.l \1,d0-d7
	movem.l d0-d7,$ffff8240.w
	endm
	
mouseoff	macro
	move.b #$12,$fffffc02.w
	endm
	
mouseon	macro
	move.b #$08,$fffffc02.w
	endm
	
supexec	macro
	pea \1
	move.w #$26,-(sp)
	trap #14
	addq.l #6,sp
	endm

supervis	macro
	move.l \1,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	endm

soundoff	macro
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0A0A0000,$ffff8800.w
	endm
	
setscreen	macro
	move.w \1,-(sp)
	move.l \2,-(sp)
	move.l \3,-(sp)
	move.w #$5,-(sp)
	trap #14
	lea 12(sp),sp
	endm
	
setscreen2	macro
	move.w \1,d0
	move.b d0,$ffff8260.w
	move.l \2,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	endm
	
pterm	macro
	clr.w -(sp)
	trap #1
	endm
	
print	macro
	pea \1
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	endm

getrez	macro
	move.w #4,-(sp)
	trap #14
	addq.l #2,sp
	move.w d0,\1
	endm

getrez2	macro
	move.b $ffff8260.w,d0
	and.w #3,d0
	move.w d0,\1
	endm

getphys	macro
	move.w #3,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,\1
	endm

getphys2	macro
	move.l $ffff8200.w,d0
	lsl.w #8,d0
	move.l d0,\1
	endm

getlog	macro
	move.w #3,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,\1
	endm

getkey	macro
	move.w #7,-(sp)
	trap #1	
	addq.l #2,sp
	endm

vsync	macro
	move.w #$25,-(sp)
	trap #14
	addq.l #2,sp
	endm

readsct	macro
	move.w \1,-(sp)	nb sct
	move.w \2,-(sp)	side
	move.w \3,-(sp)	track
	move.w \4,-(sp)	sct
	move.w \5,-(sp)	drive
	clr.l -(sp)
	move.l \6		tampon
	move.w #8,-(sp)
	trap #14
	lea 20(sp),sp
	endm

writesct	macro
	move.w \1,-(sp)	nb sct
	move.w \2,-(sp)	side
	move.w \3,-(sp)	track
	move.w \4,-(sp)	sct
	move.w \5,-(sp)	drive
	clr.l -(sp)
	move.l \6		tampon
	move.w #9,-(sp)
	trap #14
	lea 20(sp),sp
	endm

v_init	macro
\1	set \2
	endm
	
v_inc	macro
\1	set \1+\2
	endm
	
mtable_l	macro
	v_init moffset,0
	rept \1
	dc.l \2+moffset
	v_inc moffset,\3
	endr
	endm
	
mtable_w	macro
	v_init moffset,0
	rept \1
	dc.w \2+moffset
	v_inc moffset,\3
	endr
	endm
	
mtable_b	macro
	v_init moffset,0
	rept \1
	dc.b \2+moffset
	v_inc moffset,\3
	endr
	endm
				
	opt o+,w-,d-

	supervis	#0
	mouseoff
	clr.b	$484
	moveq	#1,d0		numero de musique
	bsr	player
loop	vsync
	lea	$ffff8209.w,a0
wait_line1	move.b	(a0),d0
	beq.s	wait_line1
	neg.w	d0
	lsl.l	d0,d0
	move.w	#0,$ffff8240.w
	bsr.s 	player+4
	move.w	#$777,$ffff8240.w
	cmp.b 	#$39,$fffffc02.w
	bne.s 	loop
	move.b	#7,$484
	moveq	#0,d0
	bsr	player
	mouseon
	pterm

player	bra	init
	bra	play

	dc.b	"(C) 1991 BLUE BIRD,EPSILON & EPIC from THE MISFITS SOFTWARE (TMS)"
	even

init	movem.l 	d0-a6,-(sp)		initialisation
	bsr.s 	init_zic
	movem.l 	(sp)+,d0-a6
	rts

play	movem.l 	d0-a6,-(sp)		player
	bsr 	play_zic
	movem.l 	(sp)+,d0-a6
	rts

init_zic	and.w	#$ff,d0
	subq.b 	#1,d0
	bpl.s	inits1
	lea	music_flag(pc),a0
	sf	(a0)
	lea	$ffff8800.w,a0	all off
	lea	2(a0),a1
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0A0A0000,(a0)
	move.b	#7,(a0)
	move.b	#$ff,(a1)
	rts
	
inits1	lea	reloc_flag(pc),a0
	tst.b	(a0)
	bne.s	no_init
	st	(a0)
	lea	tab_ins(pc),a0	reloge adresse instruments
	lea	debut_ins(pc),a1
relocate	lea	(a1),a2
	move.l	(a0),d1
	bmi.s	no_init
	add.l	d1,a2
	move.l	a2,(a0)+
	bra.s	relocate	
no_init	lea	music_flag(pc),a0	initialise musique
	st	(a0)
	lea	zics_tab(pc),a0	
	lea 	a(pc),a3
	lea	debut_zics(pc),a1
	lsl.w	#3,d0
	move.l	a3,a2
	lea	(a0,d0.w),a0		a0=adr tab zic
	add.l	(a0)+,a1		a1=adr debut zic
	move.w	(a1)+,(a2)+		set vitesse
	move.l	a1,(a2)+		set adr {sequence}
	move.l	a1,(a2)+		set adr {sequence}
	move.b	(a1),pattern_a-a+1(a3)	set num pattern voie 1 <
	move.b	2(a1),pattern_b-a+1(a3)	 "   "	"      "  2	<
	move.b	4(a1),pattern_c-a+1(a3)	 "   "	"      "  3	<
	move.w	(a0),(a2)+		set longueur sequences
	move.w	(a0),(a2)+		set compteur sequences
	add.w	(a0)+,a1
	move.l	a1,(a2)+		set adr pattern
	clr.w	(a2)+		position dans patterns a 0
	addq.l	#6,table_seq-a(a3)			<
	subq.w	#6,compt_seq-a(a3)			<
	bne.s	no_loop_ini
	move.l	debut_seq-a(a3),table_seq-a(a3)
	move.w	long_seq-a(a3),compt_seq-a(a3)
	
no_loop_ini	lea	$ffff8800.w,a0	clear psg registers
	lea	2(a0),a1
	moveq	#8,d0
clr_sound	move.b	d0,(a0)
	clr.b	(a1)
	addq.b	#1,d0
	cmp.b	#11,d0
	bne.s	clr_sound
	move.b	#7,(a0)
	move.b	#%11111000,(a1)
irts	rts

play_zic	lea 	a(pc),a6		a6=table valeurs zic
	tst.b	music_flag-a(a6)
	beq.s	irts

	subq.b 	#1,(a6)		decompte nbre VBLs
	bne 	no_new_inst
	move.b 	1(a6),(a6)

	lea	tab_ins(pc),a2	a2=adr table d'instruments
	lea	note_a-a(a6),a3
	lea	pattern_a-a(a6),a4
	lea	table_patt,a5
	move.w	pos_pattern-a(a6),d2	d2=pos dans patterns

	moveq	#2,d3
load_instr	move.l	debut_pat-a(a6),a0	a0=adr debut patterns
	move.w	(a4)+,d1		d1=num pattern voie a
	add.w	d1,d1
	move.w	(a5,d1.w),d1
	add.w	d2,d1
	lea	(a0,d1.w),a1		a1=adr pattern voie a
	move.b	(a1)+,d1		d1=note
	beq	dbf		note=0 => suivant
	cmp.b	#$64,d1		code de vitesse ?
	bne.s	load_ins1
	move.b	(a1)+,1(a6)		nouvelle vitesse
	bra	dbf
load_ins1	cmp.b	#$63,d1
	bne.s	keep_vol		teste si code modification
	move.b	(a1)+,1(a3)		volume si present le charge
	bra.s	dbf
keep_vol	cmp.b	#$62,d1		code modif instr. ?
	bne.s	keep_vols1
	move.b	(a1)+,d0
	and.w	#$f,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lea	(a2,d0.w),a1
	move.l	4(a1),6(a3)
	bra.s	dbf	
keep_vols1	move.b	d1,note_a-b(a3)	charge note
	move.b	(a1)+,d0		d0=volume+instrument
	move.b	d0,d1		move.b evite un and.w
	lsr.b	#4,d1
	move.b	d1,volume_a-b(a3)	charge volume
	and.w	#$f,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lea	(a2,d0.w),a1
	move.l	(a1)+,adr_freq_a-b(a3)	copie adr donnees son
	move.l	(a1)+,adr_noise_a-b(a3)	bruit
	move.l	(a1),adr_env_a-b(a3)	enveloppe son
	addq.l	#4,adr_env_a-b(a3)	ajoute nombre de donnees
	move.l	(a1)+,a0
	move.b	(a0)+,wait_vib_a-b(a3)	attente vibrato
	addq.b	#1,wait_vib_a-b(a3)
	move.b	(a0),freq_vi_i_a-b(a3)	freq init vibrato
	move.b	(a0)+,freq_vib_a-b(a3)	freq vibrato
	move.b	(a0)+,intens_vi_a-b(a3)	intensit‚ vibrato
	move.b	(a0),speed_s_a-b(a3)	vitesse lecture enveloppe
	move.b	(a0),speed_s_a_i-b(a3)
	clr.w	adr_fine_a-b(a3)
dbf	lea	LONG_DATS(a3),a3
	dbf	d3,load_instr	

	addq.w	#2,pos_pattern-a(a6)
	cmp.w	#62,d2
	bne.s	no_loop_seq
	
	move.l	table_seq-a(a6),a0	a0=adr sequenc
	move.b	(a0),pattern_a-a+1(a6)
	move.b	2(a0),pattern_b-a+1(a6)
	move.b	4(a0),pattern_c-a+1(a6)
	addq.l	#6,table_seq-a(a6)
	clr.w	pos_pattern-a(a6)
	subq.w	#6,compt_seq-a(a6)
	bne.s	no_loop_seq
	move.l	debut_seq-a(a6),table_seq-a(a6)	bouclage seq.
	move.w	long_seq-a(a6),compt_seq-a(a6)

no_loop_seq	lea	pattern_a-a(a6),a4	sort future note pour
	move.w	pos_pattern-a(a6),d2	test portamento
	move.l	debut_pat-a(a6),a0	a0=adr debut patterns
	lea	note_a-a(a6),a5	a5=adr note courante
	lea 	notes_tab(pc),a6	a6=adr table freq notes
	lea	table_patt,a3
	moveq	#2,d7

tst_porta	moveq	#0,d1
	move.w	(a4)+,d1		d1=num pattern voie a
	add.w	d1,d1
	move.w	(a3,d1.w),d1
	add.w	d2,d1
	lea	(a0,d1.w),a1		a1=adr pattern voie a
	move.b	(a1)+,d1		d1=note
	move.b	(a1)+,d0		d0=volume+instrument

	sub.b	#$70,d1		teste portamento up
	bmi.s	port_ok		d0=longueur portamento
	cmp.b	#$f,d1		d1=hauteur portamento
	bpl.s	no_porta_up		
	moveq	#0,d2
	move.b	(a5),d2		portamento up
	move.w	d2,d4
	add.b	d1,d4
	add.w 	d2,d2
	add.w	d4,d4		calcule freq note courante
	move.w 	(a6,d2.w),d2
	move.w 	(a6,d4.w),d4
	sub.w	d4,d2
	moveq	#0,d4
	move.b	vitesse+1(pc),d4
	move.w	d4,18(a5)
	divu	d4,d2
	move.w	d2,16(a5)
	sub.b	d0,(a5)
	bra.s	port_ok

no_porta_up	sub.b	#$10,d1		portamento down
	moveq	#0,d2
	move.b	(a5),d2		portamento down
	move.w	d2,d4
	add.b	d1,d4
	add.w 	d2,d2
	add.w	d4,d4		calcule freq note courante
	move.w 	(a6,d2.w),d2
	move.w 	(a6,d4.w),d4
	sub.w	d4,d2
	moveq	#0,d4
	move.b	vitesse+1(pc),d4
	move.w	d4,d5
	mulu.w	d0,d5	
	move.w	d5,18(a5)		set compteur portamento
	divu	d4,d2
	move.w	d2,16(a5)
	move.b	d0,(a5)

port_ok	lea	LONG_DATS(a5),a5
	dbf	d7,tst_porta	
	
no_new_inst	lea	$ffff8800.w,a5	a5=registre sonore
	moveq	#0,d7		d7=>num. reg. frequence psg 
	moveq	#8,d6		d6=>num. reg. volume psg
	moveq	#0,d5		d5=code mix
	moveq	#3,d4		d4=num. bit code mix noise
	moveq	#0,d3		d3=num. bit code mix sound
	moveq	#0,d2		d2=valeur noise
	lea	note_a(pc),a4		a4=debut table 3 voies
relit_note	move.l	2(a4),a0		* calcul note *******
	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#$70,d0
	bne.s	no_end_note
	moveq	#0,d0
	bra.s	no_add_note
no_end_note	cmp.b	#$71,d0
	bne.s	note_ok
	move.b	1(a0),d0
	sub.l	d0,2(a4)
	bra.s	relit_note

note_ok	addq.l	#1,2(a4)
no_add_note	moveq	#0,d1
	move.b	(a4),d1
	add.b	d0,d1
	add.w 	d1,d1		d1=note
	move.w	notes_tab(pc,d1.w),d0
	bra	no_add_s1
	
notes_tab	
	DC.W	0,0
	dc.w	$eee,$e17		12 notes * 8 octaves
	dc.w	$d4d,$c8e,$bd9,$b2f	dans l'ordre :
	dc.w	$a8e,$9f7,$967,$8e0	0  = DO  = C
	dc.w	$861,$7e8,$777,$70b	1  = DO# = C#
	dc.w	$6a6,$647,$5ec,$597	2  = RE  = D
	dc.w	$547,$4fb,$4b3,$470	3  = RE# = D#
	dc.w	$430,$3f4,$3bb,$385	4  = MI  = E
	dc.w	$353,$323,$2f6,$2cb	5  = FA  = F
	dc.w	$2a3,$27d,$259,$238	6  = FA# = F#
	dc.w	$218,$1fa,$1dd,$1c2	7  = SOL = G
	dc.w	$1a9,$191,$17b,$165	8  = SOL#= G#
	dc.w	$151,$13e,$12c,$11c	9  = LA  = A
	dc.w	$10c,$fd,$ee,$e1	10 = LA# = A#
	dc.w	$d4,$c8,$bd,$b2	11 = SI  = B
	dc.w	$a8,$9f,$96,$8e
	dc.w	$86,$7e,$77,$70	si n=note (0 a 11) et
	dc.w	$6a,$64,$5e,$59	o=octave (0 a 7) alors
	dc.w	$54,$4f,$4b,$47	code note = o*12+n
	dc.w	$43,$3f,$3b,$38
	dc.w	$35,$32,$2f,$2c	rem:la international (440 HZ)
	dc.w	$2a,$27,$25,$23	a pour code : 57
	dc.w	$21,$1f,$1d,$1c
	dc.w	$1a,$19,$17,$16
	dc.w	$15,$13,$12,$11
	dc.w	$10,$f

no_add_s1	sub.b	#1,20(a4)		test compteur vibrato
	bne.s	no_vib
	move.b	#1,20(a4)
	move.b	23(a4),d1
	ext.w	d1
	sub.w	d1,16(a4)
	subq.b	#1,22(a4)
	bne.s	no_vib
	neg.b	23(a4)
	move.b	21(a4),22(a4)

no_vib	add.w	16(a4),d0		ici ajouts port & vibrato
	move.b	d7,(a5)
	move.b	d0,2(a5)		donne 1/2 note
	addq.b	#1,d7
	lsr.w	#8,d0
	move.b 	d7,(a5)
	move.b	d0,2(a5)		donne 1/2 note
	addq.b	#1,d7

relit_noise	move.l	6(a4),a0		* calcul bruit *******
	move.b	(a0),d0
	cmp.b	#$70,d0
	bne.s	no_end_nois
	bset	d4,d5		noise on
	bra.s	relit_vol
no_end_nois	cmp.b	#$71,d0
	bne.s	non_loop_ns
	moveq	#0,d0
	move.b	1(a0),d0
	sub.l	d0,6(a4)
	bra.s	relit_noise
non_loop_ns	cmp.b	#-1,d0
	bne.s	no_noise_of
	bclr	d3,d5		sound on
	bset	d4,d5		noise off
	bra.s	end_noise
no_noise_of	tst.b	d0
	bpl.s	sound_on
	bset	d3,d5		sound off
	bclr	d4,d5		noise on
	and.b	#31,d0
	bra.s	put_noise
sound_on	bclr	d3,d5		sound on
	bclr	d4,d5		noise on
put_noise	move.b	d0,d2		!!!!!	
end_noise	addq.l	#1,6(a4)

relit_vol	move.l	10(a4),a0		* calcule volume *******
	move.b	(a0),d0		$70  = fin
	cmp.b	#$70,d0		$71+1= boucle 
	bne.s	non_fin_vol		$72+2= courbes psg
	move.b	d6,(a5)
	move.b	(a5),d0
	bra.s	set_volume
non_fin_vol	cmp.b	#$71,d0		$73+1= chgt vit. env
	bne.s	non_loop_v		$74  = rien
	moveq	#0,d0
	move.b	1(a0),d0
	sub.l	d0,10(a4)
	bra.s	relit_vol
non_loop_v	cmp.b	#$72,d0		* courbe psg
	bne.s	no_crbe_psg
	move.b	#11,(a5)
	move.b	1(a0),2(a5)
	move.b	#12,(a5)
	move.b	#0,2(a5)
	move.b	#13,(a5)
	move.b	2(a0),2(a5)
	move.b	d6,(a5)
	move.b	#$10,2(a5)
	addq.l	#3,10(a4)
	addq.b	#1,14(a4)		?
	bra.s	no_volume	
no_crbe_psg	cmp.b	#$73,d0		* vitesse enveloppe
	bne.s	no_chg_vit	
	move.b	1(a0),14(a4)
	move.b	1(a0),15(a4)
	addq.b	#1,14(a4)
	addq.l	#2,10(a4)
	bra.s	relit_vol
no_chg_vit	subq.b	#1,14(a4)
	bne.s	no_move_vol
	move.b	15(a4),14(a4)
	addq.l	#1,10(a4)
no_move_vol	cmp.b	#$74,d0
	beq.s	no_volume
set_volume	move.b	1(a4),d1
	beq.s	no_chg_vol
	cmp.b	#1,d1
	bne.s	no_rst_vol
	moveq	#0,d0
	bra.s	no_chg_vol
no_rst_vol	not.b	d1
	and.b	#15,d1
	sub.b	d1,d0
	tst.b	d0
	bpl.s	no_chg_vol
	moveq	#0,d0
no_chg_vol	move.b	d6,(a5)
	move.b	d0,2(a5)
no_volume	addq.b	#1,d6
	lea	LONG_DATS(a4),a4
	addq.b	#1,d3
	addq.b	#1,d4

	cmp.b	#11,d6
	bne	relit_note

	move.b	#6,(a5)
	move.b	d2,2(a5)		put noise
	
	or.b	#$c0,d5
	move.b	#7,(a5)
	move.b	d5,2(a5)		put mix code
	rts

table_patt	mtable_w	100,0,64

a
vitesse	dc.w	0	vitesse
debut_seq	dc.l	0	adr debut table sequences
table_seq	dc.l	0	adr table sequences
long_seq	dc.w	0	longueur sequences
compt_seq	dc.w	0	compteur sequences
debut_pat	dc.l	0	adr debut table patterns
pos_pattern	dc.w	0	position dans les patterns
pattern_a	dc.w	0	numero pattern voie A
pattern_b	dc.w	0	numero pattern voie B
pattern_c	dc.w	0	numero pattern voie C

b
note_a	dc.b	0	note voie a
volume_a	dc.b	0	volume reference voie a
adr_freq_a	dc.l	instrum0	adresse env de freq voie a
adr_noise_a	dc.l	instrum0	adresse enveloppe bruit
adr_env_a	dc.l	instrum0	adresse enveloppe volume
speed_s_a	dc.b	0	speed enveloppe son
speed_s_a_i	dc.b	0	speed init eveloppe son
adr_fine_a	dc.w	0	val a ajouter voie a
compt_por_a	dc.w	0	compteur longueur portamento
wait_vib_a	dc.b	0	attente du vibrato
freq_vi_i_a	dc.b	0	frequence init du vibrato
freq_vib_a	dc.b	0	compt frequence du vibrato
intens_vi_a	dc.b	0	intensit‚ vibrato

note_b	dc.b	0	note voie b
volume_b	dc.b	0	volume reference voie b
adr_freq_b	dc.l	instrum0	adresse env de freq voie b
adr_noise_b	dc.l	instrum0	adresse enveloppe bruit
adr_env_b	dc.l	instrum0	adresse enveloppe volume
speed_s_b	dc.b	0	speed enveloppe son
speed_s_b_i	dc.b	0	speed init eveloppe son
adr_fine_b	dc.w	0	val a ajouter voie b
compt_por_b	dc.w	0	compteur longueur portamento
wait_vib_b	dc.b	0	attente du vibrato
freq_vi_i_b	dc.b	0	frequence init du vibrato
freq_vib_b	dc.b	0	compt frequence du vibrato
intens_vi_b	dc.b	0	intensit‚ vibrato

note_c	dc.b	0	note voie c
volume_c	dc.b	0	volume reference voie c
adr_freq_c	dc.l	instrum0	adresse env de freq voie c
adr_noise_c	dc.l	instrum0	adresse enveloppe bruit
adr_env_c	dc.l	instrum0	adresse enveloppe volume
speed_s_c	dc.b	0	speed enveloppe son
speed_s_c_i	dc.b	0	speed init eveloppe son
adr_fine_c	dc.w	0	val a ajouter voie c
compt_por_c	dc.w	0	compteur longueur portamento
wait_vib_c	dc.b	0	attente du vibrato
freq_vi_i_c	dc.b	0	frequence init du vibrato
freq_vib_c	dc.b	0	compt frequence du vibrato
intens_vi_c	dc.b	0	intensit‚ vibrato

reloc_flag	dc.b	0	flag si musique deja relog‚e
music_flag	dc.b	0	flag musique on/off

instrum0	dc.b	$70

	even
		
***************************************************************************
***                                                                     ***
***                       donnees des instruments                       ***
***                                                                     ***
***************************************************************************

tab_ins	dc.l	freq_1-debut_ins
	dc.l	noise_1-debut_ins
	dc.l	volume_1-debut_ins
	dc.l	freq_2-debut_ins
	dc.l	noise_2-debut_ins
	dc.l	volume_2-debut_ins
	dc.l	freq_3-debut_ins
	dc.l	noise_3-debut_ins
	dc.l	volume_3-debut_ins
	dc.l	freq_4-debut_ins
	dc.l	noise_4-debut_ins
	dc.l	volume_4-debut_ins
	dc.l	freq_5-debut_ins
	dc.l	noise_5-debut_ins
	dc.l	volume_5-debut_ins
	dc.l	freq_6-debut_ins
	dc.l	noise_6-debut_ins
	dc.l	volume_6-debut_ins
	dc.l	freq_7-debut_ins
	dc.l	noise_7-debut_ins
	dc.l	volume_7-debut_ins
	dc.l	freq_8-debut_ins
	dc.l	noise_8-debut_ins
	dc.l	volume_8-debut_ins
	dc.l	freq_9-debut_ins
	dc.l	noise_9-debut_ins
	dc.l	volume_9-debut_ins
	dc.l	freq_10-debut_ins
	dc.l	noise_10-debut_ins
	dc.l	volume_10-debut_ins
	dc.l	freq_11-debut_ins
	dc.l	noise_11-debut_ins
	dc.l	volume_11-debut_ins
	dc.l	freq_12-debut_ins
	dc.l	noise_12-debut_ins
	dc.l	volume_12-debut_ins
	dc.l	freq_13-debut_ins
	dc.l	noise_13-debut_ins
	dc.l	volume_13-debut_ins
	dc.l	freq_14-debut_ins
	dc.l	noise_14-debut_ins
	dc.l	volume_14-debut_ins
	dc.l	freq_15-debut_ins
	dc.l	noise_15-debut_ins
	dc.l	volume_15-debut_ins
	dc.l	freq_16-debut_ins
	dc.l	noise_16-debut_ins
	dc.l	volume_16-debut_ins

	dc.l	-1		

debut_ins

freq_1	dc.b	07,07,12,12,15,15,$71,6
noise_1	dc.b	$70
volume_1	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_2	dc.b	07,07,12,12,14,14,$71,6
noise_2	dc.b	$70
volume_2	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_3	dc.b	07,07,12,12,17,17,$71,6
noise_3	dc.b	$70
volume_3	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_4	dc.b	$70
noise_4	dc.b	$80,$70
volume_4	dc.b	0,0,0,1,10,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_5	dc.b	16,14,11,7,4,2,0,$70
noise_5	dc.b	-$13,$70
volume_5	dc.b	0,4,1,2,12,11,$71,1

freq_6	dc.b	0,12,12,12,0,$71,1
noise_6	dc.b	$70
volume_6	dc.b	16,4,1,3,12,11,10,9,8,7,6,4,3,2,1,0,$71,1

freq_7	dc.b	08,08,12,12,15,15,$71,6
noise_7	dc.b	$70
volume_7	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_8	dc.b	08,08,12,12,14,14,$71,6
noise_8	dc.b	$70
volume_8	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_9	dc.b	08,08,12,12,17,17,$71,6
noise_9	dc.b	$70
volume_9	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_10	dc.b	0,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16,-17,-18,-20,-25,-30,-35,$70	snaredrum
noise_10	dc.b	-$14,-1,-1,9,8,8,7,0,0,0,0,0,0,0,0,0,-1,$70
volume_10	dc.b	0,0,0,1,11,13,12,12,12,11,10,8,6,4,1,0,0,$70

freq_11	dc.b	$70
noise_11	dc.b	$70
volume_11	dc.b	16,3,1,1,12,11,$71,1

freq_12	dc.b	07,07,11,11,14,14,$71,6
noise_12	dc.b	$70
volume_12	dc.b	0,0,0,2,12,11,10,9,8,7,6,5,4,3,2,1,0,$71,1

freq_13	dc.b	$70			   melody
noise_13	dc.b	$70
volume_13	dc.b	0,0,0,4,$72,40,14,$70
 
freq_14	dc.b	$70			   strings 1
noise_14	dc.b	$70
volume_14	dc.b	0,0,0,4,$72,45,14,$70

freq_15	dc.b	$70			   strings 2
noise_15	dc.b	$70
volume_15	dc.b	0,0,0,5,$72,120,14,$70

freq_16	dc.b	$70			   
noise_16	dc.b	$70
volume_16	dc.b	0,0,0,5,$72,72,14,$70

	even

***************************************************************************
***                                                                     ***
***                          DONNEES DES MUSIQUE                        ***
***                                                                     ***
***************************************************************************

nombre_zics	= 2			  nombre de musiques

zics_tab	dc.l	zic_1-debut_zics	  adr relative zic
	dc.w	fin_sequences_1-zic_1-2	  longueur sequences
	dc.w	fin_zic_1-fin_sequences_1 longueur patterns
*zic2	dc.l	zic_2-debut_zics
*	dc.w	fin_sequences_2-zic_2-2
*	dc.w	fin_zic_2-fin_sequences_2

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

debut_zics

zic_1	dc.b	1,6
	*			
list_sequences_1
	
	dc.w	$100,$600,0
	dc.w	$200,$700,0
	dc.w	$100,$600,0
	dc.w	$300,$600,0
	dc.w	$400,$800,0
	dc.w	$100,$600,$d00
	dc.w	$200,$700,$e00
	dc.w	$100,$600,$d00
	dc.w	$300,$600,$d00
	dc.w	$400,$800,$e00
	dc.w	$100,$600,$900
	dc.w	$200,$700,$a00
	dc.w	$100,$600,$b00
	dc.w	$300,$600,$c00
	dc.w	$400,$800,$a00
	dc.w	$100,$1100,$f00
	dc.w	$200,$1200,$1000
	dc.w	$100,$1100,$f00
	dc.w	$300,$1100,$1000
	dc.w	$400,$1300,$f00
	dc.w	0,$1400,$100
	dc.w	0,0,$200
	dc.w	0,0,$100
	dc.w	0,0,$300
	dc.w	0,0,$400
	
	
fin_sequences_1

pat0	
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
pat1
	dc.w	$2600,0,$26b0,0
	dc.w	$2600,0,$2602,0
	dc.w	$2600,0,$2601,0
	dc.w	$26b1,0,$2601,0
	dc.w	$2600,0,$26b0,0
	dc.w	$2600,0,$2602,0
	dc.w	$2600,0,$2601,0
	dc.w	$26b1,0,$2600,0
pat2
	dc.w	$2b00,0,$2bb0,0
	dc.w	$2b00,0,$2b02,0
	dc.w	$2b00,0,$2b01,0
	dc.w	$2bb1,0,$2b01,0
	dc.w	$2b00,0,$2bb0,0
	dc.w	$2b00,0,$2b02,0
	dc.w	$2b00,0,$2b01,0
	dc.w	$2bb1,0,$2b00,0
pat3
	dc.w	$2606,0,$26b6,0
	dc.w	$2606,0,$2608,0
	dc.w	$2606,0,$2607,0
	dc.w	$26b7,0,$2607,0
	dc.w	$2606,0,$26b6,0
	dc.w	$2606,0,$2608,0
	dc.w	$2606,0,$2607,0
	dc.w	$26b7,0,$2606,0
pat4
	dc.w	$2901,0,$29b1,0
	dc.w	$2901,0,$2901,0
	dc.w	$29b1,0,$2901,0
	dc.w	$2901,0,$2901,0
	dc.w	$290b,0,$29bb,0
	dc.w	$290b,0,$290b,0
	dc.w	$29bb,0,$290b,0
	dc.w	$290b,0,$290b,0
pat5
	dc.w	$0e04,0,0,0
	dc.w	$0e04,0,$0e04,0
	dc.w	$0a04,0,$0c04,0
	dc.w	$0e04,0,0,0
	dc.w	$0e04,0,0,0
	dc.w	$0e04,0,$0e04,0
	dc.w	$1304,0,$1104,0
	dc.w	$0e04,0,0,0
pat6
	dc.w	$0e04,0,0,0
	dc.w	$2409,0,$0e04,0
	dc.w	$0a04,0,$0c04,0
	dc.w	$2409,0,$0e04,0
	dc.w	$0e04,0,0,0
	dc.w	$2409,0,$0e04,0
	dc.w	$1304,0,$1104,0
	dc.w	$2409,0,$0e04,0
pat7
	dc.w	$1304,0,0,0
	dc.w	$2409,0,$1304,0
	dc.w	$0e04,0,$1104,0
	dc.w	$2409,0,$1304,0
	dc.w	$1304,0,0,0
	dc.w	$2409,0,$1304,0
	dc.w	$1604,0,$1104,0
	dc.w	$2409,0,$1304,0
pat8
	dc.w	$0c04,0,0,0
	dc.w	$2409,0,$0c04,0
	dc.w	$0804,0,$0b04,0
	dc.w	$2409,0,$0c04,0
	dc.w	$0c04,0,0,0
	dc.w	$2409,0,$0c04,0
	dc.w	$1104,0,$1004,0
	dc.w	$2409,0,$0c04,0
pat9
	dc.w	$35d3,0,$34d3,0
	dc.w	$32d3,0,$30d3,0
	dc.w	$32d3,0,$2dd3,0
	dc.w	$2bd3,0,$2dd3,0
	dc.w	$35d3,0,$34d3,0
	dc.w	$32d3,0,$30d3,0
	dc.w	$32d3,0,$2dd3,0
	dc.w	$2bd3,0,$2dd3,0
pata
	dc.w	$35e3,0,$34e3,0
	dc.w	$32e3,0,$30e3,0
	dc.w	$32e3,0,$2de3,0
	dc.w	$2be3,0,$2de3,0
	dc.w	$35e3,0,$34e3,0
	dc.w	$32e3,0,$30e3,0
	dc.w	$32e3,0,$2de3,0
	dc.w	$2be3,0,$2de3,0
patb
	dc.w	$35f3,0,$34f3,0
	dc.w	$32f3,0,$30f3,0
	dc.w	$32f3,0,$2df3,0
	dc.w	$2bf3,0,$2df3,0
	dc.w	$35f3,0,$34f3,0
	dc.w	$32f3,0,$30f3,0
	dc.w	$32f3,0,$2df3,0
	dc.w	$2bf3,0,$2df3,0
patc
	dc.w	$3503,0,$3403,0
	dc.w	$3203,0,$3003,0
	dc.w	$3203,0,$2d03,0
	dc.w	$2b03,0,$2d03,0
	dc.w	$3503,0,$3403,0
	dc.w	$3203,0,$3003,0
	dc.w	$3203,0,$2d03,0
	dc.w	$2b03,0,$2d03,0
patd
	dc.w	$3205,0,0,0
	dc.w	$321a,0,0,0
	dc.w	$3905,$391a,$3705,$391a
	dc.w	$3905,$391a,$3705,$3905
	dc.w	$391a,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,$3205,$3212
	dc.w	$2d05,$2d1a,$3005,0
pate
	dc.w	$3005,0,0,0
	dc.w	$321a,0,0,0
	dc.w	$2d05,$391a,$2b05,$391a
	dc.w	$2d05,$391a,$2d05,$3205
	dc.w	$391a,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,$2b05,$3212
	dc.w	$2d05,$2d1a,$3005,0
patf
	dc.w	$260a,$2d0a,$320a,$321a
	dc.w	0,0,$300a,0
	dc.w	$320a,0,0,0
	dc.w	$2d0a,0,$2dda,0
	dc.w	$2d0a,0,$2d1a,0
	dc.w	0,0,$2b0a,0
	dc.w	$2d0a,0,$260a,0
	dc.w	$261a,0,0,0
pat10
	dc.w	$260a,$2d0a,$320a,$321a
	dc.w	0,0,$350a,0
	dc.w	$370a,0,0,0
	dc.w	$390a,0,$391a,0
	dc.w	$390a,0,$391a,0
	dc.w	$320a,0,0,0
	dc.w	$321a,0,$340a,0
	dc.w	$370a,0,0,0
pat11
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
	dc.w	$1ada,0,$0eda,0
pat12
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
	dc.w	$1fda,0,$13da,0
pat13
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
	dc.w	$18da,0,$0cda,0
pat14
	dc.w	$3210,0,0,0
	dc.w	0,0,0,0 
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
fin_zic_1



 