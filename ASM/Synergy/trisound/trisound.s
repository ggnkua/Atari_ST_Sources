** Trisound Player v.1.7
** Base by B.A.T
**
** Modified by gwEm 2005:
** 	- full machine restoration
**	- SMC removal
**	- address register passing for TVS = a0, TRI = a1
**	- devpac syntax
**	- small optimisations and redundant code removal (more is possible)

;................................................................
TEST_BUILD	EQU 0

		section	text
;................................................................
; test player by gwEm
		IFNE	TEST_BUILD
test_player:	clr.l	-(sp)			; supervisor mode
		move.w	#$20,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;
		move.l	d0,oldusp		; store old user stack pointer

		move.l	$114.w,oldtc		; store old timer C vector

		lea	voice_set(pc),a0
		move.l	a0,a1
		add.l	#song-voice_set,a1
		bsr	MUSIC			; init music

		move.l	#timerc,$114.w		; steal timer C

		move.w	#7,-(sp)		; wait for a key
		trap	#1			;
		addq.l	#2,sp			;

		move.l	oldtc,$114.w		; restore timer c

		bsr	MUSIC+8			; de-init music

		move.l	oldusp(pc),-(sp)	; user mode
		move.w	#$20,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;

		clr.w   -(sp)                   ; pterm()
		move.w	#$4c,-(sp)		;
		trap    #1      		;

timerc:		move.w	sr,-(sp)		; store status register
		move.w  #$2500,sr		; enable interrupts except vbl (allows timer effects)
		sub.w	#50,fiftycount		; 50Hz replay
		bne.s	.noplay
		move.w	#200,fiftycount
		bsr 	MUSIC+4			; call music
.noplay		move.w	(sp)+,sr		; restore status register
	        move.l  oldtc(pc),-(sp)		; go to old vector (system friendly ;) )
	        rts

oldtc:		ds.l	1
oldusp:		ds.l	1
fiftycount:	dc.w	200
		ENDC

		IFEQ	TEST_BUILD
		dc.b	"TRIM"
		ENDC
;..........................................................................


		opt	CHKPC
************************** START OF MUSIC *******************
MUSIC:
init_mus:	bra     init_music		;+0
play_mus:	bra     do_play			;+4
exit_mus:	bra     deinit_music		;+8		;gwEm 2005
************************* INIT SOUND ********************
max_pat         EQU 32

i_noise_freq    EQU 0
i_sound_mode    EQU 2
i_env_type      EQU 3
i_env_freq      EQU 4
i_vibr_speed    EQU 6
i_vibr_depth    EQU 8
i_env_attack    EQU 10
i_env_sustain   EQU 12
i_env_release   EQU 14
i_env_start     EQU 16
i_pit_len       EQU 112
i_env_len       EQU 112
i_pit_start     EQU 128
i_pit_attack    EQU 240
i_pit_sustain   EQU 242
i_pit_release   EQU 244
i_interval1     EQU 252
i_interval2     EQU 254
i_total_len     EQU 256


init_music:	movem.l	d0-a6,-(sp)		;gwEm 2005
		lea	tvs_point(pc),a2	;
		move.l	a0,(a2)+		;TVS point
		move.l	a0,a5			;
		move.l	a1,(a2)			;TRI point
		move.l	a1,a6			;

		bsr     play3v
                lea     pat_lin(pc),A3
                clr.w   (A3)
                bsr     calc_pos
                bsr     calc_sam_ptrs

.init_digi:	move    SR,-(SP)
                move    #$2700,SR       	;zet INTs uit

		lea	mfp_restore(pc),a0	;gwEm 2005
                lea     intnorm(PC),A3

                bclr    #5,$FFFFFA07.w  	;timer A disable	gwEm 2005
		sne	(a0)+

		move.b	$FFFFFA19.w,(a0)+	;gwEm 2005
                move.b  #1,$FFFFFA19.w  	;timer A divider = /4

                bset    #5,$FFFFFA13.w  	;timer A mask		gwEm 2005
		sne	(a0)+

		bclr	#3,$FFFFFA17.w		;automatic interrupts	gwEm 2005
		sne	(a0)+

		move.l	$134.w,(a0)+		;gwEm 2005
                move.l  A3,$134.w 	     	;set timer A vector

		move.l	$60.w,(a0)+		;gwEm 2005
		lea	dummyrte(pc),a0		;set spurious interrupt vector to dummy routine gwEm 2005
		move.l	a0,$60.w		;

                bsr	snd_init        	;initialiseer PSG

		;rte				;gwEm 2005
		move.w	(sp)+,sr		;
		movem.l	(sp)+,d0-a6		;
                rts


***** SOUND PLAY INIT ROUTINE *****

play3v:         move.w  #1,last_pat(a6)         ;aantal patterns is eerst 1 		gwEm 2005

                move.w  #max_pat-1,D0   	;haal aantal patterns-1 (voor dbra lus)
                lea     patterns(a6),A0 	;begin adres patterns	gwEm 2005
                lea     pat_tab(PC),A1  	;begin adres pattern tabel
.init_pat_tab:	move.l  A0,(A1)+        	;sla adres pattern op
                adda.l  #64*12,A0       	;naar volgende pattern
                dbra    D0,.init_pat_tab 	;net zo lang tot alle pattern geweest zijn

                lea     note_count(PC),A3
                move.w  #1,(A3)         	;begin meteen met noot
                lea     pos_now(PC),A3
                clr.w   (A3)            	;begin bij position #0
                lea     pat_base(PC),A3
                move.l  patterns(a6),6(A3)      ;pointer IN pattern goed zetten		gwEm 2005
                move.l  patterns(a6),(A3)       ;pointer NAAR pattern goed zetten	gwEm 2005

***** INITIALISEER VOICE STATUS STRUCTURE ******

                lea     adata+sound_mode(PC),A3
                clr.b   (A3)
                lea     env_0(PC),A4
                lea     adata+env_ptr(PC),A3
                move.l  A4,(A3)
                move.w  #2,6(A3)
                move.w  #5,8(A3)
                move.w  #9,10(A3)
                lea     adata+pit_ptr(PC),A3
                move.l  A4,(A3)
                move.w  #2,6(A3)
                move.w  #5,8(A3)
                move.w  #9,10(A3)

                lea     bdata+sound_mode(PC),A3
                clr.b   (A3)
                lea     bdata+env_ptr(PC),A3
                move.l  A4,(A3)
                move.w  #2,6(A3)
                move.w  #5,8(A3)
                move.w  #9,10(A3)
                lea     bdata+pit_ptr(PC),A3
                move.l  A4,(A3)
                move.w  #2,6(A3)
                move.w  #5,8(A3)
                move.w  #9,10(A3)

                lea     cdata+sound_mode(PC),A3
                clr.b   (A3)
                lea     cdata+env_ptr(PC),A3
                move.l  A4,(A3)
                move.w  #2,6(A3)
                move.w  #5,8(A3)
                move.w  #9,10(A3)
                lea     cdata+pit_ptr(PC),A3
                move.l  A4,(A3)
                move.w  #2,6(A3)
                move.w  #5,8(A3)
                move.w  #9,10(A3)

                rts


snd_init:	movem.l	d0-a6,-(sp)		;gwEm 2005
		move    SR,-(SP)
                move    #$2700,SR
                bclr    #5,$FFFFFA07.w  	;zt timer A voor kanaal A stil
                lea     adata+silent(PC),A3
                bset    #0,(A3)         	;zet kanalen uit
                bclr    #1,(A3)         	;geen sample op kanaal A
                lea     bdata+silent(PC),A3
                bset    #0,(A3)
                lea     cdata+silent(PC),A3
                bset    #0,(A3)
                lea     adata+instr_no(PC),A3
                st      (A3)            	;maak instrumenten nummer $ff zodat bij vergelijking instrument data opnieuw geladen wordt
                lea     bdata+instr_no(PC),A3
                st      (A3)
                lea     cdata+instr_no(PC),A3
                st      (A3)

		bsr	reset_ym		;gwEm 2005

                lea     sampoint(PC),A0		;gwEm 2005 - relocate digi drum routine
                lea     add_label+2(PC),A1	;
                move.l  A0,(A1)			;
                lea     next_label+4(PC),A0
                lea     adata+silent(PC),A1
                move.l  A1,(A0)

		;rte				;gwEm 2005
		move.w	(sp)+,sr		;
		movem.l	(sp)+,d0-a6		;
                rts				;

;..........................................................................

deinit_music	movem.l	d0-a6,-(sp)		;new routine by gwEm 2005
		move    sr,-(sp)
                move    #$2700,sr

		lea	mfp_restore(pc),a0
		
		tst.b	(a0)+
		beq.s	.clrtimerAena
		bset	#5,$FFFFFA07.w		;timer A enable
		bra.s	.timerAdiv
.clrtimerAena	bclr    #5,$FFFFFA07.w  	;timer A disable

.timerAdiv	move.b	(a0)+,$FFFFFA19.w	;timer A divider

		tst.b	(a0)+
		beq.s	.clrtimerAmask
                bset	#5,$FFFFFA13.w  	;timer A mask
		bra.s	.mfpvectorreg
.clrtimerAmask	bclr	#5,$FFFFFA13.w

.mfpvectorreg	tst.b	(a0)+
		beq.s	.clrvr
		bset	#3,$FFFFFA17.w
		bra.s	.vectors
.clrvr		bclr	#3,$FFFFFA17.w		;automatic interrupts

.vectors	move.l	(a0)+,$134.w		;gwEm 2005
		move.l	(a0)+,$60.w

		bsr	reset_ym
		move.w	(sp)+,sr
		movem.l	(sp)+,d0-a6
		rts


reset_ym:       lea     $FFFF8800.w,A0		;routine moved by gwEm 2005
                lea     .data(PC),A1
		moveq   #13-1,D1
.loop:		move.w  (A1)+,D0
                move.l 	D0,0(A0)		;movep removed - gwEm 2005
                dbra    D1,.loop
                move.b  #7,(A0)
                move.b  (A0),D0         	;haal waarde reg #7
                andi.b  #%11000000,D0   	;laat A/B I/O staan
                or.b    #%00111111,D0     	;zet alles verder uit
                move.b  D0,2(A0)        	;sla reg #7 op	
		rts
.data:		dc.l	$00000000
		dc.l	$01000000
		dc.l	$02000000
		dc.l	$03000000
		dc.l	$04000000
		dc.l	$05000000
		dc.l	$06000000
		dc.l	$08000000
		dc.l	$09000000
		dc.l	$0A000000
		dc.l	$0B000000
		dc.l	$0C000000
		dc.l	$0D000000

mfp_restore:	ds.l	1
		ds.b	4
		ds.l	1

;..........................................................................

do_play:	movem.l	d0-a6,-(sp)		;gwEm 2005
		move.w	sr,-(sp)		;
		move.l	tvs_point(pc),a5	;A5 points to TVS
		move.l	tri_point(pc),a6	;A6 points to TRI

	        lea     note_count(PC),A3
                subq.w  #1,(A3)         	;moet er een nieuwe noot gepakt worden?
                bne     .do_fx_all       	;als niet zo -> spring over noot routine heen
                move.w  speed(a6),(A3)       	;herstel voordeler		gwEm 2005
                lea     pat_base(PC),A3
                movea.l (A3),A1         	;haal pointer naar begin van pattern
                move.w  4(A3),D0        	;haal  regel#
                move.w  D0,D1
                lsl.w   #3,D0
                add.w   D1,D1
                add.w   D1,D1
                add.w   D1,D0           	;vermenigvuldig met lengte 1 noot
                adda.w  D0,A1           	;en tel op bij pointer in pattern
                lea     pat_lin(PC),A3
                move.l  A1,2(A3)        	;sla pointer op voor later
                addq.w  #1,(A3)         	;naar volgende regel
                cmpi.w  #64,(A3)        	;zijn we al bij het einde?
                bne.s   .no_re_pat       	;als we het einde nog niet bereikt hebben -> ga door
                bsr     load_pos        	;haal nieuwe positie

.no_re_pat:	lea     adata(PC),A0    	;haal adres channel A data-field
                bsr     getnote         	;lees noot
                lea     bdata(PC),A0    	;haal adres channel B data-field
                bsr     getnote         	;lees noot
                lea     cdata(PC),A0    	;haal adres channel C data-field
                bsr     getnote         	;lees noot
                lea     adata+sound_mode(PC),A3
                lea     bdata+sound_mode(PC),A4
                move.b  #%11111111,D0   	;standaard masker voor REG #7
                btst    #0,sound_mode(A0) 	;toon op kanaal C?
                beq.s   .no_tone_c      	;nee -> niks doen
                and.b   #%11111011,D0   	;ja -> wis bijhorende bit
.no_tone_c:	btst    #1,sound_mode(A0) 	;ruis op kanaal C?
                beq.s   .no_nois_c       	;nee -> niks doen
                and.b   #%11011111,D0   	;ja -> wis bijhorende bit
.no_nois_c:	btst    #0,(A4)         	;toon op kanaal B?
                beq.s   .no_tone_b       	;nee -> niks doen
                and.b   #%11111101,D0   	;ja -> wis bijhorende bit
.no_tone_b:	btst    #1,(A4)         	;ruis op kanaal B?
                beq.s   .no_nois_b       	;nee -> niks doen
                and.b   #%11101111,D0   	;ja -> wis bijheorende bit
.no_nois_b:	btst    #1,14(A3)       	;wordt er een sample gespeeld?
                bne.s   .no_nois_a       	;ja -> geen toon en geen ruis op kanaal A
                btst    #0,(A3)         	;toon op kanaal A?
                beq.s   .no_tone_a       	;nee -> niks doen
                and.b   #%11111110,D0   	;ja -> wis bijhorende bit
.no_tone_a:	btst    #1,(A3)         	;ruis op kanaal A?
                beq.s   .no_nois_a       	;nee -> niks doen
                and.b   #%11110111,D0   	;ja -> wis bijheorende bit
.no_nois_a:     move.w	#$2700,SR       	;MFP interrupts off	
		move.b	#7,$FFFF8800.w		;register 7 		gwEm 2005
                move.b  D0,$FFFF8802.w		;			gwEm 2005
     		move.w	#$2300,SR       	;MFP interrupts on


.do_fx_all:	lea     cdata(PC),A0    	;haal adres channel C data-field
                bsr     do_fx           	;doe envelope, tremolo etc.
                lea     bdata(PC),A0    	;haal adres channel B data-field
                bsr     do_fx           	;doe envelope, tremolo etc.
                lea     adata(PC),A0    	;haal adres channel A data-field
                bsr     do_fx           	;doe envelope, tremolo etc.
                lea     $FFFF8800.w,A1  	;adres PSG register select
                lea     $FFFF8802.w,A2  	;adres PSG write data

                move.w	#$2700,SR       	;MFP interrupts off
                btst    #1,silent(A0)   	;wordt er een sample gespeeld?
                bne.s   .do_nout_a       	;ja -> doe niks met kanaal A registers
                clr.b   (A1)            	;tone freq register
                move.b  psgfreq+1(A0),(A2) 	;haal frequency, schrijf lobyte freq
                move.b  #1,(A1)
                move.b  psgfreq(A0),(A2) 	;haal en schrijf frequency hi-byte,
                tst.b   silent(A0)      	;staat dit kanaal aan?
                bne.s   .no_hrdw_auto_a 	;nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
                btst    #2,sound_mode(A0) 	;taat er uberhaupt hardware op dit kanaal?
                beq.s   .no_hrdw_auto_a
                btst    #3,sound_mode(A0) 	;staat hardware frequency op auto?
                beq.s   .no_hrdw_auto_a
                move.w  psgfreq(A0),D0
                lsr.w   #4,D0           	;deel frequency door 16, voor hardware frequency
                move.b  #11,(A1)        	;hardware frequency register
                move.b  D0,(A2)         	;schrijf lo-byte frequency
                move.l  #$0C000000,(A1) 	;hi-byte frequency = 0
.no_hrdw_auto_a:move.b  #8,(A1)         	;volume kanaal A
                move.b  psgvol(A0),(A2)

.do_nout_a:	lea     bdata(PC),A0    	;adres variabelen gebied kanaal B
                move.b  #2,(A1)         	;tone freq register
                move.b  psgfreq+1(A0),(A2) 	;haal en schrijf frequency lo-byte
                move.b  #3,(A1)
                move.b  psgfreq(A0),(A2) 	;haal en schrijf frequency hi-byte
                tst.b   silent(A0)      	;staat dit kanaal aan?
                bne.s   .no_hrdw_auto_b 	;nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
                btst    #2,sound_mode(A0) 	;staat er uberhaupt hardware op dit kanaal?
                beq.s   .no_hrdw_auto_b
                btst    #3,sound_mode(A0) 	;staat hardware frequency op auto?
                beq.s   .no_hrdw_auto_b
                move.w  psgfreq(A0),D0
                lsr.w   #4,D0           	;deel frequency door 16, voor hardware frequency
                move.b  #11,(A1)        	;hardware frequency register
                move.b  D0,(A2)         	;schrijf lo-byte frequency
                move.l  #$0C000000,(A1)	 	;hi-byte frequency = 0
.no_hrdw_auto_b:move.b  #9,(A1)         	;volume kanaal B
                move.b  psgvol(A0),(A2)

                lea     cdata(PC),A0    	;adres variabelen gebied kanaal C
                move.b  #4,(A1)         	;tone freq register
                move.b  psgfreq+1(A0),(A2) 	;haal en schrijf frequency lo-byte
                move.b  #5,(A1)
                move.b  psgfreq(A0),(A2) 	;haal en schrijf frequency hi-byte
                tst.b   silent(A0)      	;staat dit kanaal aan?
                bne.s   .no_hrdw_auto_c		;nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
                btst    #2,sound_mode(A0) 	;staat er uberhaupt hardware op dit kanaal?
                beq.s   .no_hrdw_auto_c
                btst    #3,sound_mode(A0) 	;staat hardware frequency op auto?
                beq.s   .no_hrdw_auto_c
                move.w  psgfreq(A0),D0
                lsr.w   #4,D0           	;deel frequency door 16, voor hardware frequency
                move.b  #11,(A1)        	;hardware frequency register
                move.b  D0,(A2)         	;schrijf lo-byte frequency
                move.l  #$0C000000,(A1) 	;hi-byte frequency = 0
.no_hrdw_auto_c:move.b  #10,(A1)        	;volume kanaal C
                move.b  psgvol(A0),(A2)

                move.w	(sp)+,SR  	     	;MFP interrupts weer aan - gwEm 2005
		movem.l	(sp)+,d0-a6
                rts                     	;kom TERUG van routine

;.................

do_fx:          tst.b   silent(A0)      	;kijk of dit kanaal stil moet zijn
                bne     .do_silent       	;ja -> clear PSG volume
                btst    #2,sound_mode(A0) 	;kijk of hardware envelope aan staat
                beq.s   .no_he           	;nee -> doe niks
                move.b  #$10,psgvol(A0) 	;zet volume op hardware envelope
                bra.s   .to_tie          	;spring over rest heen

.no_he:		move.w  env_offs(A0),D0 	;haal envelope offset
                movea.l env_ptr(A0),A2  	;haal pointer naar envelope
                move.b  0(A2,D0.w),D1   	;haal lokaal volume
                move.b  g_vol(A0),D2    	;haal globaal volume
                asl.b   #4,D2           	;vermenigvuldig met 16 voor offset naar goede tabel
                add.b   D1,D2           	;tel lokaal volume bij globaal volume
                andi.w  #$FF,D2         	;maak word van volume
                lea     vols(PC),A2     	;haal adres volume tabellen
                move.b  0(A2,D2.w),psgvol(A0) 	;bereken volume dat uiteindelijk in PSG moet
                addq.w  #1,D0           	;verhoog offset
                cmp.w   env_sus(A0),D0  	;zijn we aan het begin van de release?
                bne.s   .no_sus_rep		;nee -> niet sustain herhalen
                move.w  env_att(A0),D0  	;ja -> zet offset weer op sustain
.no_sus_rep:	cmp.w   env_rel(A0),D0  	;zijn we al (voor)bij het einde?
                blo.s   .no_rel			;nee -> volume niet 0 maken
                bset    #0,silent(A0)   	;zet silent bit van dit kanaal zodat dit kanaal zodirekt stil is
.no_rel:	move.w  D0,env_offs(A0) 	;sla offset op
.to_tie:	move.w  tie_stp(A0),D0  	;haal stap voor tie
                beq.s   .no_tie          	;als tie=0 -> geen tie
                bmi.s   .tie_lo          	;bij negatieve stap is target lager dan huidige freq
                add.w   p_freq(A0),D0   	;verhoog frequentie met stap
                cmp.w   g_freq(A0),D0   	;is de frequentie op goede hoogte?
                blt.s   .noreach_tie_hi 	;als werkelijke frequentie lager is dan echte, zijn we er nog niet
                clr.w   tie_stp(A0)     	;wis tie stap
                move.w  g_freq(A0),D0   	;haal echte frequentie -> soms wijkt de gemaakte af door scheve offsets
.noreach_tie_hi:move.w  D0,p_freq(A0)   	;zet frequentie weg
                bra.s   .no_tie			;sla tie lo over
.tie_lo:	add.w   p_freq(A0),D0   	;verlaag frequentie met stap
                cmp.w   g_freq(A0),D0   	;is de frequentie op goede hoogte?
                bgt.s   .noreach_tie_lo 	;als werkelijke frequentie hoger is dan echte, zijn we er nog niet
                clr.w   tie_stp(A0)     	;wis tie stap
                move.w  g_freq(A0),D0   	;haal echte frequentie -> soms wijkt de gemaakte af door scheve offsets
.noreach_tie_lo:move.w  D0,p_freq(A0)   	;sla frequentie op
.no_tie:	move.w  trem_offs(A0),D1 	;haal offset daarin
                add.w   vibr_speed(A0),D1 	;verhoog offset in tremolo tabel
                cmpi.w  #59,D1          	;zijn we al voorbij het einde
                bls.s   .no_re_trem      	;nee -> ga door
                moveq   #0,D1           	;begin opnieuw aan tabel
.no_re_trem:	move.w  D1,trem_offs(A0) 	;sla offset weer op
                add.w   D1,D1           	;vermenig vuldig met 2 voor word tabel
                lea     trem_tab(PC),A2 	;haal pointer naar tremolo tabel
                move.w  0(A2,D1.w),D1   	;pak variatie van frequentie
                move.w  vibr_depth(A0),D2 	;haal diepte van tremolo
                asr.w   D2,D1           	;maak goede diepte tremolo aan
                add.w   p_freq(A0),D1   	;tel echte frequentie bij variatie op
                move.b  int_now(A0),D0  	;bij welke interval zijn we nu?
                beq.s   .intr_0          	;0=normale frequentie
                cmpi.b  #1,D0           	;1=interval #1
                beq.s   .intr_1
                add.w   int_freq2(A0),D1 	;tel interval #2 bij huidige frequentie
                clr.b   int_now(A0)     	;volgende keer 0
                bra.s   .intr_2
.intr_1:	add.w   int_freq1(A0),D1 	;tel interval #1 bij huidige frequentie
.intr_0:	addq.b  #1,int_now(A0)  	;verhoog interval count
.intr_2:                                 	; laat frequentie in d1
                tst.b   pit_mode(A0)    	;staat pitch aan (vergelijkbaar met silent bit#0 voor amplitude envelope)
                beq.s   .no_pitch        	; pitch uit -> tel er geen frequentie bij op
                move.w  pit_offs(A0),D0 	;haal pitch envelope offset
                movea.l pit_ptr(A0),A2  	;haal pointer naar envelope
                move.b  0(A2,D0.w),D2   	;haal relatieve frequentie
                ext.w   D2              	;sign-extend byte tot word
                add.w   D2,D1           	;tel relatieve frequentie bij huidige frequentie
                addq.w  #1,D0           	;verhoog offset
                cmp.w   pit_sus(A0),D0  	;zij we aan het begin van de release?
                bne.s   .no_pit_sus_rep  	;nee -> niet sustain herhalen
                move.w  pit_att(A0),D0  	;ja -> zet offset weer op sustain
.no_pit_sus_rep:cmp.w   pit_rel(A0),D0  	;zijn we al (voor)bij het einde?
                blo.s   .no_pit_rel      	;nee -> volume niet 0 maken
                clr.b   pit_mode(A0)    	;pitch afgelopen -> zet pitch afhandeling uit
.no_pit_rel:	move.w  D0,pit_offs(A0) 	;sla offset op
.no_pitch:	move.w  D1,psgfreq(A0)  	;sla frequentie op
                rts

.do_silent:	clr.b   psgvol(A0)      	;wis PSG volume
                rts

;.................

getnote:        tst.b   (A1)            		;bekijk noot/octaaf
                beq     .test_env        		;als octaaf/noot = 0 -> geen verandering, maar bekijk envelope
                bmi     .sam_note        		;als octaaf/noot < 0 -> lees sample
                move.b  2(A1),D1        		;haal instrument nummer
                cmp.b   instr_no(A0),D1 		;hebben we dit instrument al?
                beq     .same_instr      		;ja -> ga door
                cmp.b   #$3F,D1         		;vergelijk YMS# met maximum ($3f=63)
                bhi     .same_instr      		;als d0>maximum -> verkeerd nummer en negeer dit instrument dus
                move.b  D1,instr_no(A0) 		;sla instrument nummer op voor vergelijking
                andi.w  #$3F,D1         		;maak word van YM sound
                lea     ym_sounds(a5),A2 		;haal adres begin YM sounds 		gwEm 2005
                asl.w   #8,D1           		;maal 256(=lengte 1 ym sound)
                adda.w  D1,A2           		;tel die offset op bij start adres
                move.w  i_noise_freq(A2),D0 		;haal frequentie ruis
                move.w  D0,noise_freq(A0) 		;sla op
                btst    #1,i_sound_mode(A2) 		;heeft dit instrument noise aan?
                beq.s   .no_instr_noise  		;nee -> zet frequentie dan niet in PSG
                move    #$2700,SR       		;disable MFP interrupts
                move.b  #6,$FFFF8800.w  		;register #6 : noise freq
                move.b  D0,$FFFF8802.w
                move    #$2300,SR       		;re-enable MFP interrupts
.no_instr_noise:move.b  i_sound_mode(A2),sound_mode(A0) ;haal sound mode
                move.w  i_env_freq(A2),h_env_freq(A0) 	;haal frequentie hardware envelope
                move.b  i_env_type(A2),h_env_type(A0) 	;haal type hardware envelope
                move.w  i_vibr_speed(A2),vibr_speed(A0) ;haal snelheid van vibrato
                move.w  i_vibr_depth(A2),vibr_depth(A0) ;haal diepte van vibrato
                move.w  i_interval1(A2),interval1(A0) 	;haal interval #1
                move.w  i_interval2(A2),interval2(A0) 	;haal interval #2
                clr.w   env_offs(A0)    		;clear envelope offset
                move.w  i_env_attack(A2),env_att(A0) 	;haal attack einde
                move.w  i_env_sustain(A2),env_sus(A0) 	;haal sustain einde
                move.w  i_env_release(A2),env_rel(A0) 	;haal release einde
                lea     i_env_start(A2),A3 		;haal start envelope tabel
                move.l  A3,env_ptr(A0)
                clr.w   pit_offs(A0)    		;clear pitch envelope offset
                move.w  i_pit_attack(A2),pit_att(A0) 	;haal pitch attack einde
                move.w  i_pit_sustain(A2),pit_sus(A0) 	;haal pitch sustain einde
                move.w  i_pit_release(A2),pit_rel(A0) 	;haal pitch release einde
                lea     i_pit_start(A2),A3 		;haal start pitch envelope tabel
                move.l  A3,pit_ptr(A0)
                st      pit_mode(A0)    		;zet pitch aan
.same_instr:	moveq   #0,D0           		;maak d0 leeg zodat we het zodirekt als word kunnen behandelen
                move.b  (A1),D0         		;haal octaaf(0-7) & noot (0-24 in stappen van 2)
                move.w  D0,D1           		;maak backup van octaaf
                lsr.w   #4,D1           		;haal octaaf# naar goede plaats
                lea     note_2_freq(PC),A2 		;haal pointer naar noot->freq omreken tabel
                andi.w  #$0F,D0         		;maskeer noot
                move.w  D0,D2           		;bewaar noot en gebruik d2
                add.w   D2,D2           		; maal 2 voor offset in word tabel
                move.w  0(A2,D2.w),D2   		;haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
                lsr.w   D1,D2           		;verdubbel frequentie zovaak als octaaf nummer-1
                move.w  D2,g_freq(A0)   		;sla verkregen frequentie op
                move.w  D0,D3           		;bewaar noot en gebruik d3
                add.w   interval1(A0),D3 		;tel interval bij noot# op
                add.w   D3,D3           		;maal 2 voor offst in word tabel
                move.w  0(A2,D3.w),D3   		;haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
                lsr.w   D1,D3           		;verdubbel frequentie zovaak als octaaf nummer-1
                sub.w   D2,D3           		;haal van nieuwe frequentie oorspronkelijke frequentie af, voor relative frequentie
                move.w  D3,int_freq1(A0) 		;sla interval frequency op
                add.w   interval2(A0),D0 		;tel interval bij noot# op
                add.w   D0,D0           		;maal 2 voor offset in word tabel
                move.w  0(A2,D0.w),D0   		;haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
                lsr.w   D1,D0           		;verdubbel frequentie zovaak als octaaf nummer-1
                sub.w   D2,D0           		;haal van nieuwe frequentie oorspronkelijke frequentie af, voor relative frequentie
                move.w  D0,int_freq2(A0) 		;sla interval frequency op
                move.b  1(A1),D1        		;haal tie waarde
                beq.s   .no_calc_tie			;als tie value=0 dan is er geen tie
.calc_tie:                               		;in d2 zit huidige frequentie nog
                sub.w   p_freq(A0),D2   		;trek huidige frequentie van target freq af voor step
                ext.l   D2              		;maak long van step voor delen
                andi.l  #$FF,D1         		;maak long van aantal te 'tie'en noten
                muls    speed(a6),D1    		;vermenigvuldig " met speed	gwEm 2005
                divs    D1,D2           		;deel d2 door snelheid*noten voor tie stap
                beq.s   .no_calc_tie     		; als tie stap=0 zet freq meteen goed
                move.w  D2,tie_stp(A0)  		;sla tie stap op
                bra.s   .yes_calc_tie
.no_calc_tie:	move.w  g_freq(A0),p_freq(A0) 		;zet globale frequentie meteen als huidige frequentie
                clr.w   tie_stp(A0)     		;clear tie stap
.yes_calc_tie:	move.b  3(A1),D0        		;haal envelope/volume
                andi.w  #$1F,D0         		;maskeer volume en verwijder envelope en maak er tegelikertijd een word van
                move.b  D0,g_vol(A0)    		;sla volume op
.test_env:	addq.l  #3,A1
                move.b  (A1)+,D1        		;haal envelope value(& volume)
                lsr.b   #6,D1           		;verschuif hem naar de onderste bits en verwijder volume
                tst.b   D1              		*******
                beq.s   .same_env        		;als envelope value=0 (NO_CHANGE), dan niks veranderen
                btst    #2,sound_mode(A0) 		;wordt hardware envelope op dit kanaal gespeeld?
                bne.s   .he_adsr         		;ja -> voer dat soort envelope uit
                cmpi.b  #1,D1           		;is envelope value dan 1?
                beq.s   .attack_env      		;ja -> doe attack deel van envelope
                cmpi.b  #2,D1           		;is envelope value dan 2?
                beq.s   .sustain_env     		;ja -> begin envelope bij sustain
	                               			;dan maar release doen :
                move.w  env_sus(A0),env_offs(A0)	;zet offset op begin release
                move.w  pit_sus(A0),pit_offs(A0)	;zzet pitch offset op begin release
                bclr    #0,silent(A0)   		;clear silent bit
                st      pit_mode(A0)    		;zet pitch aan
.same_env	rts                     		;gwEm 2005

.sustain_env:	move.w  env_att(A0),env_offs(A0)	;zet offset op begin sustain
                move.w  pit_att(A0),pit_offs(A0)	;zet pitch offset op begin sustain
                bclr    #0,silent(A0)   		;clear silent bit
                st      pit_mode(A0)    		;zet pitch aan
                rts

.attack_env:	clr.w   env_offs(A0)    	;doe attack deel van envelope -> zet offset op 0
                clr.w   pit_offs(A0)    	;zet pitch envelope goed
                clr.w   trem_offs(A0)   	;zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
                bclr    #0,silent(A0)   	;clear silent bit
                st      pit_mode(A0)    	;zet pitch aan
                move    #$2700,SR       	;interrupts uit
                bclr    #1,silent(A0)   	;clear sample bit
                beq.s   .dont_stop_sam   	;als er geen sample op dit kanaal gespeeld werd -> doe niks
                bclr    #5,$FFFFFA07.w  	;wel sample hier -> zet timer A uit
.dont_stop_sam:	move    #$2300,SR       	;interrupts weer aan
		rts                     	;kom terug van subroutine

.he_adsr:	tst.b   D1              		;is envelope value dan 0?
                beq.s   .cont_he         		;ja -> laat envelope als hij is
                cmpi.b  #2,D1           		;is envelope value dan 2?
                beq.s   .sustain_he      		;ja -> begin envelope bij sustain
                cmpi.b  #3,D1           		;is envelope value dan 3?
                beq     .release_he      		;ja -> begin envelope bij release
                move    #$2700,SR       		;geen oderbreking graag
                btst    #3,sound_mode(A0) 		;staat hardware automatic frequency aan?
                bne.s   .attack_hardw_auto 		;ja -> zet frequency niet; dat doet PSGfreq later
                move.b  #11,$FFFF8800.w 		;hardware envelope frequency
                move.b  h_env_freq+1(A0),$FFFF8802.w
                move.b  #12,$FFFF8800.w 		;...
                move.b  h_env_freq(A0),$FFFF8802.w
.attack_hardw_auto:move.b #13,$FFFF8800.w 		;selecteer hardware envelope type register
                btst    #0,h_env_type(A0) 		;is dit een enkelvoudige envelope(niet continious)
                bne.s   .yes_hardw_type  		;ja -> zet hardware type in PSG om weer aan het begin te beginnen
                move.b  $FFFF8800.w,D0  		;nee -> zet hardware frequentie alleen neer als die er niet al staat -> zet hardware freq zo min mogelijk in PSG, om kraken tegen te gaan
                cmp.b   h_env_type(A0),D0 		;staat goede hardware type al in PSG?
                beq.s   .no_hardw_type   		;ja -> laat het maar
.yes_hardw_type:move.b  h_env_type(A0),$FFFF8802.w 	;zet hardware envelope type in PSG
.no_hardw_type:	clr.w   trem_offs(A0)   		;zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
                clr.w   pit_offs(A0)    		;zet pitch offset op begin attack
                st      pit_mode(A0)    		;zet pitch envelope an
                bclr    #0,silent(A0)   		;clear silent bit
                bclr    #1,silent(A0)   		;clear sample bit
                beq.s   .same_he         		;als er geen sample op dit kanaal gespeeld werd -> doe niks
                bclr    #5,$FFFFFA07.w  		;wel sample hier -> zet timer A uit
.same_he:	move    #$2300,SR
.cont_he:	rts

.sustain_he:	move    #$2700,SR       		;geen oderbreking graag
                btst    #3,sound_mode(A0) 		;staat hardware automatic frequency aan?
                bne.s   .sustain_hardw_auto 		;ja -> zet frequency niet; dat doet PSGfreq later
                move.b  #11,$FFFF8800.w 		;hardware envelope frequency
                move.b  h_env_freq+1(A0),$FFFF8802.w
                move.b  #12,$FFFF8800.w 		;...
                move.b  h_env_freq(A0),$FFFF8802.w
.sustain_hardw_auto:move.b #13,$FFFF8800.w 		;selecteer hardware envelope type register
                btst    #0,h_env_type(A0) 		;is dit een enkelvoudige envelope(niet continious)
                bne.s   .yes_sus_htype   		;ja -> zet hardware type in PSG om weer aan het begin te beginnen
                move.b  $FFFF8800.w,D0  		;nee -> zet hardware frequentie alleen neer als die er niet al staat -> zet hardware freq zo min mogelijk in PSG, om kraken tegen te gaan
                cmp.b   h_env_type(A0),D0 		;staat goede hardware type al in PSG?
                beq.s   .no_sus_htype    		;ja -> laat het maar
.yes_sus_htype:	move.b  h_env_type(A0),$FFFF8802.w 	;zet hardware envelope type in PSG
.no_sus_htype:	clr.w   trem_offs(A0)   		;zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
                move.w  pit_att(A0),pit_offs(A0)	;zet pitch offset op begin sustain(=einde attack)
                st      pit_mode(A0)    		;zet pitch envelope aan
                bclr    #0,silent(A0)   		;clear silent bit
                bclr    #1,silent(A0)   		;clear sample bit
                beq.s   .same_sus_he     		;als er geen sample op dit kanaal gespeeld werd -> doe niks
                bclr    #5,$FFFFFA07.w  		;wel sample hier -> zet timer A uit
.same_sus_he:	move.w	#$2300,SR
                rts

.release_he:	bset    #0,silent(A0)   		;zet silent bit
                rts

.sam_note:	btst    #2,silent(A0)   		;moeten we muten?
                bne.s   .no_new_sam      		;als mute bit=1 -> kanaal wordt gemute
                move.b  2(A1),D0        		;haal sample nummer
                andi.w  #$0F,D0         		;neem alleen laagste nibble en maak er een word van
                lea     sam_tab(PC),A2  		;haal adres sample tabel
                add.w   D0,D0           		;
                add.w   D0,D0           		;voor offset in tabel met longs
                move    #$2700,SR       		;?  ;MFP interrupts uit
                move.l  0(A2,D0.w),D5   		;schrijf adres sample in sample adres

                ;lea     ss_start+2(PC),A4 		;gwEm 2005
                ;sub.l   A4,D5				;
                ;move.w  D5,(A4)			;
		lea     sampoint(PC),A4			;gwEm 2005
		move.l	d5,(a4)				;

                move.b  1(A1),D0        		;haal hertz
                andi.w  #$0F,D0         		;neem alleen laagste nibble en maak er een word van
                lea     hertz(PC),A2    		;start of hertz -> speed conversion table
                move.b  0(A2,D0.w),$FFFFFA1F.w 		;convert hertz into timer A data
                move.b  #%10,silent(A0) 		;zodat de REG 7 routine weet dat er een sample gespeeld wordt en toon en ruis dus uit moeten
                bset    #5,$FFFFFA07.w  		;timer A weer aan
                move    #$2300,SR       		;MFP interrupts weer aan
.no_new_sam:	addq.l  #4,A1           		;schuif pointer in pattern regel op
                rts                     		;einde


;                OPT O-
;intnorm:        move.b  #8,$FFFF8800.w  		;PSG register 8 = volume kanaal A
;ss_start:       move.b  ss_start(PC),$FFFF8802.w 	;zet volume
;                bmi.s   nextsam         		;if volume<0 -> sample finished -> clear interrupt
;add_label:      addq.w  #1,$98989898    		;ss_start+4
;                rte                     		;return from exception
;                OPT O+
;
;nextsam:        clr.b   $FFFF8802.w     		;zet volume op 0
;next_label:     move.b  #%1,$98989898   		;adata+silent
;							;er wordt geen sample gespeeld maar wees toch stil
;                bclr    #5,$FFFFFA07.w  		;zet timer A uit
;                rte                     		;return from exception


intnorm:	move.l	a0,-(sp)			;SMC/low memory access free digidrum routine by gwEm 2005
		move.b	#8,$FFFF8800.w
		move.l	sampoint(pc),a0
		move.b	(a0),$FFFF8802.w
		bmi.s	nextsam
add_label:	addq.l	#1,$98989898			;sampoint
		move.l	(sp)+,a0
		rte
nextsam:	clr.b	$FFFF8802.w
next_label:     move.b  #%1,$98989898   		;adata+silent
		bclr	#5,$FFFFFA07.w
		move.l	(sp)+,a0
dummyrte:	rte

sampoint:	ds.l	1


load_pos:       lea     pat_lin(PC),A3
                clr.w   (A3)            	;zet regelnummer op 0
                lea     pos_now(PC),A3		;load position without zero
                move.w  (A3),D0         	;haal position
                addq.w  #1,D0           	;naar volgende position
                cmp.w   last_pos(a6),D0 	;zijn we voorbij de laatste position	gwEm 2005
                bls.s   .no_restart      	;nee -> niet restarten
                move.w  restart(a6),D0  	;haal restart position			gwEm 2005
.no_restart:	move.w  D0,(A3)         	;sla position op
calc_pos:	lea     pos_tab(a6),A0 		;haal adres position tabel		gwEm 2005
                lea     pos_now(PC),A3
                move.w  (A3),D0         	;haal position nummer
                move.b  (A0,D0.w),D0   		;haal huidige pattern nummer (voor als we net aankomen met calc_pos)
                andi.w  #$7F,D0         	;maak er een word van
                lea     pat_now(PC),A3
                move.w  D0,(A3)         	;sla op
                lea     2(A3),A0        	;haal tabel met patterns
                add.w   D0,D0           	;
                add.w   D0,D0           	;vermenigvuldig met 4 voor tabel met longs
                lea     pat_base(PC),A3
                move.l  0(A0,D0.w),(A3) 	;haal pointer naar pattern
                rts

calc_sam_ptrs:  lea     sam_tab(PC),A0  	;haal adres tabel met pointers
                lea     sam_len(a5),A1  	;haal adres tabel met lengtes		gwEm 2005
                lea     sam_first(a5),A2 	;haal begin adres eerste sample		gwEm 2005
                moveq   #15,D0          	;pointers van 16 samples berekenen
                moveq   #0,D1           	;lengte alle samples samen is eerst 0
.calc_next_sam:	move.l  A2,(A0)+        	;sla pointer naar sample op
                adda.l  (A1),A2         	;verhoog pointer met lengte sample
                add.l   (A1)+,D1        	;verhoog totale lengte met lengte sample
                dbra    D0,.calc_next_sam
                lea     sam_tot(PC),A0
                move.l  D1,(A0)         	;sla totale lengte samples op
                rts

;...............................................................................

vols:           DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
                DC.B 0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2
                DC.B 0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3
                DC.B 0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4
                DC.B 0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5
                DC.B 0,0,1,1,2,2,2,3,3,4,4,4,5,5,6,6
                DC.B 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
                DC.B 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
                DC.B 0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9
                DC.B 0,1,1,2,3,3,4,5,5,6,7,7,8,8,9,10
                DC.B 0,1,1,2,3,4,4,5,6,7,7,8,9,10,10,11
                DC.B 0,1,2,2,3,4,5,6,6,7,8,9,10,10,11,12
                DC.B 0,1,2,3,3,4,5,6,7,8,9,10,10,11,12,13
                DC.B 0,1,2,3,4,5,6,7,7,8,9,10,11,12,13,14
                DC.B 0,1,2,3,4,5,6,7,8,9,$0A,$0B,$0C,$0D,$0E,$0F
                EVEN

note_2_freq:    DS.W 1         		 			;lege ruimte want als noot=0 -> geen verandering
                DC.W 3822,3607,3405,3214,3033,2863
                DC.W 2702,2551,2407,2272,2145,2024
                DC.W 1991,1804,1703,1607,1517,1432
                DC.W 1351,1276,1204,1136,1073,1012

hertz:          DC.B 110,110,110,110
                DC.B 110,110,94,82
                DC.B 73,66,60,55
                DC.B 51,47,44,41

trem_tab:       DC.W 0,428,852,1266,1666,2048,2408,2741,3044,3314
                DC.W 3547,3742,3896,4006,4074,4096,4074,4006,3896,3742
                DC.W 3547,3314,3044,2741,2408,2048,1666,1266,852,428
                DC.W 0,-428,-852,-1266,-1666,-2048,-2408,-2741,-3044,-3314
                DC.W -3547,-3742,-3896,-4006,-4074,-4096,-4074,-4006,-3896,-3742
                DC.W -3547,-3314,-3044,-2741,-2408,-2048,-1666,-1266,-852,-428


note_count:     DS.W 	1  	;voordeler voor noot-snelheid (ALTIJD beginnen met 1)
pos_now:        DS.W 	1   	;huidige POSITION
pat_now:        DS.W 	1    	;huidige PATTERN
pat_tab:        DS.L 	120  	;tabel met pointers naar patterns
pat_base:       DS.L 	1      	;pointer naar B
pat_lin:        DS.W 	1    	;;pattern regel
pat_ptr:        DS.L 	1     	;;pointer naar huidige plaats in patter(=pat_base+14*
env_0:          DS.B 	10   	;10 lege bytes als valse envelope
sam_tab:        DS.L 	32  	;pointers naar samples (laatste 16 zijn loze pointers)
sam_tot:        DS.L 	1      	;totale lengte samples
tvs_point	ds.l	1	;gwEm 2005
tri_point	ds.l	1	;gwEm 2005

bdata:
psgfreq         EQU *-bdata
                DS.W 1          ;frequentie die uiteindelijk in PSG moet
g_freq          EQU *-bdata
                DS.W 1          ;globale (noot-) frequentie (waarom long? -upper word gaat naar PSG, lower word is achter de komma)
p_freq          EQU *-bdata
                DS.W 1          ;huidige frequentie zonder tremolo(bij TIE belangrijk)
tie_stp         EQU *-bdata
                DS.W 1          ;stap van tie
trem_offs       EQU *-bdata
                DS.W 1          ;offset in tremolo tabel
vibr_speed      EQU *-bdata
                DS.W 1          ;snelheid van tremolo
vibr_depth      EQU *-bdata
                DS.W 1          ;diepte van tremolo
psgvol          EQU *-bdata
                DS.B 1          ;volume dat uiteindelijk in PSG moet
g_vol           EQU *-bdata
                DS.B 1          ;globaal volume
                EVEN
env_ptr         EQU *-bdata     ;
                DS.L 1          ;pointer naar envelope tabel
env_offs        EQU *-bdata
                DS.W 1          ;offset in die tabel
env_att         EQU *-bdata
                DS.W 1          ;offset einde attack
env_sus         EQU *-bdata
                DS.W 1          ;offset einde sustain
env_rel         EQU *-bdata
                DS.W 1          ;offset einde release
                EVEN
pit_ptr         EQU *-bdata
                DS.L 1          ;pointer naar pitch envelope tabel
pit_offs        EQU *-bdata
                DS.W 1          ;offset in pitch envelope tabel
pit_att         EQU *-bdata
                DS.W 1          ;offset einde pitch attack
pit_sus         EQU *-bdata
                DS.W 1          ;offset einde pitch sustain
pit_rel         EQU *-bdata
                DS.W 1          ;offset einde pitch release
pit_mode        EQU *-bdata
                DS.B 1          ;<>0 : pitch staat aan
                EVEN
noise_freq      EQU *-bdata
                DS.W 1          ;frequentie ruis voor PSG
sound_mode      EQU *-bdata
                DS.B 1          ;masker voor reg #7
h_env_type      EQU *-bdata
                DS.B 1          ;type hardware envelope
                EVEN
h_env_freq      EQU *-bdata
                DS.W 1          ;frequentie hardware envelope
interval1       EQU *-bdata
                DS.W 1          ;interval #1 in aantal noten
interval2       EQU *-bdata
                DS.W 1          ;interval #2 in aantal noten
int_freq1       EQU *-bdata
                DS.W 1          ;interval #1 in relatieve frequency
int_freq2       EQU *-bdata
                DS.W 1          ;interval #2 in relatieve frequency
int_now         EQU *-bdata
                DS.B 1          ;welke interval zijn we? (0=normaal, 1=interval #1, 2=interval #2)
instr_no        EQU *-bdata     ;nummer huidige instrument (om te vergelijken)
                DS.B 1
silent          EQU *-bdata     ;als byte<>0 moeten we sil zijn
                DS.B 1
v_s_s_len       EQU *-bdata     ;lengte hele tabel om zo in 1 keer voice status structure voor channel C te definieren
                EVEN
cdata:          DS.B v_s_s_len  ;zelfde tabel als boven voor kanaal C
                EVEN
adata:          DS.B v_s_s_len  ;en nog een keer voor kanaal A
                EVEN

;................................................................
		IFNE	TEST_BUILD		
voice_set:      incbin 	'insignia.tvs'
            	even
		ENDC

ym_names        EQU 	0+4 				;ym sound namen 	gwEm 2005
ym_sounds       EQU 	ym_names+64*8 			;reserveer ruimte voor ym sounds
sam_names       EQU 	ym_sounds+64*i_total_len	;sample namen
sam_len         EQU 	sam_names+16*8 			;sample lengtes (laaste 16 zijn loze lengtes)
sam_rates       EQU 	sam_len+32*4 			;sample rates
sam_first       EQU 	sam_rates+16

;.......	
		IFNE	TEST_BUILD
song:		incbin 	'axelfoly.tri'
                even
		ENDC

speed           EQU 	0+4      			;snelheid		gwEm 2005
restart         EQU 	speed+2     			;restart position
last_pos        EQU 	restart+2   			;aantal positions (max. 120)
last_pat        EQU 	last_pos+2  			;aantal patterns
pos_tab         EQU 	last_pat+2  			;positions
patterns        EQU 	pos_tab+120
pat_last        EQU 	patterns+max_pat*64*12 		;de patterns

		IFEQ	TEST_BUILD
		dc.b	"TRIM"
		ENDC
;................................................................

		end