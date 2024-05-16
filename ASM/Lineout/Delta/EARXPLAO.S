; Earx's modplayer. Based on rsnd player.
;
; Just a plain modplayer. Needs no special format. Also no extra mem
; needed after mod.
;
; Replay is on time and looping is slick. There is crap tho:
; - no fineposition in samples
; - sample-changes without note (should be seamless, now it sounds shitty)
; - tremelo bug (?)
;
; Credits:
; - cpu part:     earx, huge parts by newface (and pt author ?)
; - dsp part:     original by newface, remake by earx
; - host restore: nullos
;
; v1.1: fixed crunchy noises, upped volume, retrig working
; v1.2: optimised sampletransfer for speed

;= equates =================================================================

color:			=	0		; display cpu/dsp time
EarxPlay.MAX_TRACKS:	=	8
EarxPlay.SYNCMODE:	=	1		; use $800 for end-command..


DSP_BASE:		=	$FFFFA200

; offsets of the mod's samples
			RSRESET
ModSample.NAME:		RS.B	22
ModSample.LENGTH:	RS.W	1
ModSample.FINETUNE:	RS.B	1
ModSample.VOLUME:	RS.B	1
ModSample.LOOPSTART:	RS.W	1
ModSample.LOOPLEN:	RS.W	1
ModSample.SIZE:		RS.B	0

; offsets of the mod.format
			RSRESET
Mod.NAME:		RS.B	20
Mod.SAMPLES:		RS.B	ModSample.SIZE*31
Mod.POSITIONS:		RS.B	1
Mod.REPEAT:		RS.B	1
Mod.POSTABLE:		RS.B	128
Mod.ID:			RS.L	1
Mod.PATTERNS:		RS.B	0

; voicestructure for administration
			RSRESET
Voice.CMD:		RS.B	1
Voice.SAMPLE:		RS.B	1		; sample nr
Voice.COMMANDPARS:	RS.W	1
Voice.IPERIOD:		RS.W	1		; 1/f
Voice.NPERIOD:		RS.W	1		; 1/f
Voice.START:		RS.L	1
Voice.LENGTH:		RS.L	1
Voice.LOOPSTART:	RS.L	1
Voice.REPLEN:		RS.L	1
Voice.SPLOFFSET:	RS.W	1
Voice.TONEPORTSPEED:	RS.W	1
Voice.WAVESTART:	RS.L	1
Voice.REALLENGTH:	RS.L	1
Voice.PATTPOS:		RS.W	1
Voice.WANTEDPERIOD:	RS.W	1
Voice.VOLUME:		RS.W	1
Voice.FINETUNE:		RS.B	1
Voice.SINFO:		RS.B	1
Voice.GLISSFUNK:	RS.W	1	+0	:	+1
Voice.VIBRATOCMD:	RS.W	1	+0	:	+1
Voice.TREMOLOCMD:	RS.W	1	+0	;	+1
Voice.WAVECONTROL:	RS.W	1	+0	;	+1
Voice.LOOPCOUNT:	RS.W	1
Voice.TONEPORTDIRECT:	RS.B	1
Voice.VIBRATOPOS:	RS.B	1
Voice.TREMOLOPOS:	RS.B	1
Voice.FUNKOFFSET:	RS.B	1
Voice.TRIGGER:		RS.B	1
Voice.SAMPLENUM:	RS.B	1
Voice.SIZE:		RS.B	0

; voicestructure for mixing
			RSRESET
Mixer.VOLUME:		RS.W	1	
Mixer.FINETUNE:		RS.B	1
Mixer.INFO:		RS.B	1
Mixer.PERIOD:		RS.W	1
Mixer.START:		RS.L	1
Mixer.LENGTH:		RS.L	1
Mixer.LOOPSTART:	RS.L	1
Mixer.LOOPLENGTH:	RS.L	1
Mixer.SAMPLEADR:	RS.L	1
Mixer.FLAGINFO:		RS.W	1
Mixer.SIZE:		RS.B	0

;= macros ==================================================================

;	toutes le macro		NEW-FACE
env	MACRO
.\@	btst	#1,\1
	beq.s	.\@
	endm
rec	MACRO
.\@	btst	#0,\1
	beq.s	.\@
	endm

ReadHost	MACRO	dst			
.\@	btst	#0,DSP_BASE+2.w
	beq.s	.\@
	move.l	DSP_BASE+4.w,\1
	ENDM
WritHost	MACRO	src				
.\@	btst	#1,DSP_BASE+2.w
	beq.s	.\@
	move.l	\1,DSP_BASE+4.w
	ENDM

save_host:	macro
	move.b	#$80+$13,DSP_BASE+1.w		;HOST commande $13
	move.w	#1000,d0		
.loop	tst.b	DSP_BASE+1.w			;Attendre le d‚clenchement cot‚ DSP
	dbpl	d0,.loop	
	move.l	#'RSP',d3			;"Real Sound Player"
	move.l	d3,d2				;On va recevoir au maximum 2 valeurs+"RSP"
	move.l	d3,d1				;Principe des "registres en d‚calages"
.link	move.l	d1,d0			
	move.l	d2,d1				;
	ReadHost	d2			;r‚cupere ds le Host...
	cmp.l	d3,d2				;="RSP" ?
	bne.s	.link				;Non, on recommence
	WritHost	d3			;Balance notre identification, et lire
	ReadHost	-(sp)			;ce que le mixer a capt‚ pour Host->DSP
	ReadHost	-(sp)		
	WritHost	d0			;On lui envoie ce que l'on a capt‚.
	WritHost	d1		
	endm

restore_host:	macro
; a5: DSP_BASE+2
.wc	btst	#3,(a5)				;on attend la fin du traitement
	beq.s	.wc				;par le DSP
	moveq	#1,d0			
.resend	move.l	(sp)+,d1			;On restitue au DSP 
	cmpi.l	#'RSP',d1			;le(s) valeurs qu'on
	beq.s	.nosend				;a r‚cup‚r‚ au

;	move.l	d1,2(a5)			;d‚clenchement de la commande
	WritHost	d1			; test!

.nosend	dbf	d0,.resend		
	endm

se_period	macro	adresse_table,valeur a rechercher,offset dans la table (-2), increment (variable)
	moveq	#0,\3
	moveq	#37,\4
.loop	lsr	\4
	addx	\4,\3
.loop2	cmp	-2(\1,\3*2),\2
	blt.s	.loop
	beq.s	.find
	lsr	\4
	subx	\4,\3
	bra.s	.loop2
.find
		endm

se_period2	macro	adresse_table, valeur a rechercher, compteur
	moveq	#3,\3
.loop	lea	8*2(\1),\1
	cmp	(\1),\2
	dbge	\3,.loop
	beq.s	.find
	bgt.s	.search	
	lea	5*2(\1),\1
.search	move	#7,\3
.loop2	cmp	-(\1),\2
	dblt	\3,.loop2
	beq.s	.find
	lea	2(\1),\1
.find
;	\1
	endm
	
;tous les effects
set_wave_ctrl	macro
	move.b	Voice.WAVECONTROL+1(a4),d1
	btst	#2,d1
	bne.s	.pt_vibnoc
	clr.b	Voice.VIBRATOPOS(A4)
.pt_vibnoc
	btst	#6,d1
	bne.s	.pt_trenoc
	clr.b	Voice.TREMOLOPOS(A4)
.pt_trenoc
	move.l	Voice.LENGTH(A4),Mixer.LENGTH(A5)	;Set length
	move.l	Voice.START(a4),Mixer.START(a5)		;Set start
.pt_sdmaskp
	move.w	Voice.NPERIOD(A4),Mixer.PERIOD(a5)
	move.b	#$FE,Mixer.FLAGINFO(a5)	;s_ptr_sample(a5)=s_loopstart(a5)	
	st	Voice.TRIGGER(A4)
	endm

;= main routs ==============================================================

EarxPlay.routTable:
	bra.w	EarxPlay.relocate
	bra.w	EarxPlay.init
	bra.w	EarxPlay.deinit
	bra.w	EarxPlay.play
	bra.w	EarxPlay.stop
	bra.w	EarxPlay.nextPos
	bra.w	EarxPlay.getSyncInfo


EarxPlay.relocate:
	movem.l	d0-a6,-(sp)
	lea	EarxPlay.routTable-$1C(pc),a0
	MOVE.L	2(A0),D0
	ADD.L	6(A0),D0
	ADD.L	14(A0),D0
	LEA	$1C(A0),A0
	MOVE.L	A0,A1
	MOVE.L	A0,A2
	MOVE.L	A0,D1
	ADD.L	D0,A1
	MOVE.L	(A1)+,D0
	ADD.L	D0,A2
	ADD.L	D1,(A2)
	MOVEQ.L	#0,D0
.BOUCLE:MOVE.B	(A1),D0
	CLR.B	(A1)+
	TST.B	D0
	BEQ.S	.FIN_RELOC
	CMP.B	#1,D0
	BEQ.S	.SPECIAL_BRANCH
	ADD.L	D0,A2
	ADD.L	D1,(A2)
	BRA.S	.BOUCLE
.SPECIAL_BRANCH:
	LEA	$FE(A2),A2
	BRA.S	.BOUCLE
.FIN_RELOC
	movem.l	(sp)+,d0-a6
	RTS	

; INPUT:
; d0.w= size in dspwords
; a0: p56 program
Dsp.loadProgram:
	tst.w	EarxPlay.initialized
	bne.w	load_dsp_prg

	move.w	#$4242,-(sp)
	clr.l	d1
	move.w	d0,d1
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move	#$6d,-(sp)	; Dsp_ExecProg
	trap	#14
	lea	12(sp),sp
	rts

; INPUT:
; d0.w=mixfreq (1:49KHz, 2:33KHz)
; OUTPUT:
; d0.l=returncode (=0:ok, <0: error)
EarxPlay.init:
	cmpi.w	#1,d0
	blt.s	.error
	cmpi.w	#2,d0
	bhi.s	.error
	move.w	d0,matr_i

	tst.w	EarxPlay.initialized
	bne.s	.tables_done
	move.l	(table_frq-4.w,pc,d0.w*4),d2
	bsr	init_freq_table
	bsr	init_table_vitesse
	st	EarxPlay.initialized
.tables_done:

	bsr	init_sound_config
	bsr	load_dsp_prog	
	bsr	save_mfp 
	bsr	EarxPlay.installTimer
	moveq	#0,d0
	rts
.error:	clr.w	EarxPlay.initialized
	moveq	#-1,d0
	rts

EarxPlay.deinit:
	bsr	restore_mfp
	lea	$ffffa200.w,a6
	move.b	#$80+$13,1(a6)
	move.w	#1000,d0		
.loop	tst.b	1(a6)			;Attendre DSP
	dbpl	d0,.loop		
	clr.l	$fffffa204.w		
	move.w	#1,-(A7)
	move.w	#0,-(A7)
	move.w	#0,-(A7)
	move.w	#8,-(A7)
	move.w	#0,-(A7)
	move.w	#$8B,-(A7)
	trap	#14
	lea	12(sp),sp
	move.w	#0,-(A7)
	move.w	#$84,-(A7)
	trap	#14
	addq	#4,A7
	rts

; INPUT:
; a0: module
; OUTPUT:
; d0.l=returncode (=0: ok, <0: error)
EarxPlay.play:
	move.l	a0,EarxPlay.modAdr

; Get nmbr of tracks..
	move.l	Mod.ID(a0),d0
	cmpi.l	#"4CHN",d0
	beq	.set4Chn
	cmpi.l	#"6CHN",d0
	beq	.set6Chn
	cmpi.l	#"8CHN",d0
	beq	.set8Chn
	cmpi.l	#"M.K.",d0
	beq	.set4Chn
	cmpi.l	#'M&k&',d0
	beq	.set4Chn
	cmpi.l	#'M&k&',d0
	beq	.set4Chn
	cmpi.l	#'M!k!',d0
	beq	.set4Chn
	cmpi.l	#'FLT4',d0
	beq	.set4Chn
	cmpi.l	#'FLT6',d0
	beq	.set6Chn
	cmpi.l	#'FLT8',d0
	beq	.set8Chn
	cmpi.l	#'CD81',d0
	beq	.set8Chn
	cmpi.l	#'OCTA',d0
	beq	.set8Chn
	cmpi.l	#'FA04',d0
	beq	.set4Chn
	cmpi.l	#'FA06',d0
	beq	.set6Chn
	cmpi.l	#'FA08',d0
	beq	.set8Chn
	bra	.error
.end_get_tracks:

; Get addresses of samples.
	lea	Mod.POSTABLE(a0),a1
	moveq	#128-1,d7
	clr.l	d1
.find_max_loop:
	move.b	(a1)+,d0
	cmp.b	d1,d0
	bls.s	.next
	move.b	d0,d1
.next:	dbf	d7,.find_max_loop

	addq.w	#1,d1					; d1.w=#patterns
	mulu.w	EarxPlay.numTracks,d1
	lsl.l	#8,d1					; d1.l=size of patterns
	lea	(Mod.PATTERNS,a0,d1.l),a1		; a1: samples
	lea	EarxPlay.splAdrTable,a2			; a2: sample-adr-table
	lea	Mod.SAMPLES(a0),a3			; a3: spl descriptors
	clr.l	d0
	moveq	#31-1,d7
.get_spladr_loop:
	move.l	a1,(a2)+				; Store sampleaddy.

	move.w	ModSample.LENGTH(a3),d0			; d0.w=size of sample /2
	lea	(a1,d0.l*2),a1				; a1: next sample
	bne.s	.spllength_okay
	addq.w	#1,d0
	move.w	d0,ModSample.LENGTH(a3)
.spllength_okay:

	move.w	ModSample.LOOPLEN(a3),d1
	bne.s	.looplength_okay
	addq.w	#1,d1
	move.w	d1,ModSample.LOOPLEN(a3)
.looplength_okay:

	adda.w	#ModSample.SIZE,a3			; a3: next sampledescriptor
	dbf	d7,.get_spladr_loop

; Set player-parameters to default.
	move.w	#6,EarxPlay.speed
	clr.w	EarxPlay.counter
	clr.w	EarxPlay.position			; Set to position 0.
	move.w	#-1,EarxPlay.pattpos			; Set to note -1, will be 0 at first play!

	bsr.s	EarxPlay.resetVoices
	bsr	init_sound_config
	st	EarxPlay.playing

	clr.l	d0
	rts
.error:	moveq	#-1,d0
	rts

.set4Chn:
	move.w	#4,EarxPlay.numTracks
	bra	.end_get_tracks
.set6Chn:
	move.w	#6,EarxPlay.numTracks
	bra	.end_get_tracks
.set8Chn:
	move.w	#8,EarxPlay.numTracks
	bra	.end_get_tracks

EarxPlay.stop:
	clr.w	EarxPlay.playing
	move.w	#1,-(A7)
	move.w	#0,-(A7)
	move.w	#0,-(A7)
	move.w	#8,-(A7)
	move.w	#0,-(A7)
	move.w	#$8B,-(A7)
	trap	#14
	lea	12(sp),sp
	rts

EarxPlay.resetVoices:
	lea	Mixer.table,a0
	lea	.void(pc),a1
	moveq	#EarxPlay.MAX_TRACKS-1,d0
.loop_chip:
	lea	Mixer.SIZE(a0),a3
	clr.w	(a0)+	;volume =0
	clr.w	(a0)+
	clr.w	(a0)+
	move.l	a1,(a0)+ ;0 spladdy?
	move.l	#2,(a0)+ ;4
	move.l	a1,(a0)+ ;12 spladdy?
	move.l	#2,(a0)+ ;16
	move.l	a1,(a0)+	;s_ptr_sample
	clr.w	(a0)+	;s_flag_info
	move.l	a3,a0
	dbf	d0,.loop_chip

	lea	Voice.table,a5
	move.w	#(Voice.SIZE*EarxPlay.MAX_TRACKS/2)-1,d1
.loop_cls_voice:
	clr.w	(a5)+
	dbf	d1,.loop_cls_voice
	rts

.void:	dc.w	0		; void, the only likable thing about c

EarxPlay.nextPos:
	addq.w	#1,EarxPlay.position
	clr.w	EarxPlay.pattpos
	rts

; Gets command-values from cyclic buffer.
; Each time a $800 command is encountered, this returns it's parameters.
; Note: $800 stops the player automaticly.
; TODO: block timer a interrupt! Otherwise commands might be skipped!!
; OUTPUT:
; d0.b=parameters ($FF: none)
EarxPlay.getSyncInfo:
	move.w	command_tail,d1
	cmp.w	command_head,d1
	beq.s	.error
	move.b	(command_buffer.l,d1.w),d0
	addq.w	#1,d1
	andi.w	#$001F,d1
	move.w	d1,command_tail
.succes:rts
.error:	moveq	#-1,d0
	rts

;= setup code ==============================================================

save_mfp
	movem.l a0-a1,-(sp)
	lea $fffffa00.w,a0
	lea mfp_save,a1
 	move.l $134.w,(a1)+
	move.b $7(a0),(a1)+
	move.b $9(a0),(a1)+
	move.b $13(a0),(a1)+
	move.b $19(a0),(a1)+
	move.b $1f(a0),(a1)+
	move.W #$2300,sr
	movem.l (sp)+,a0-a1
	rts

EarxPlay.installTimer:
	moveq #0,d0
	lea $fffffa00.w,a0
	;movep.w d0,7(a0)
	move.b #$40,$fffffa17.w
	bclr #3,$fffffa17.w
	bset #5,$fffffa07.w
	bset #5,$fffffa13.w
	clr.b $fffffa19.w
	move.b #246,$fffffa1f.w
	move.b #$7,$fffffa19.w
	move.l #timer_a,$134.w
	move.w #$2300,sr
	rts

restore_mfp
	move.w #$2700,sr
	lea $fffffa00.w,a0
	lea mfp_save,a1
	move.l (a1)+,$134.w
	move.b (a1)+,$7(a0)
	move.b (a1)+,$9(a0)
	move.b (a1)+,$13(a0)
	move.b (a1)+,$19(a0)
	move.b (a1)+,$1f(a0)
	bset #3,$fffffa17.w
	bclr #5,$fffffa07.w
	bclr #5,$fffffa13.w
	move.w	#20000,d0
.atte:	nop
	dbf	d0,.atte
	move.w	#$2300,sr
	rts

timer_a:tst.b	EarxPlay.playing
	beq.s	.no_playing
	ifne	color
	move.l	#$ff000000,$fffff9800.w
	endc
	subq.b	#1,EarxPlay.timerCount
	bpl.s	.no_read
	move.b	EarxPlay.timerBase,EarxPlay.timerCount
	movem.l	d0-a6,-(sp)
	bsr	EarxPlay.playNote
	bsr	EarxPlay.mix
	movem.l	(sp)+,d0-a6
.no_read:
	ifne	color
	move.l	#-1,$fffff9800.w
	endc
.no_playing:
	rte
	

init_sound_config
	move.w	#1,-(A7)			protocol
	move.w	matr_i,-(A7)		
	move.w	#0,-(A7)			25175 KHZ
	move.w	#8,-(A7)			dest=casque/HP
	move.w	#1,-(A7)			source=emission DSP
	move.w	#$8B,-(A7)
	trap	#14
	lea	12(sp),sp
	move.w	#0,-(sp)			timer A
	move.w	#1,-(sp)			playback
	move.w	#135,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#0,-(A7)			;tristate disable dsprec
	move.w	#1,-(A7)			;tristate enable dspxmit
	move.w	#$89,-(A7)
	trap	#14
	addq	#6,sp
	rts

init_freq_table
; d2.l=depth_freq
	lea	freq_table,a0
	moveq	#$4F,d0
.loop1:	clr.l	(a0)+
	dbf	d0,.loop1
	move.w	#900-1,d0
	moveq	#$50,d1
.loop2:	move.l	d2,d4
	divul.l	d1,d4:d4
	move.l	D4,(a0)+
	addq	#1,d1
	dbf	d0,.loop2
; initialiser vitesse entrelac‚e.
	rts

; Translates ciaa bpm to timer a ticks.
init_table_vitesse
	movem.l d0-a6,-(sp)
	lea	EarxPlay.timerTable,a0
	clr.w	(a0)+
	move.w	#254,d7
	moveq	#1,d0
.loop	move.l	d0,d1
	mulu.w	#50*256,d1
	divu.w	#$7d,d1
	move.l	#12288*256,d2
	divu.w	d1,d2
	moveq	#0,d3
.cc	cmp.w	#255,d2
	ble.s	.ok
	lsr.w	#1,d2
	addq.w	#1,d3
	bra.s	.cc
.ok	move.b	d2,(a0)+			; Store #ticks.
	move.b	d3,(a0)+			; Store mfp pre-div.
	addq.w	#1,d0
	dbf	d7,.loop	
	movem.l (sp)+,d0-a6
	rts


load_dsp_prog:
	pea	(EarxPlay.mixerEnd-EarxPlay.mixer)/3.w	
	pea	EarxPlay.mixer(pc)
	move.w	#$6d,-(sp)	
	trap	#14		
	lea	10(sp),sp		
.wc	btst	#3,$fffffa202.w			;on attend la phase d'initialisation DSP
	beq.s	.wc			
	rts

; INPUT:
; d0.w=prgsize in 3byte units
; a0: dsp proggy
load_dsp_prg:					;by NULLOS...
	move.b	#$80+$14,DSP_BASE+1.w		;declenche la host commande...
.waiting:
	tst.b	DSP_BASE+1.w
	bmi.s	.waiting
.send:	subq.l	#1,a0		
	move.l	(a0)+,d1
.loop:	WritHost	d1
	moveq	#-1,d1
	subq.w	#1,d0
	beq.s	.loop
	bpl.s	.send
	rts

;= actual player ===========================================================

; Plays a line from the module. Reads and decodes notes to mixvoices.
EarxPlay.playNote:
; Prepare for looping..
	lea	Voice.table,a4
	lea	Mixer.table,a5
	move.w	EarxPlay.numTracks,d7
	subq.w	#1,d7

; Test if new notes should be read..
	subq.w	#1,EarxPlay.counter		; Decrease counter.
	bgt	.update_fx			; No counter reset -> only update fx.

; Counter reset, could mean we progress to next line..
	move.w	EarxPlay.speed,EarxPlay.counter	; Reset counter.
	tst.w	EarxPlay.pattDelayTime2
	beq.s	.read_note			; No delay -> process next line.
; There is patterndelay, try to move to next line and update fx..
	bsr	EarxPlay.advanceNote
	bra	.update_fx

; patterndelay=0, time to read some notes..
.read_note:
	bsr	EarxPlay.advanceNote

; Find note to play in current pattern.
	movea.l	EarxPlay.modAdr,a1
	movea.l	a1,a0
	adda.w	#Mod.POSTABLE,a0		; a0: position->pattern table
	adda.w	#Mod.PATTERNS,a1		; a1: patterndata
	adda.w	EarxPlay.position,a0
	clr.l	d0
	move.b	(a0),d0				; d0.l=pattnum
	mulu.w	EarxPlay.numTracks,d0
	lsl.l	#8,d0				; d0.l=offset to desired pattern
	adda.l	d0,a1				; a1: desired pattern
	move.w	EarxPlay.pattpos,d0		; d0.w=position in pattern
	mulu.w	EarxPlay.numTracks,d0		; d0.l=offset to position in pattern
	lea	(a1,d0.l*4),a1			; a1: note on 1st track

; Process the new notes in this line..
.new_loop:
; Read protracker note..
	move.w	(a1)+,d2			; d2.w=$Ifff
	move.w	(a1)+,d0			; d0.w=$icPp
; Decode protracker note to: command+pars, instrument, period.
; instrument# I: upper nibble, i: lower nibble
; f: frequency (period)
; c: command (encoded)
; p: command parameters
	move.w	d0,d1
	lsr.w	#8,d1
	lsr.w	#4,d1				; d1.w=$000i
	move.w	d2,d3
	andi.w	#$F000,d2			; d2.w=$I000
	sub.w	d2,d3				; d3.w=$0fff
	lsr.w	#8,d2				; d2.w=$00I0
	add.w	d2,d1				; d1.w=$00Ii
	move.w	d3,Voice.IPERIOD(a4)		; Store period (freq).
	move.b	d1,Voice.SAMPLE(a4)		; Store instrument.
	move.w	d0,d3
	and.w	#$0F00,d3			; d3.w=$0c00
	lsr.w	#8,d3				; d3.w=$000c
	clr.w	d1
	move.b	d0,d1				; d1.w=$00Pp
	cmp.w	#$E,d3
	bne.s	.no_e_effect			; c<>$E -> not filter and not special
	move.w	d0,d2
	lsr.b	#4,d2				; d2.b=$0P
	beq.s	.no_e_effect			; upper parnibble unused -> no special effect
	addq.b	#1,d3
	add.b	d2,d3				; d3.b=specialcommand=P+1+c
	and.b	#$0F,d1				; d1.b=specialpars=p.
.no_e_effect:
; d1.b=commandpars (still encoded)
	move.b	d3,Voice.CMD(a4)		; Store command.
	jsr	(modi_comm.w,pc,d3.w*4)		; Decode parameters for command.
	move.w	d1,Voice.COMMANDPARS(a4)	; Output commandpars. (a word for a byte, lame)

;- ready to kick some notes ------------------------------------------------
	pea	(a1)
	clr.l	d0
	move.b	Voice.SAMPLE(a4),d0
	beq.s	.inst_nul	;instrument nul?

;tape le sample
	subq.w	#1,d0
	move.l	d0,d1
	movea.l	EarxPlay.modAdr,a1		; a1: mod
	adda.w	#Mod.SAMPLES,a1			; a1: sampledescriptors
	mulu.w	#ModSample.SIZE,d0		; d0.l=offset to sampledesciptor
	adda.l	d0,a1				; a1: desired sampledescriptor
	move.l	(EarxPlay.splAdrTable,d1.l*4),d1
	move.l	d1,Voice.START(a4)
	clr.l	d0
	move.w	ModSample.LENGTH(a1),d0
	add.l	d0,d0				; Words to bytes..
	move.l	d0,Voice.LENGTH(a4)
	clr.w	d0
	move.b	ModSample.VOLUME(a1),d0
	lsl.w	#8,d0
	move.w	d0,Voice.VOLUME(a4)		; 0<=v<=64*256
	move.b	ModSample.FINETUNE(a1),Voice.FINETUNE(a4)		; Store finetune.
	clr.l	d0
	move.w	ModSample.LOOPSTART(a1),d0
	add.l	d0,d0				; Words to bytes.
	add.l	d1,d0
	move.l	d0,Voice.LOOPSTART(a4)
	move.l	d0,Voice.WAVESTART(a4)
	clr.l	d0
	move.w	ModSample.LOOPLEN(a1),d0
	add.l	d0,d0				; Words to bytes.
	move.l	d0,Voice.REPLEN(a4)

	clr.b	Mixer.INFO(a5)

;	voir PROTRACK	(c 1 bordel !!)
.inst_nul:
	clr.l	d0
	move.b	Voice.CMD(a4),d0
;	cmp.b	#$E,d0
;	beq.s	.no_filter
;	bsr	pt_filteronoff
;.no_filter
	tst.w	Voice.IPERIOD(a4)
	beq.s	.search_command1	;periode nul?
;	commande 3 7 9
	jsr	(pt_read_pattern_table1.w,pc,d0.l*4)
	bra.s	.check_for_next
.search_command1
	jsr	(pt_read_pattern_no_note.w,pc,d0.l*4)
.check_for_next
	move.w	Voice.VOLUME(a4),d0
	lsr.w	#8,d0
	move.w	d0,Mixer.VOLUME(a5)
	move.b	Voice.FINETUNE(a4),Mixer.FINETUNE(a5)
	move.l	Voice.LOOPSTART(a4),Mixer.LOOPSTART(a5)
	move.l	Voice.REPLEN(a4),Mixer.LOOPLENGTH(a5)	
	adda.w	#Mixer.SIZE,a5
	adda.w	#Voice.SIZE,a4
	move.l	(sp)+,a1
	dbf	d7,.new_loop	
	rts

.update_fx:
; Update old fx..
.update_old_loop:
	bsr	EarxPlay.updateFunk
	move.w	Voice.NPERIOD(a4),Mixer.PERIOD(a5)
	clr.l	d0
	move.b	Voice.CMD(a4),d0
	jsr	(EarxPlay.checkEffectsTable.w,pc,d0.l*4)
	move.w	Voice.VOLUME(a4),d0
	lsr.w	#8,d0
	move.w	d0,Mixer.VOLUME(a5)
	move.b	Voice.FINETUNE(a4),Mixer.FINETUNE(a5)
	adda.w	#Mixer.SIZE,a5
	adda.w	#Voice.SIZE,a4
	dbf	d7,.update_old_loop
	rts

; Advances the player to next line keeping in mind delay.
EarxPlay.advanceNote:
; Update pattpos and position..
	move.w	EarxPlay.pattpos,d0		; d0.w=old patternposition
	addq.w	#1,d0				; d0.w='new' pattpos

; delay shit..
	move.w	EarxPlay.pattDelayTime2,d2
	move.w	EarxPlay.pattDelayTime,d1
	beq.s	.pt_dskpc
	move.w	d1,d2
	clr.w	EarxPlay.pattDelayTime
.pt_dskpc:
	tst.w	d2
	beq.s	.no_ptdskpa
	subq.w	#1,d2
	beq.s	.no_ptdskpa
	subq.w	#1,d0	
.no_ptdskpa:
	move.w	d2,EarxPlay.pattDelayTime2

	cmpi.w	#64,d0
	blo.s	.pattpos_ok
	clr.w	d0				; Reset patternposition.
	move.w	EarxPlay.position,d1		; d1.w=(old) position
	addq.w	#1,d1				; Increase position.
	movea.l	EarxPlay.modAdr,a0
	cmp.b	Mod.POSITIONS(a0),d1
	blt.s	.pos_ok
	clr.w	d1
	move.b	Mod.REPEAT(a0),d1		; Wrap position.
	cmp.b	Mod.POSITIONS(a0),d1
	blt.s	.pos_ok
	clr.w	d1
.pos_ok:move.w	d1,EarxPlay.position		; Store position.
.pattpos_ok:
	move.w	d0,EarxPlay.pattpos		; Store patternposition.
	rts

;= effect tables ===========================================================

pt_funktable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

pt_vibratotable	
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

pt_periodtable
; -> Tuning 0
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113,0
; -> Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113,0
; -> Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112,0
; -> Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111,0
; -> Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110,0
; -> Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109,0
; -> Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109,0
; -> Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108,0
; -> Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120,0
; -> Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119,0
; -> Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118,0
; -> Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118,0
; -> Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117,0
; -> Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116,0
; -> Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115,0
; -> Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114,0

;= command handling routs ==================================================

; used for converting parameters in an 'easy' format.
modi_comm:
	bra.w	pt_parpeggio		;0	
	bra.w	return			;1	
	bra.w	return			;2	
	bra.w	return			;pt_settoneporta	;3
	bra.w	pt_pvibrato		;4
	bra.w	pt_pvolumeslide		;
	bra.w	pt_pvolumeslide		;
	bra.w	pt_ptremolo		;
	bra.w	return			;8
	bra.w	pt_psampleoffset	;9
	bra.w	pt_pvolumeslide		;10
	bra.w	return			;11
	bra.w	pt_pvolumechange	;12
	bra.w	pt_ppatternbreak	;13
	bra.w	return			;pt_FilterOnOff		;14
	bra.w	return			;pt_SetSpeed		;15
	bra.w	return			;pt_FinePortaUp		;16
	bra.w	return			;pt_FinePortaDown	;17
	bra.w	pt_pSetGlissControl	;18
	bra.w	return			;pt_SetVibratoControl	;19
	bra.w	pt_psetfinetune		;20
	bra.w	return			;pt_JumpLoop		;21
	bra.w	return			;pt_SetTremoloControl	;22
	bra.w	return			;pt_KarplusStrong	;23
	bra.w	return			;pt_RetrigNote		;24
	bra.w	pt_pVolumeFineUp	;25
	bra.w	pt_pVolumeFineDown	;26
	bra.w	return			;pt_NoteCut		;27
	bra.w	return			;pt_NoteDelay		;28
	bra.w	return			;pt_PatternDelay	;29
	bra.w	return			;pt_FunkIt		;30

pt_ptremolo
pt_pvibrato
	lsl.w	#4,d1
	lsr.b	#4,d1
	rts
pt_parpeggio
	lsl.w	#4,d1
	lsr.b	#4,d1
	rts
pt_psampleoffset
	lsl	#8,d1	;*256
	rts

pt_pvolumeslide
	and	#$ff,d1
	move	d1,d2
	lsr	#4,d2
	tst.b	d2
	beq.s	pt_pVolSlideDown
	lsl	#8,d2
	move	d2,d1
	rts

pt_pVolSlideDown
	and	#$f,d1
	lsl	#8,d1
	neg	d1
	rts

pt_pVolumeFineUp
	and	#$f,d1
	lsl	#8,d1
	rts

pt_pVolumeFineDown
	and	#$f,d1
	lsl	#8,d1
	neg	d1
	rts

pt_psetfinetune
pt_pSetGlissControl
	;and	#$f,d1
	rts

pt_pvolumechange	
	cmp.w	#$40,d1
	ble.s	.end
	moveq	#$40,d1
.end:	rts

pt_ppatternbreak		;13
	movem.l	d0/d2,-(sp)
	move.l	d1,d2
	lsr.b	#4,d1
	mulu	#10,d1
	and.w	#$f,d2
	add.w	d2,d1
	cmp.w	#63,d1
	ble.s	.end_effect
	clr.w	d1
.end_effect
	movem.l	(sp)+,d0/d2
	rts


EarxPlay.checkEffectsTable:
	bra.w	pt_arpeggio			;
	bra.w	pt_portaup			;	
	bra.w	pt_portadown			;
	bra.w	pt_toneportamento		;
	bra.w	pt_vibrato			;
	bra.w	pt_toneplusvolslide		;
	bra.w	pt_vibratoplusvolslide		;
pt_SetBack
	bra.w	pt_tremolo
	bra.w	return			;8	;PHASOR
	bra.w	return			;9	;
	bra.w	pt_volumeslide			;
	bra.w	return			;11	;
	bra.w	return			;12	;
	bra.w	return			;13	;
	bra.w	return			;14	;
	bra.w	return			;15	;
	bra.w	return		;16		;
	bra.w	return		;17	;
	bra.w	pt_setglisscontrol	;18	;
	bra.w	pt_setvibratocontrol	;19	;
	bra.w	pt_setfinetune	;20		;
	bra.w	return		;21		;
	bra.w	pt_settremolocontrol	;22	;
	bra.w	pt_karplusstrong	;23	;
	bra.w	pt_retrignote	;24
	bra.w	return		;25
	bra.w	return		;26
	bra.w	pt_notecut	;27
	bra.w	pt_notedelay	;28
	bra.w	return		;29
	bra.w	return		;30


;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

pt_read_pattern_table1
	bra.w	pt_initperiod		;
	bra.w	pt_initperiod		;
	bra.w	pt_initperiod		;
	bra.w	pt_chktoneporta	;
	bra.w	pt_initperiod		;
	bra.w	pt_chktoneporta	;
	bra.w	pt_initperiod		;
;pt_SetBack
	bra.w	pt_initperiod
	bra.w	pt_initperiod		;8	;phasor effect ?!?
	bra.w	pt_dosampleoffset	;9	
	rept	21
	bra.w	pt_initperiod		;10
	endr

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

pt_read_pattern_table2
	bra.w	return		;
	bra.w	return		;
	bra.w	return		;
	bra.w	return		;
	bra.w	return		;
	bra.w	return		;
	bra.w	return		;
;pt_SetBack
	bra.w	return

;	bra.w	return			;8	;phasor effect ?!?
	bra.w	pt_docommand8

	bra.w	return			;9	;
	bra.w	return			
	bra.w	pt_positionjump		;11	;
	bra.w	pt_volumechange		;12	;
	bra.w	pt_patternbreak		;13	;
	bra.w	return			;14	;
	bra.w	pt_setspeed		;15	;
	bra.w	pt_fineportaup		;16	;
	bra.w	pt_fineportadown	;17	;
	bra.w	pt_setglisscontrol	;18	;
	bra.w	pt_setvibratocontrol	;19	;
	bra.w	pt_dosetfinetune	;20	;
	bra.w	pt_jumploop		;21	;
	bra.w	pt_settremolocontrol	;22	;
	bra.w	pt_karplusstrong	;23	;
	bra.w	pt_retrignote		;24
	bra.w	pt_volumefineup		;25	;
	bra.w	pt_volumefinedown	;26	;
	bra.w	pt_notecut		;27
	bra.w	pt_notedelay		;28
	bra.w	pt_patterndelay		;29	;
	bra.w	pt_funkit		;30	;

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

pt_read_pattern_no_note
	bra.w	return
	bra.w	return
	bra.w	return
	bra.w	return
	bra.w	return
	bra.w	return
	bra.w	return
	bra.w	return

	bra.w	pt_docommand8
;	bra.w	return

	bra.w	pt_sampleoffset	;9	;
	bra.w	return			;
	bra.w	pt_positionjump	;11	;
	bra.w	pt_volumechange	;12	;
	bra.w	pt_patternbreak	;13	;
	bra.w	return		;14	;
	bra.w	pt_setspeed	;15	;
	bra.w	pt_fineportaup		;16	;
	bra.w	pt_fineportadown	;17	;
	bra.w	pt_setglisscontrol	;18	;
	bra.w	pt_setvibratocontrol	;19	;
	bra.w	pt_setfinetune		;20	;
	bra.w	pt_jumploop		;21	;
	bra.w	pt_settremolocontrol	;22	;
	bra.w	pt_karplusstrong	;23	;
	bra.w	pt_retrignote		;24	;
	bra.w	pt_volumefineup		;25	;
	bra.w	pt_volumefinedown	;26	;
	bra.w	pt_notecut		;27	;
	bra.w	pt_notedelay		;28	;
	bra.w	pt_patterndelay		;29	;
	bra.w	pt_funkit		;30	;

return:	rts

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

; Store command-value in cyclic buffer.
pt_docommand8:
	move.w	command_head,d0
	move.b	Voice.COMMANDPARS+1(a4),d1
	IFNE	EarxPlay.SYNCMODE
	bne.s	.store
; Command 0 : stop playing!
	movem.w	d0-d1,-(sp)
	bsr.w	EarxPlay.stop
	movem.w	(sp)+,d0-d1
	ENDC
.store:	move.b	d1,(command_buffer,d0.w)
	addq.w	#1,d0
	andi.w	#$001F,d0
	move.w	d0,command_head
	rts

pt_dosetfinetune
	bsr	pt_setfinetune
	bsr	pt_setperiod ;; non defini.
	rts

pt_chktoneporta
	bsr	pt_settoneporta
	moveq	#0,d0
	move.b	Voice.CMD(a4),d0
	jmp	(EarxPlay.checkEffectsTable.w,pc,d0.l*4)	;effets 3 5

pt_dosampleoffset
	bsr	pt_sampleoffset
	bsr	pt_setperiod				;effet 9
	set_wave_ctrl
	rts
	
pt_initperiod
	bsr.s	pt_setperiod
	moveq	#0,d0
	move.b	Voice.CMD(a4),d0
	cmp.b	#28,d0
	beq	pt_notedelay
	set_wave_ctrl
	jmp	(pt_read_pattern_table2.w,pc,d0.l*4)
	rts

pt_setperiod:
	lea	pt_periodtable(pc),a0
	move.w	Voice.IPERIOD(a4),d0
	clr.l	d3
	move.b	Voice.FINETUNE(a4),d3
	beq.s	.set_direcper
	se_period	a0,d0,d2,d1
	mulu	#37,D3
	add.w	d3,d2
	move	-2(a0,d2*2),Voice.NPERIOD(a4)
	rts
.set_direcper
	move	d0,Voice.NPERIOD(a4)
	rts

pt_arpeggio
	moveq	#0,d1
	move	EarxPlay.counter,d0
	divs	#3,d0
	swap	d0
	subq	#1,d0
	beq.s	.set_direct_period	
	bmi.s	.pt_arpegio1
.pt_arpegio2
	move.b	Voice.COMMANDPARS+1(a4),d1	
	bra.s	.next_arp
.pt_arpegio1
	move.b	Voice.COMMANDPARS(a4),d1	
.next_arp
	moveq	#0,d0
	move.b	Voice.FINETUNE(a4),d0
	mulu	#37*2,d0
	lea	pt_periodtable(pc),a0
	add.l	d0,a0
	move	Voice.NPERIOD(a4),d0
	se_period2	a0,d0,d2
.arpegio_set	
	move	(a0,d1*2),Mixer.PERIOD(a5)
	rts
.set_direct_period
	rts

pt_settoneporta	
	move	Voice.IPERIOD(a4),d2
	moveq	#0,d0
	move.b	Voice.FINETUNE(a4),d0
	beq.s	.set_direcper
	mulu	#37*2,d0
	lea	(pt_periodtable.w,pc,d0),a0
	se_period2	a0,d2,d0
	move.b	Voice.FINETUNE(a4),d2
	and.b	#8,D2
	beq.s	.pt_stpgoss
	subq	#2,a0
.pt_stpgoss
	move	(a0),d2	; d'apres
.set_direcper
	move	d2,Voice.WANTEDPERIOD(a4)	
	sf	Voice.TONEPORTDIRECT(a4)
	cmp	Voice.NPERIOD(a4),d2
	beq.s	.pt_cleartoneporta	
	bge.s	.return
	st	Voice.TONEPORTDIRECT(a4)
.return
	rts
.pt_cleartoneporta
	clr.w	Voice.WANTEDPERIOD(a4)
	rts

pt_toneportamento
	move	Voice.COMMANDPARS(a4),d0
	beq.s	pt_toneportnochange
	clr.w	Voice.COMMANDPARS(a4)
	move	d0,Voice.TONEPORTSPEED(a4)
pt_toneportnochange
	move.w	Voice.WANTEDPERIOD(a4),d0
	beq.s	.return
	move	Voice.NPERIOD(a4),d2	;
	move	Voice.TONEPORTSPEED(a4),d1
	tst.b	Voice.TONEPORTDIRECT(a4)
	bne.s	.pt_toneportaup
.pt_toneportadown
	add	d1,d2
	cmp	d2,d0
	bgt.s	.pt_toneportasetper
	bra.s	.set_reg
.pt_toneportaup
	sub	d1,d2
	cmp	d2,d0
	blt.s	.pt_toneportasetper
.set_reg
	move	d0,d2
	clr.w	Voice.WANTEDPERIOD(a4)
.pt_toneportasetper
	move	d2,Voice.NPERIOD(a4)
	tst.b	Voice.GLISSFUNK+1(a4)
	beq	.pt_glissskip
	moveq	#0,d0
	move.b	Voice.FINETUNE(a4),d0
	mulu	#37*2,d0
	lea	(pt_periodtable.w,pc,d0),a0
	se_period2	a0,d2,d0
	move	(a0),d2
.pt_glissskip
	move	d2,Mixer.PERIOD(a5)
	rts
.return:rts

pt_vibrato
	move	Voice.COMMANDPARS(a4),d0
	beq.s	pt_vibrato2
	tst.b	d0
	beq.s	.pt_vibskip	
	move.b	d0,Voice.VIBRATOCMD+1(a4)
.pt_vibskip	
	lsr.w	#8,d0
	tst.b	d0
	beq.s	pt_vibrato2	
	move.b	d0,Voice.VIBRATOCMD(a4)
pt_vibrato2
	move.b	Voice.VIBRATOPOS(a4),d0
	lea	pt_vibratotable(pc),a1
	lsr	#2,d0
	and	#$1f,d0
	moveq	#0,d2
	move.b	Voice.WAVECONTROL+1(a4),d2
	and.b	#$3,d2
	beq.s	.pt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	.pt_vib_rampdown
	st	d2
	bra.s	.pt_vib_set
.pt_vib_rampdown
	move.b	d0,d2
	tst.b	Voice.VIBRATOPOS(a4)
	bpl.s	.pt_vib_set
	st	d2
	sub.b	d0,d2
	bra.s	.pt_vib_set
.pt_vib_sine
	move.b	(a1,d0.w),d2
.pt_vib_set
	
	move.b	Voice.VIBRATOCMD+1(a4),d0	
	mulu	d0,d2
	lsr.w	#7,d2
	
	move	Voice.NPERIOD(a4),d1
	tst.b	Voice.VIBRATOCMD(a4)
	bpl.s	.pt_vibratopos
	neg	d2
.pt_vibratopos
	add	d2,d1
	move	d1,Mixer.PERIOD(a5)
	
	move.b	Voice.VIBRATOCMD(a4),d1
	lsl.b	#4,d1
	or.b	d0,d1
	lsr.w	#2,d1
	and	#$3c,d1
	add.b	d1,Voice.VIBRATOCMD(a4)

	rts

pt_toneplusvolslide	
	bsr	pt_toneportnochange
	bra	pt_volumeslide

pt_vibratoplusvolslide
	bsr	pt_vibrato2
	bra	pt_volumeslide

pt_tremolo
	move	Voice.COMMANDPARS(a4),d0
	beq.s	pt_tremolo2
	tst.b	d0
	beq.s	.pt_treskip	
	move.b	d0,Voice.TREMOLOCMD+1(a4)
.pt_treskip	
	lsr.w	#8,d0
	tst.b	d0
	beq.s	pt_tremolo2	
	move.b	d0,Voice.TREMOLOCMD(a4)
pt_tremolo2
	move.b	Voice.TREMOLOPOS(a4),d0
	lea	pt_vibratotable(pc),a1
	lsr	#2,d0
	and	#$1f,d0
	moveq	#0,d2
	move.b	Voice.WAVECONTROL(a4),d2
	and.b	#$3,d2
	beq.s	.pt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	.pt_tre_rampdown
	st	d2
	bra.s	.pt_tre_set
.pt_tre_rampdown
	move.b	d0,d2
	tst.b	Voice.TREMOLOPOS(a4)
	bpl.s	.pt_tre_set
	st	d2
	sub.b	d0,d2
	bra.s	.pt_tre_set
.pt_tre_sine
	move.b	(a1,d0.w),d2
.pt_tre_set
	move.b	Voice.TREMOLOCMD+1(a4),d0	
	mulu	d0,d2
	lsl	#2,d2
	move	Voice.VOLUME(a4),d0
	
	tst.b	Voice.TREMOLOPOS(a4)
	bpl.s	.pt_vibratopos
	neg	d2
.pt_vibratopos
	add	d2,d0
	bpl.s	.no_negv
	moveq	#0,d0
.no_negv
	cmp	#$4000,d0
	ble.s	.nohiv
	move	#$4000,d0
.nohiv:	lsr.w	#8,d0
	move.w	d0,Mixer.VOLUME(a5)
	move.b	Voice.TREMOLOCMD(a4),d1
	lsl.b	#4,d1
	or.b	Voice.TREMOLOCMD+1(a4),d1
	lsr.b	#2,d1
	and	#$3c,d1
	add.b	d1,Voice.TREMOLOPOS(a4)
;	ne plus fixer le volume.
	rts

pt_sampleoffset	
	moveq	#0,d0
	move.w	Voice.COMMANDPARS(A4),D0
	beq.s	pt_sononew
	move.w	d0,Voice.SPLOFFSET(A4)
pt_sononew
	move.w	Voice.SPLOFFSET(A4),D0
	cmp.l	Voice.LENGTH(A4),D0
	bge.s	pt_sofskip
	sub.l	d0,Voice.LENGTH(A4)
	add.l	d0,Voice.START(A4)
	move.l	Voice.START(A4),Mixer.START(A5)	;Set sampledata pointer
	move.l	Voice.LENGTH(A4),Mixer.LENGTH(A5)	;Set length
	rts
pt_sofskip
	move.l	#1,Voice.LENGTH(A4)		;plus de sample?
	move.l	Voice.LENGTH(A4),Mixer.LENGTH(A5)	;Set length
	rts

pt_volumeslide
	move.w	Voice.COMMANDPARS(a4),D0
vol_slide_return
	move	Voice.VOLUME(a4),d1
	add	d0,d1
	bge.s	.vol_noneg
	clr	d1
.vol_noneg
	cmpi.w	#$4000,d1
	ble.s	.vol_nohi
	move.w	#$4000,d1
.vol_nohi
	move.w	d1,Voice.VOLUME(a4)
	lsr.w	#8,d1
	move.w	d1,Mixer.VOLUME(a5)
	rts

pt_positionjump	
	move.w	Voice.COMMANDPARS(A4),D0
	subq.w	#1,d0
	move.w	d0,EarxPlay.position
	move.w	#-1,EarxPlay.pattpos
	rts

pt_volumechange
	move.w	Voice.COMMANDPARS(a4),d0
	lsl.w	#8,d0
	move.w	d0,Voice.VOLUME(a4)
	rts

pt_patternbreak:
	addq.w	#1,EarxPlay.position
	move.w	Voice.COMMANDPARS(a4),d0
	subq.w	#1,d0
	move.w	d0,EarxPlay.pattpos
	rts

pt_filteronoff	
;	synchro ..
;	st	filter	
	rts

pt_setspeed:	
	move.w	Voice.COMMANDPARS(a4),d0
	beq.s	.speed_nul
	movea.l	EarxPlay.modAdr,a0
; We assume ciaa mode here..
	cmpi.b	#$20,d0
	bhs.s	set_tempo
.no_ciaamode:
	move.w	d0,EarxPlay.counter
	move.w	d0,EarxPlay.speed
.speed_nul:
	rts

set_tempo:
	clr.l	d1
	move.b	d0,d1
	move.w	(EarxPlay.timerTable.l,d1.l*2),d0
	move.b	d0,EarxPlay.timerCount
	move.b	d0,EarxPlay.timerBase
	lsr.w	#8,d0
	clr.b	$fffffa19.w			; Stop timer a.
	move.b	d0,$fffffa1f.w
	move.b	#$7,$fffffa19.w			; prediv = 200
	rts

pt_fineportaup	
pt_portaup
	move	Voice.NPERIOD(a4),d0
	sub	Voice.COMMANDPARS(a4),d0
	cmp	#$71,d0
	bge.s	.no_lower_per
	move	#$71,d0
.no_lower_per
	move	d0,Voice.NPERIOD(a4)
	move	d0,Mixer.PERIOD(a5)
	rts

pt_fineportadown	
pt_portadown
	move	Voice.NPERIOD(a4),d0
	add	Voice.COMMANDPARS(a4),d0
	cmp	#$358,d0
	bmi.s	.no_lower_per
	move	#$358,d0
.no_lower_per
	move	d0,Voice.NPERIOD(a4)
	move	d0,Mixer.PERIOD(a5)
	rts

pt_setglisscontrol	
	move.b	Voice.COMMANDPARS+1(a4),Voice.GLISSFUNK+1(a4)	
	rts

pt_setvibratocontrol	
	move.b	Voice.COMMANDPARS+1(a4),Voice.WAVECONTROL+1(a4)	
	rts

pt_setfinetune	
	move.b	Voice.COMMANDPARS+1(a4),Voice.FINETUNE(a4)
	rts

pt_jumploop	
	move	Voice.COMMANDPARS(a4),d0
	beq.s	pt_setloop
	tst.w	Voice.LOOPCOUNT(A4)
	beq.s	pt_jumpcnt
	subq	#1,Voice.LOOPCOUNT(A4)
	beq.s	return_pt
pt_jmploop
	move.w	Voice.PATTPOS(a4),EarxPlay.breakPos
	st	EarxPlay.pbreak
	rts
pt_jumpcnt
	move.w	d0,Voice.LOOPCOUNT(A4)
	move.w	Voice.PATTPOS(a4),EarxPlay.breakPos
	st	EarxPlay.pbreak
	rts
pt_setloop
	move.w	EarxPlay.pattpos,Voice.PATTPOS(a4)
return_pt
	rts

pt_settremolocontrol	
	move.b	Voice.COMMANDPARS+1(a4),Voice.WAVECONTROL(a4)
	rts

pt_karplusstrong	
	move.l	Voice.LOOPSTART(a4),a0
	move.l	a0,a1
	btst	#0,Voice.SINFO(a4)
	bne.s	.sample_16bits
	move.l	Voice.REPLEN(a4),d0
	move.b	(a0),d1
.pt_karplop
	ext	d1
	move.b	1(a0),d2
	ext	d2
	add	d2,d1
	asr	d1
	move.b	d1,(a0)+
	exg	d2,d1
	subq.l	#1,d0
	bne.s	.pt_karplop
	move.b	(a1),d2
	ext	d2
	add	d1,d2
	asr	d2
	move.b	d2,(a0)
	rts

.sample_16bits
	move	Voice.REPLEN(a4),d0
	lsr	d0
	move.w	(a0),d1
.pt_karplop2
	ext.l	d1
	move.w	2(a0),d2
	ext.l	d2
	add.l	d2,d1
	asr.l	d1
	move.w	d1,(a0)+
	exg	d2,d1
	subq.l	#1,d0
	bne.s	.pt_karplop2
	move.w	(a1),d2
	ext.l	d2
	add.l	d1,d2
	asr.l	d2
	move.w	d2,(a0)
	rts

pt_retrignote:
	move.w	Voice.COMMANDPARS(A4),D0
	beq.s	.end
	clr.l	d1
	move.w	EarxPlay.counter,D1
	bne.s	.skip
	tst.w	Voice.IPERIOD(A4)
	bne.s	.end
.skip:	divu.w	D0,D1
	swap	d1
	tst.w	d1
	bne.s	.end
	MOVE.L	Voice.START(A4),Mixer.START(A5)		;Set sampledata pointer
	MOVE.l	Voice.LENGTH(A4),Mixer.LENGTH(A5)	;Set length
	MOVE.w	Voice.NPERIOD(A4),Mixer.PERIOD(A5)
	MOVE.L	Voice.LOOPSTART(A4),Mixer.LOOPSTART(A5)
	MOVE.L	Voice.REPLEN(A4),Mixer.LOOPLENGTH(A5)
	clr.b	Mixer.INFO(a5)				; Tell mixer to start sample again.
.end:	rts

pt_volumefineup	
pt_volumefinedown	
	move.w	Voice.COMMANDPARS(a4),D0
	bra	vol_slide_return
	rts

pt_notecut	
	move.w	Voice.COMMANDPARS(a4),D0
	cmp.w	EarxPlay.counter,D0
	bne.s	.return
	clr.w	Voice.VOLUME(A4)
.return
	rts

pt_notedelay	
	move.w	Voice.COMMANDPARS(a4),d0
	cmp.w	EarxPlay.counter,D0
	bne.s	.return
	move	Voice.NPERIOD(a4),d0
	beq.s	.return
	move.b	#$fe,Mixer.FLAGINFO(a5)	;s_ptr_sample(a5)=s_loopstart(a5)	
	move.L	Voice.START(A4),Mixer.START(A5)	;Set sampledata pointer
	move.l	Voice.LENGTH(A4),Mixer.LENGTH(A5)	;Set length
	move.w	d0,Mixer.PERIOD(A5)
	move.L	Voice.LOOPSTART(A4),Mixer.LOOPSTART(A5)
	move.L	Voice.REPLEN(A4),Mixer.LOOPLENGTH(A5)
.return
	rts

pt_patterndelay	
	move.w	Voice.COMMANDPARS(A4),D0
	tst.w	EarxPlay.pattDelayTime2
	bne.s	.return
	addq.w	#1,d0
	move.w	d0,EarxPlay.pattDelayTime
.return:rts

pt_funkit	
	move.b	Voice.COMMANDPARS(a4),d0
	move.b	d0,Voice.GLISSFUNK(a4)
	tst.w	Voice.GLISSFUNK(a4)
	beq.s	pt_funkend

EarxPlay.updateFunk:
	move.b	Voice.GLISSFUNK(a4),D0
	beq.s	pt_funkend
	lea	pt_funktable(PC),a2
	move.b	(a2,d0.w),d0
	add.b	d0,Voice.FUNKOFFSET(a4)
	btst	#7,Voice.FUNKOFFSET(a4)
	beq.s	pt_funkend
	clr.b	Voice.FUNKOFFSET(a4)
	move.l	Voice.LOOPSTART(a4),D0
	move.l	Voice.REPLEN(a4),D1
	add.l	d1,d0
	add.l	d1,d0
	move.l	Voice.WAVESTART(a4),a2
	addq.l	#1,a2
	cmp.l	d0,a2
	blo.s	.pt_funkok
	move.l	Voice.LOOPSTART(a4),a2
.pt_funkok
	move.l	a2,Voice.WAVESTART(a4)	;sert a quoi?
	not.b	(a2)
pt_funkend:
	rts


;= mixer ===================================================================
;
; Mixes and resamples the stuff given by Mixer.table.
; Uses the dsp mixer remake by earx.
;

EarxPlay.mix:
	lea	DSP_BASE+2.w,a5			; a5: host status reg
	lea	4(a5),a3			; a3: host tx/rx (lower word)
	save_host
	WritHost	#$1			; Tell dsp, mixing is still active..
	move.l	#$0003FFFF,d3			; d3.l=global vol
	clr.w	Mixer.firstl
	lea	Mixer.lrTable,a1
	lea	Mixer.table,a4
	move.w	EarxPlay.numTracks,d7		; d7.w>=4
	divu.w	d7,d3				; d3.w= vol per channel
	subq.w	#1,d7

.voice_loop:
	clr.l	d0
	move.b	(a1)+,d0			; d0.b=chn info
	pea	(a1)

; If voice is mute, don't mix!
	cmpi.b	#$FD,Mixer.INFO(a4)
	beq	.next_track
	move.w	Mixer.VOLUME(a4),d1
	beq	.next_track

; Check channel and if you can move instead of add..
	tst.b	d0
	bmi	.next_track
	bne.s	.right_voice
.left_voice
	tst.b	Mixer.firstl
	bne.s	.add_voice
	st	Mixer.firstl
	bra.s	.move_voice
.right_voice
	tst.b	Mixer.firstr
	bne.s	.add_voice
	st	Mixer.firstr
.move_voice:
	addq.w	#%010,d0
.add_voice:

; bit 0: 0=l, 1=r; bit 1: 0=add, 1=move; bit 2: 1=play special spl
	WritHost	d0

; Send trackvolume.
; d1.w=spl volume, d3.w=channel volume
	mulu.w	d3,d1
	WritHost	d1

; Send frequency, get blocklength
	move.w	Mixer.PERIOD(a4),d1
	move.l	(freq_table.l,d1.w*4),d1
	WritHost	d1			; Send frequency.
	ReadHost	d0			; d0.l=bytes to send (blocksize)
	beq	.next_track

	move.l	d0,.blocksize

; Start sample, if not already started.
	tst.b	Mixer.INFO(a4)
	bne.s	.sample_started
	move.l	Mixer.START(a4),Mixer.SAMPLEADR(a4)
	st	Mixer.INFO(a4)
.sample_started:

; d0.l=blocksize
; Set defaults for no-wrap situation.
	move.l	d0,.head
	clr.w	.nr_loops
	clr.l	.tail

; Test for wrapping..
; Split the block up in head, body (loops) and tail parts..
	move.l	Mixer.SAMPLEADR(a4),d1
	movea.l	d1,a1				; a1: actual pos
	add.l	d0,d1				; d1.l: unwrapped next pos
	cmpi.b	#$FE,Mixer.INFO(a4)
	beq.s	.handle_loop

.handle_whole_play:
	move.l	Mixer.START(a4),d2
	add.l	Mixer.LENGTH(a4),d2		; d2.l: sample_end
	cmp.l	d2,d1
	ble.s	.admin_done			; If not wrapped, don't split up.
; This frame contains a possible loop.. Check if it has one..
	cmpi.l	#2,Mixer.LOOPLENGTH(a4)
	bhi.s	.looplength_okay
	move.b	#$FD,Mixer.INFO(a4)		; Indicate mute.
	bra.s	.looplength_checked
.looplength_okay:
	move.b	#$FE,Mixer.INFO(a4)		; Indicate loop.
.looplength_checked:
	sub.l	d2,d1				; d1.l=loops+tail
.calc_h_l_t:
	move.l	d0,d2				; d2.l=blocksize=head+loops+tail
	sub.l	d1,d2				; d2.l=head
	move.l	d2,.head			; Store headsize.
	clr.l	d2
	divu.l	Mixer.LOOPLENGTH(a4),d2:d1
	move.w	d1,.nr_loops			; Store #loops.
	move.l	d2,.tail			; Store tailsize.
	add.l	Mixer.LOOPSTART(a4),d2
	move.l	d2,d1				; d1.l= next pos.
	bra.s	.admin_done

.handle_loop:
	move.l	Mixer.LOOPSTART(a4),d2
	add.l	Mixer.LOOPLENGTH(a4),d2		; d2.l: loop_end
	cmp.l	d2,d1
	ble.s	.admin_done
	sub.l	d2,d1				; d1.l=loops+tail
	bra.s	.calc_h_l_t

.admin_done:
	move.l	d1,Mixer.SAMPLEADR(a4)		; Store next pos.

; Write the block (head, loops, tail)..
; Warning: this sends (blocksize/2 + 1) words!
; (plus a parity byte if required)
; a1: actual pos

; Give packet info to dsp..
	move.l	a1,d1				; d1.l: actual pos
	env	(a5)
	move.w	d1,(a3)				; Transfer start to let dsp see parity..

; Send definitive size to dsp..
	move.l	.blocksize(pc),d0
	cmpi.b	#$FD,Mixer.INFO(a4)		; Mute? -> only send head.
	bne.s	.size_found
	move.l	.head(pc),d0
	clr.w	.nr_loops
	clr.l	.tail
.size_found:
	move.l	d0,d5
	andi.w	#$FFFE,d5
	addq.l	#2,d5				; (bytes/2)+1 = exact amount of words to send to dsp
	lsr.l	d0				; d0.w=n-1=#words to send-1
	WritHost	d0
	tst.l	d0
	beq	.next_track
	lsr.l	d1				; Shift out lsb of sampleadr.
	bcc.s	.even				; Dsp also tests parity!
	clr.l	d1
	move.b	(a1)+,d1
	swap	d1
	WritHost	d1			; Send odd sample.
.even:	env	(a5)
	
; head..
	move.l	.head(pc),d0
	bsr	.send_block

; body..
	move.w	.nr_loops(pc),d6
	beq.s	.body_done
	move.l	Mixer.LOOPLENGTH(a4),d1
	movea.l	Mixer.LOOPSTART(a4),a2
	lsr.l	d1
	move.l	d1,d0
	mulu.w	d6,d0
	sub.l	d0,d5
	sub.l	d0,d5
	subq.w	#1,d6
	subq.w	#1,d1

.body_loop:
	move.w	d1,d0
	movea.l	a2,a1
; Send d0.w+1 words!
.slloop:move.w	(a1)+,(a3)
	dbf	d0,.slloop
	dbf	d6,.body_loop
.body_done:

; tail..
	move.l	.tail(pc),d0
	move.l	d0,d1
	lsr.l	d1
	beq.s	.tail_done
	movea.l	Mixer.LOOPSTART(a4),a1
.tail_size_calced:
	bsr	.send_block
.tail_done:

; Check for last word(s)...
	tst.l	d5
	beq.s	.next_track
	move.l	Mixer.START(a4),d6
	add.l	Mixer.LENGTH(a4),d6		; d6.l: sample_end

.rest_loop:
	move.l	Mixer.LOOPLENGTH(a4),d2
	cmpi.l	#2,d2
	ble.s	.correct_addy			; No loop? -> Don't wrap addy.
	move.l	Mixer.LOOPSTART(a4),d1
	move.l	d1,d0
	add.l	d2,d0				; d0.l: loopend
	cmp.l	a1,d0				; Looping sample exceeding loop?
	bhi.s	.correct_addy
	movea.l	d1,a1
.correct_addy:
	cmpa.l	d6,a1				; If sample exceeds end, then put some void to the dsp.
	blt.s	.in_sample
	lea	.void(pc),a1
.in_sample:
	move.w	(a1)+,(a3)
	subq.l	#2,d5
	bne.s	.rest_loop

.next_track:
	movea.l	(sp)+,a1
	adda.w	#Mixer.SIZE,a4
	dbf	d7,.voice_loop

	WritHost	#$1234			; Send terminator.
	restore_host
	rts

; This sends a loop or tail to host.
; remember, loopstart and tailstart are even and looplen>=2!
; send d0/2 words!
.send_block:
	lsr.l	d0				; d0.w=n=#words to send
	sub.l	d0,d5
	sub.l	d0,d5
	move.l	d0,d1
	beq.s	.sent
	lsr.w	#4,d0
	andi.w	#$F,d1
	neg.l	d1
	jmp	.jump(pc,d1.l*2)
	
; Send d0.w words!
.sendlloop:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
.jump:	dbf	d0,.sendlloop

.sent:	rts

.blocksize:
	ds.l	1
.head:	ds.l	1				; 
.tail:	ds.l	1
.nr_loops:
	ds.w	1
.void:	ds.l	1

;= data ====================================================================

; frequency information
table_frq:
	dc.l	$24063686,$3639d737

; mixing tables
Mixer.lrTable:
	REPT	EarxPlay.MAX_TRACKS/2
	DC.B	0,1
	ENDR

; dsp mixer
EarxPlay.mixer:
	INCBIN	RSNDEARX.P56
EarxPlay.mixerEnd:
	EVEN

;= reserves ================================================================

	bss

; player status
EarxPlay.initialized:
	ds.w	1

; module information
EarxPlay.modAdr:
	ds.l	1
EarxPlay.splAdrTable:				; addresses of samples
	ds.l	31
EarxPlay.numTracks:
	ds.w	1

; player parameters
EarxPlay.playing:
	ds.w	1
EarxPlay.position:				; current position in mod
	ds.w	1
EarxPlay.speed:					; #vbl's per note
	ds.w	1
EarxPlay.counter:				; #vbl's to go till next note
	ds.w	1
EarxPlay.breakPos:
	ds.w	1
EarxPlay.pattpos:				; current position in pattern
	ds.w	1
EarxPlay.pbreak:
	ds.w	1
EarxPlay.pattDelayTime:
	ds.w	1
EarxPlay.pattDelayTime2:
	ds.w	1

; synchronisation command info
command_buffer:
	ds.b	32
command_tail:
	ds.w	1
command_head:
	ds.w	1

; frequency information
EarxPlay.timerBase:				; #timerticks in a 'vbl'
	ds.b	1
EarxPlay.timerCount:				; #timerticks till next 'vbl'
	ds.b	1
matr_i:	ds.w	1
freq_table:
	ds.l 	80+900
EarxPlay.timerTable:
	ds.w	256

; note structures
Voice.table:
	DS.B	EarxPlay.MAX_TRACKS*Voice.SIZE

; mixing tables
Mixer.table:
	DS.B	EarxPlay.MAX_TRACKS*Mixer.SIZE	; spl offset, loop, start, vol, freq info for all tracks
Mixer.firstl:
	DS.B	1				; indicates 1st left track
Mixer.firstr:
	DS.B	1				; indicates 1st right track

; mfp context
mfp_save:
	ds.l	20
