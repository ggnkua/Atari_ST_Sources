
;********************************************
;* ----- Protracker V1.1B Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1991  *
;* Bekkeliveien 10, N-2010 STRÿMMEN, Norway *
;********************************************

; VBlank Version 2:
; Call mt_init to initialize the routine, then call mt_music on
; each vertical blank (50 Hz). To end the song and turn off all
; voices, call mt_end.

; This playroutine is not very fast, optimized or well commented,
; but all the new commands in PT1.1A should work.
; If it's not good enough, you'll have to change it yourself.
; We'll try to write a faster routine soon...

; Changes from V1.0C playroutine:
; - Vibrato depth changed to be compatible with Noisetracker 2.0.
;   You'll have to double all vib. depths on old PT modules.
; - Funk Repeat changed to Invert Loop.
; - Period set back earlier when stopping an effect.

***************************************************************************
dff096_contr:
		move.w	d0,-(sp)
		move.w	4+2(sp),d0
		btst	#15,d0					;Bits setzen?
		bne.s	ap_bits_set
		not.w	d0
		and.w	d0,dff096				;Bits lîschen
		bra.s	dff096_contr_end
ap_bits_set:
		or.w	d0,dff096				;Bits setzen
dff096_contr_end:
		move.w	(sp)+,d0
		rts
***************************************************************************
DMAWAIT       EQU 300                   ; Set this as low as possible without losing low notes.

N_NOTE        EQU 0                     ; W
N_CMD         EQU 2                     ; W
N_CMDLO       EQU 3                     ; B
N_START       EQU 4                     ; L
N_LENGTH      EQU 8                     ; W
N_LOOPSTART   EQU 10                    ; L
N_REPLEN      EQU 14                    ; W
N_PERIOD      EQU 16                    ; W
N_FINETUNE    EQU 18                    ; B
N_VOLUME      EQU 19                    ; B
N_DMABIT      EQU 20                    ; W
N_TONEPORTDIREC EQU 22                  ; B
N_TONEPORTSPEED EQU 23                  ; B
N_WANTEDPERIOD EQU 24                   ; W
N_VIBRATOCMD  EQU 26                    ; B
N_VIBRATOPOS  EQU 27                    ; B
N_TREMOLOCMD  EQU 28                    ; B
N_TREMOLOPOS  EQU 29                    ; B
N_WAVECONTROL EQU 30                    ; B
N_GLISSFUNK   EQU 31                    ; B
N_SAMPLEOFFSET EQU 32                   ; B
N_PATTPOS     EQU 33                    ; B
N_LOOPCOUNT   EQU 34                    ; B
N_FUNKOFFSET  EQU 35                    ; B
N_WAVESTART   EQU 36                    ; L
N_REALLENGTH  EQU 40                    ; W
*************************************************************************
;original coded by Aeon of AURA
;DSP-Anpassung by Chris of AURA
;a6: Modulbeginn
ap_mod_init:	
            move.l	a6,mt_songdataptr	;Moduladr. speichern
			lea		$03b6(a6),a0		;songlength-adresse
			cmpm.b 	(a0)+,(a0)+			;repeat <= songlength
			bls.s 	ap_no_buggy			;dann alles ok
			clr.b 	-1(a0)				;sonst bug entfernen

;a0: sequenzer-adresse
ap_no_buggy:
			moveq 	#$0080-1,d0			;max.128 positions
			moveq 	#0,d1				;max-pattern = 0

ap_search_max:
			cmp.b 	(a0)+,d1			;pattern > d1
			bhi.s 	ap_searching		;sonst weitersuchen
			move.b 	-1(a0),d1			;max Åbernehmen
ap_searching:
			dbra 	d0,ap_search_max	;alle 128 positions durchsuchen
			addq.l 	#1,d1				;max-pattern +1
			moveq 	#10,d0				;10 mal shiften
			lsl.l 	d0,d1				;*1024 (1024 bytes pro pattern)

			lea		(a6),a0				;module-adresse
			lea		$0014+$0016(a0),a1	;zeiger aus lÑnge sample 1
			adda.w 	#$043c,a0			;offset zu den patterns
			adda.l 	d1,a0				;adresse sample 1
			lea		mt_samplestarts(pc),a2	;sample-tabelle
			moveq 	#31-1,d0			;max.31 instumente
			moveq 	#0,d2				;anzahl intrumente = 0
			
ap_set_tabl:
			move.l 	a0,(a2)+			;adresse in tabelle eintragen
			moveq 	#0,d1				;d1.l lîschen
			move.w 	(a1),d1				;sample-length lesen
			beq.s 	ap_any_spl			;0:kein sample
			add.l	d1,d1				;*2
			adda.l 	d1,a0				;adresse des nÑchsten samples
			addq.w 	#1,d2				;instrumenten-anzahl erhîhen
ap_any_spl:
			lea		$001e(a1),a1		;zeiger auf nÑchste lÑnge	setzen
			dbra 	d0,ap_set_tabl		;alle 31 samples

;d2.l:anzahl der instrumente
;a1.l:ende sample-lÑngen + $1e
;a2.l:ende sample-tab +	4
			subq.w 	#1,d2
			moveq 	#31-1,d0			;max.31 samples
ap_convert_spls:
			lea		-$1e(a1),a1			;Zeiger auf vorherige SamplelÑnge
			move.l	-(a2),a0			;Samplestartadr. holen
			moveq	#0,d3
			move.w	(a1),d3				;SamplelÑnge holen			
			beq.s	ap_conv_no_sample

            move.w	d2,d1				;Anzahl vorhandener Samples nach d1
            mulu.w	#330*2,d1			;* Verschiebedifferenz
			lea		(a0,d1.l),a3		;neue Sampleadr.
			move.l	a3,(a2)				;und speichern
			add.l	d3,a0				;Sampleendadr. errechnen
			add.l	d3,a0
			lea		(a0,d1.l),a3		;neue Sampleendadr.
			subq.w	#1,d3
ap_copy_up:
			move.w	-(a0),d4			;Sample holen
			xori.w	#$8080,d4			;Integerkonvertierung
			move.w	d4,-(a3)			;und speichern
			dbra	d3,ap_copy_up
			
			move.l	(a2),a3				;Samplestartadr. holen
			moveq	#0,d3
			move.w	6(a1),d3			;RepeatlÑnge holen			
			cmp.w	#1,d3				;<=1?
			bhi.s	ap_gen_loop

			moveq	#0,d3
			move.w	(a1),d3				;SamplelÑnge holen
			add.l	d3,a3				;Sampleende errechnen
			add.l	d3,a3
			move.w	#330-1,d3			;330 Worte
ap_clr_sample:
			move.w	#$8080,(a3)+		;lîschen
			dbra	d3,ap_clr_sample
            bra.s	ap_nun_weiter
            
ap_gen_loop:
			moveq	#0,d4
			move.w	4(a1),d4
			add.l	d4,a3				;Startadr. des Loops
            add.l	d4,a3
			lea		(a3,d3.w*2),a4		;Endadr. des Loops

			move.w	#330-1,d3			;330 Worte
ap_copy_sample:
			move.w	(a3)+,(a4)+			;kopieren
			dbra	d3,ap_copy_sample

ap_nun_weiter:
			subq.w 	#1,d2				;vorhandene samples -1
			bmi.s 	ap_conv_ende		;wasserdicht !
ap_conv_no_sample:
			dbra 	d0,ap_convert_spls
ap_conv_ende:
*****************************************************************************
              MOVE.B #6,MT_SPEED
              CLR.B MT_COUNTER
              CLR.B MT_SONGPOS
              CLR.W MT_PATTERNPOS
			  CLR.W DFF0A8
              CLR.W DFF0B8
              CLR.W DFF0C8
              CLR.W DFF0D8
*             MOVE.W #$000F,$00DFF096
			move.w	#$f,-(sp)
			bsr		dff096_contr
			addq.w	#2,sp
              RTS
ap_playmusic:
MT_MUSIC:
              MOVEM.L D0-D4/A0-A6,-(SP)
              ADDQ.B #1,MT_COUNTER
              MOVE.B MT_COUNTER(PC),D0
              CMP.B MT_SPEED(PC),D0
              BLO.S MT_NONEWNOTE
              CLR.B MT_COUNTER
              TST.B MT_PATTDELTIME2
              BEQ.S MT_GETNEWNOTE
              BSR.S MT_NONEWALLCHANNELS
              BRA MT_DSKIP

MT_NONEWNOTE:
              BSR.S MT_NONEWALLCHANNELS
              BRA MT_NONEWPOSYET

MT_NONEWALLCHANNELS:
              LEA DFF0A0,A5
              LEA MT_CHAN1TEMP(PC),A6
              BSR MT_CHECKEFX
              LEA DFF0B0,A5
              LEA MT_CHAN2TEMP(PC),A6
              BSR MT_CHECKEFX
              LEA DFF0C0,A5
              LEA MT_CHAN3TEMP(PC),A6
              BSR MT_CHECKEFX
              LEA DFF0D0,A5
              LEA MT_CHAN4TEMP(PC),A6
              BRA MT_CHECKEFX

MT_GETNEWNOTE:
              MOVEA.L MT_SONGDATAPTR(PC),A0
              LEA 12(A0),A3
              LEA 952(A0),A2            ;pattpo
              LEA 1084(A0),A0           ;patterndata
              MOVEQ #0,D0
              MOVEQ #0,D1
              MOVE.B MT_SONGPOS(PC),D0
              MOVE.B 0(A2,D0.w),D1
              ASL.L #8,D1
              ASL.L #2,D1
              ADD.W MT_PATTERNPOS(PC),D1
              CLR.W MT_DMACONTEMP

              LEA DFF0A0,A5
              LEA MT_CHAN1TEMP(PC),A6
              BSR.S MT_PLAYVOICE
              LEA DFF0B0,A5
              LEA MT_CHAN2TEMP(PC),A6
              BSR.S MT_PLAYVOICE
              LEA DFF0C0,A5
              LEA MT_CHAN3TEMP(PC),A6
              BSR.S MT_PLAYVOICE
              LEA DFF0D0,A5
              LEA MT_CHAN4TEMP(PC),A6
              BSR.S MT_PLAYVOICE
              BRA MT_SETDMA

MT_PLAYVOICE:
              TST.L (A6)
              BNE.S MT_PLVSKIP
              BSR MT_PERNOP
MT_PLVSKIP:
              MOVE.L 0(A0,D1.l),(A6)
              ADDQ.L #4,D1
              MOVEQ #0,D2
              MOVE.B N_CMD(A6),D2
              AND.B #$F0,D2
              LSR.B #4,D2
              MOVE.B (A6),D0
              AND.B #$F0,D0
              OR.B D0,D2
              TST.B D2
              BEQ MT_SETREGS
              MOVEQ #0,D3
              LEA MT_SAMPLESTARTS(PC),A1
              MOVE.W D2,D4
              SUBQ.L #1,D2
              ASL.L #2,D2
              MULU #30,D4
              MOVE.L 0(A1,D2.l),N_START(A6)
              MOVE.W 0(A3,D4.l),N_LENGTH(A6)
              MOVE.W 0(A3,D4.l),N_REALLENGTH(A6)
              MOVE.B 2(A3,D4.l),N_FINETUNE(A6)
              MOVE.B 3(A3,D4.l),N_VOLUME(A6)
              MOVE.W 4(A3,D4.l),D3      ; Get repeat
              TST.W D3
              BEQ.S MT_NOLOOP
              MOVE.L N_START(A6),D2     ; Get start
              ASL.W #1,D3
              ADD.L D3,D2               ; Add repeat
              MOVE.L D2,N_LOOPSTART(A6)
              MOVE.L D2,N_WAVESTART(A6)
              MOVE.W 4(A3,D4.l),D0      ; Get repeat
              ADD.W 6(A3,D4.l),D0       ; Add replen
              MOVE.W D0,N_LENGTH(A6)
              MOVE.W 6(A3,D4.l),N_REPLEN(A6) ; Save replen
              MOVEQ #0,D0
              MOVE.B N_VOLUME(A6),D0
              MOVE.W D0,8(A5)           ; Set volume
              BRA.S MT_SETREGS

MT_NOLOOP:
              MOVE.L N_START(A6),D2
              ADD.L D3,D2
              MOVE.L D2,N_LOOPSTART(A6)
              MOVE.L D2,N_WAVESTART(A6)
              MOVE.W 6(A3,D4.l),N_REPLEN(A6) ; Save replen
              MOVEQ #0,D0
              MOVE.B N_VOLUME(A6),D0
              MOVE.W D0,8(A5)           ; Set volume
MT_SETREGS:
              MOVE.W (A6),D0
              AND.W #$0FFF,D0
              BEQ MT_CHECKMOREEFX       ; If no note
              MOVE.W 2(A6),D0
              AND.W #$0FF0,D0
              CMP.W #$0E50,D0
              BEQ.S MT_DOSETFINETUNE
              MOVE.B 2(A6),D0
              AND.B #$0F,D0
              CMP.B #3,D0               ; TonePortamento
              BEQ.S MT_CHKTONEPORTA
              CMP.B #5,D0
              BEQ.S MT_CHKTONEPORTA
              CMP.B #9,D0               ; Sample Offset
              BNE.S MT_SETPERIOD
              BSR MT_CHECKMOREEFX
              BRA.S MT_SETPERIOD

MT_DOSETFINETUNE:
              BSR MT_SETFINETUNE
              BRA.S MT_SETPERIOD

MT_CHKTONEPORTA:
              BSR MT_SETTONEPORTA
              BRA MT_CHECKMOREEFX

MT_SETPERIOD:
              MOVEM.L D0-D1/A0-A1,-(SP)
              MOVE.W (A6),D1
              AND.W #$0FFF,D1
              LEA MT_PERIODTABLE(PC),A1
              MOVEQ #0,D0
              MOVEQ #36,D7
MT_FTULOOP:
              CMP.W 0(A1,D0.w),D1
              BHS.S MT_FTUFOUND
              ADDQ.L #2,D0
              DBRA D7,MT_FTULOOP
MT_FTUFOUND:
              MOVEQ #0,D1
              MOVE.B N_FINETUNE(A6),D1
              MULU #36*2,D1
              ADDA.L D1,A1
              MOVE.W 0(A1,D0.w),N_PERIOD(A6)
              MOVEM.L (SP)+,D0-D1/A0-A1

              MOVE.W 2(A6),D0
              AND.W #$0FF0,D0
              CMP.W #$0ED0,D0           ; Notedelay
              BEQ MT_CHECKMOREEFX

*              MOVE.W N_DMABIT(A6),$00DFF096
			move.w	n_dmabit(a6),-(sp)
			bsr		dff096_contr
			addq.w	#2,sp
              BTST #2,N_WAVECONTROL(A6)
              BNE.S MT_VIBNOC
              CLR.B N_VIBRATOPOS(A6)
MT_VIBNOC:
              BTST #6,N_WAVECONTROL(A6)
              BNE.S MT_TRENOC
              CLR.B N_TREMOLOPOS(A6)
MT_TRENOC:
              MOVE.L N_START(A6),(A5)   ; Set start
              MOVE.W N_LENGTH(A6),4(A5) ; Set length
              MOVE.W N_PERIOD(A6),D0
              MOVE.W D0,6(A5)           ; Set period
              MOVE.W N_DMABIT(A6),D0
              OR.W D0,MT_DMACONTEMP
              BRA MT_CHECKMOREEFX

MT_SETDMA:
*              MOVE.W #300,D0
*MT_WAITDMA:
*              DBRA D0,MT_WAITDMA
              MOVE.W MT_DMACONTEMP(PC),D0
              OR.W #$8000,D0
*              MOVE.W D0,$00DFF096
			move.w	d0,-(sp)
			bsr		dff096_contr
			addq.w	#2,sp
*              MOVE.W #300,D0
*MT_WAITDMA2:
*              DBRA D0,MT_WAITDMA2

              LEA DFF0A0+$000A,A5
              LEA MT_CHAN4TEMP(PC),A6
              MOVE.L N_LOOPSTART(A6),$00D0-$a0(A5)
              MOVE.W N_REPLEN(A6),$00D4-$a0(A5)
              LEA MT_CHAN3TEMP(PC),A6
              MOVE.L N_LOOPSTART(A6),$00C0-$a0(A5)
              MOVE.W N_REPLEN(A6),$00C4-$a0(A5)
              LEA MT_CHAN2TEMP(PC),A6
              MOVE.L N_LOOPSTART(A6),$00B0-$a0(A5)
              MOVE.W N_REPLEN(A6),$00B4-$a0(A5)
              LEA MT_CHAN1TEMP(PC),A6
              MOVE.L N_LOOPSTART(A6),$00A0-$a0(A5)
              MOVE.W N_REPLEN(A6),$00A4-$a0(A5)

MT_DSKIP:
              ADDI.W #16,MT_PATTERNPOS
              MOVE.B MT_PATTDELTIME,D0
              BEQ.S MT_DSKC
              MOVE.B D0,MT_PATTDELTIME2
              CLR.B MT_PATTDELTIME
MT_DSKC:      TST.B MT_PATTDELTIME2
              BEQ.S MT_DSKA
              SUBQ.B #1,MT_PATTDELTIME2
              BEQ.S MT_DSKA
              SUBI.W #16,MT_PATTERNPOS
MT_DSKA:      TST.B MT_PBREAKFLAG
              BEQ.S MT_NNPYSK
              SF  MT_PBREAKFLAG
              MOVEQ #0,D0
              MOVE.B MT_PBREAKPOS(PC),D0
              CLR.B MT_PBREAKPOS
              LSL.W #4,D0
              MOVE.W D0,MT_PATTERNPOS
MT_NNPYSK:
              CMPI.W #1024,MT_PATTERNPOS
              BLO.S MT_NONEWPOSYET
MT_NEXTPOSITION:
              MOVEQ #0,D0
              MOVE.B MT_PBREAKPOS(PC),D0
              LSL.W #4,D0
              MOVE.W D0,MT_PATTERNPOS
              CLR.B MT_PBREAKPOS
              CLR.B MT_POSJUMPFLAG
              ADDQ.B #1,MT_SONGPOS
              ANDI.B #$7F,MT_SONGPOS
              MOVE.B MT_SONGPOS(PC),D1
              MOVEA.L MT_SONGDATAPTR(PC),A0
              CMP.B 950(A0),D1
              BLO.S MT_NONEWPOSYET
              CLR.B MT_SONGPOS
MT_NONEWPOSYET:
              TST.B MT_POSJUMPFLAG
              BNE.S MT_NEXTPOSITION
              MOVEM.L (SP)+,D0-D4/A0-A6
              RTS

MT_CHECKEFX:
              BSR MT_UPDATEFUNK
              MOVE.W N_CMD(A6),D0
              AND.W #$0FFF,D0
              BEQ.S MT_PERNOP
              MOVE.B N_CMD(A6),D0
              AND.B #$0F,D0
              BEQ.S MT_ARPEGGIO
              CMP.B #1,D0
              BEQ MT_PORTAUP
              CMP.B #2,D0
              BEQ MT_PORTADOWN
              CMP.B #3,D0
              BEQ MT_TONEPORTAMENTO
              CMP.B #4,D0
              BEQ MT_VIBRATO
              CMP.B #5,D0
              BEQ MT_TONEPLUSVOLSLIDE
              CMP.B #6,D0
              BEQ MT_VIBRATOPLUSVOLSLIDE
              CMP.B #$0E,D0
              BEQ MT_E_COMMANDS
SETBACK:      MOVE.W N_PERIOD(A6),6(A5)
              CMP.B #7,D0
              BEQ MT_TREMOLO
              CMP.B #$0A,D0
              BEQ MT_VOLUMESLIDE
MT_RETURN2:
              RTS

MT_PERNOP:
              MOVE.W N_PERIOD(A6),6(A5)
              RTS

MT_ARPEGGIO:
              MOVEQ #0,D0
              MOVE.B MT_COUNTER(PC),D0
              DIVS #3,D0
              SWAP D0
              CMP.W #0,D0
              BEQ.S MT_ARPEGGIO2
              CMP.W #2,D0
              BEQ.S MT_ARPEGGIO1
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              LSR.B #4,D0
              BRA.S MT_ARPEGGIO3

MT_ARPEGGIO1:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #15,D0
              BRA.S MT_ARPEGGIO3

MT_ARPEGGIO2:
              MOVE.W N_PERIOD(A6),D2
              BRA.S MT_ARPEGGIO4

MT_ARPEGGIO3:
              ASL.W #1,D0
              MOVEQ #0,D1
              MOVE.B N_FINETUNE(A6),D1
              MULU #36*2,D1
              LEA MT_PERIODTABLE(PC),A0
              ADDA.L D1,A0
              MOVEQ #0,D1
              MOVE.W N_PERIOD(A6),D1
              MOVEQ #36,D7
MT_ARPLOOP:
              MOVE.W 0(A0,D0.w),D2
              CMP.W (A0),D1
              BHS.S MT_ARPEGGIO4
              ADDQ.L #2,A0
              DBRA D7,MT_ARPLOOP
              RTS

MT_ARPEGGIO4:
              MOVE.W D2,6(A5)
              RTS

MT_FINEPORTAUP:
              TST.B MT_COUNTER
              BNE.S MT_RETURN2
              MOVE.B #$0F,MT_LOWMASK
MT_PORTAUP:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B MT_LOWMASK(PC),D0
              MOVE.B #$FF,MT_LOWMASK
              SUB.W D0,N_PERIOD(A6)
              MOVE.W N_PERIOD(A6),D0
              AND.W #$0FFF,D0
              CMP.W #113,D0
              BPL.S MT_PORTAUSKIP
              ANDI.W #$F000,N_PERIOD(A6)
              ORI.W #113,N_PERIOD(A6)
MT_PORTAUSKIP:
              MOVE.W N_PERIOD(A6),D0
              AND.W #$0FFF,D0
              MOVE.W D0,6(A5)
              RTS

MT_FINEPORTADOWN:
              TST.B MT_COUNTER
              BNE MT_RETURN2
              MOVE.B #$0F,MT_LOWMASK
MT_PORTADOWN:
              CLR.W D0
              MOVE.B N_CMDLO(A6),D0
              AND.B MT_LOWMASK(PC),D0
              MOVE.B #$FF,MT_LOWMASK
              ADD.W D0,N_PERIOD(A6)
              MOVE.W N_PERIOD(A6),D0
              AND.W #$0FFF,D0
              CMP.W #856,D0
              BMI.S MT_PORTADSKIP
              ANDI.W #$F000,N_PERIOD(A6)
              ORI.W #856,N_PERIOD(A6)
MT_PORTADSKIP:
              MOVE.W N_PERIOD(A6),D0
              AND.W #$0FFF,D0
              MOVE.W D0,6(A5)
              RTS

MT_SETTONEPORTA:
              MOVE.L A0,-(SP)
              MOVE.W (A6),D2
              AND.W #$0FFF,D2
              MOVEQ #0,D0
              MOVE.B N_FINETUNE(A6),D0
              MULU #37*2,D0
              LEA MT_PERIODTABLE(PC),A0
              ADDA.L D0,A0
              MOVEQ #0,D0
MT_STPLOOP:
              CMP.W 0(A0,D0.w),D2
              BHS.S MT_STPFOUND
              ADDQ.W #2,D0
              CMP.W #37*2,D0
              BLO.S MT_STPLOOP
              MOVEQ #35*2,D0
MT_STPFOUND:
              MOVE.B N_FINETUNE(A6),D2
              AND.B #8,D2
              BEQ.S MT_STPGOSS
              TST.W D0
              BEQ.S MT_STPGOSS
              SUBQ.W #2,D0
MT_STPGOSS:
              MOVE.W 0(A0,D0.w),D2
              MOVEA.L (SP)+,A0
              MOVE.W D2,N_WANTEDPERIOD(A6)
              MOVE.W N_PERIOD(A6),D0
              CLR.B N_TONEPORTDIREC(A6)
              CMP.W D0,D2
              BEQ.S MT_CLEARTONEPORTA
              BGE MT_RETURN2
              MOVE.B #1,N_TONEPORTDIREC(A6)
              RTS

MT_CLEARTONEPORTA:
              CLR.W N_WANTEDPERIOD(A6)
              RTS

MT_TONEPORTAMENTO:
              MOVE.B N_CMDLO(A6),D0
              BEQ.S MT_TONEPORTNOCHANGE
              MOVE.B D0,N_TONEPORTSPEED(A6)
              CLR.B N_CMDLO(A6)
MT_TONEPORTNOCHANGE:
              TST.W N_WANTEDPERIOD(A6)
              BEQ MT_RETURN2
              MOVEQ #0,D0
              MOVE.B N_TONEPORTSPEED(A6),D0
              TST.B N_TONEPORTDIREC(A6)
              BNE.S MT_TONEPORTAUP
MT_TONEPORTADOWN:
              ADD.W D0,N_PERIOD(A6)
              MOVE.W N_WANTEDPERIOD(A6),D0
              CMP.W N_PERIOD(A6),D0
              BGT.S MT_TONEPORTASETPER
              MOVE.W N_WANTEDPERIOD(A6),N_PERIOD(A6)
              CLR.W N_WANTEDPERIOD(A6)
              BRA.S MT_TONEPORTASETPER

MT_TONEPORTAUP:
              SUB.W D0,N_PERIOD(A6)
              MOVE.W N_WANTEDPERIOD(A6),D0
              CMP.W N_PERIOD(A6),D0
              BLT.S MT_TONEPORTASETPER
              MOVE.W N_WANTEDPERIOD(A6),N_PERIOD(A6)
              CLR.W N_WANTEDPERIOD(A6)

MT_TONEPORTASETPER:
              MOVE.W N_PERIOD(A6),D2
              MOVE.B N_GLISSFUNK(A6),D0
              AND.B #$0F,D0
              BEQ.S MT_GLISSSKIP
              MOVEQ #0,D0
              MOVE.B N_FINETUNE(A6),D0
              MULU #36*2,D0
              LEA MT_PERIODTABLE(PC),A0
              ADDA.L D0,A0
              MOVEQ #0,D0
MT_GLISSLOOP:
              CMP.W 0(A0,D0.w),D2
              BHS.S MT_GLISSFOUND
              ADDQ.W #2,D0
              CMP.W #36*2,D0
              BLO.S MT_GLISSLOOP
              MOVEQ #35*2,D0
MT_GLISSFOUND:
              MOVE.W 0(A0,D0.w),D2
MT_GLISSSKIP:
              MOVE.W D2,6(A5)           ; Set period
              RTS

MT_VIBRATO:
              MOVE.B N_CMDLO(A6),D0
              BEQ.S MT_VIBRATO2
              MOVE.B N_VIBRATOCMD(A6),D2
              AND.B #$0F,D0
              BEQ.S MT_VIBSKIP
              AND.B #$F0,D2
              OR.B D0,D2
MT_VIBSKIP:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$F0,D0
              BEQ.S MT_VIBSKIP2
              AND.B #$0F,D2
              OR.B D0,D2
MT_VIBSKIP2:
              MOVE.B D2,N_VIBRATOCMD(A6)
MT_VIBRATO2:
              MOVE.B N_VIBRATOPOS(A6),D0
              LEA MT_VIBRATOTABLE(PC),A4
              LSR.W #2,D0
              AND.W #$001F,D0
              MOVEQ #0,D2
              MOVE.B N_WAVECONTROL(A6),D2
              AND.B #$03,D2
              BEQ.S MT_VIB_SINE
              LSL.B #3,D0
              CMP.B #1,D2
              BEQ.S MT_VIB_RAMPDOWN
              MOVE.B #255,D2
              BRA.S MT_VIB_SET
MT_VIB_RAMPDOWN:
              TST.B N_VIBRATOPOS(A6)
              BPL.S MT_VIB_RAMPDOWN2
              MOVE.B #255,D2
              SUB.B D0,D2
              BRA.S MT_VIB_SET
MT_VIB_RAMPDOWN2:
              MOVE.B D0,D2
              BRA.S MT_VIB_SET
MT_VIB_SINE:
              MOVE.B 0(A4,D0.w),D2
MT_VIB_SET:
              MOVE.B N_VIBRATOCMD(A6),D0
              AND.W #15,D0
              MULU D0,D2
              LSR.W #7,D2
              MOVE.W N_PERIOD(A6),D0
              TST.B N_VIBRATOPOS(A6)
              BMI.S MT_VIBRATONEG
              ADD.W D2,D0
              BRA.S MT_VIBRATO3
MT_VIBRATONEG:
              SUB.W D2,D0
MT_VIBRATO3:
              MOVE.W D0,6(A5)
              MOVE.B N_VIBRATOCMD(A6),D0
              LSR.W #2,D0
              AND.W #$003C,D0
              ADD.B D0,N_VIBRATOPOS(A6)
              RTS

MT_TONEPLUSVOLSLIDE:
              BSR MT_TONEPORTNOCHANGE
              BRA MT_VOLUMESLIDE

MT_VIBRATOPLUSVOLSLIDE:
              BSR.S MT_VIBRATO2
              BRA MT_VOLUMESLIDE

MT_TREMOLO:
              MOVE.B N_CMDLO(A6),D0
              BEQ.S MT_TREMOLO2
              MOVE.B N_TREMOLOCMD(A6),D2
              AND.B #$0F,D0
              BEQ.S MT_TRESKIP
              AND.B #$F0,D2
              OR.B D0,D2
MT_TRESKIP:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$F0,D0
              BEQ.S MT_TRESKIP2
              AND.B #$0F,D2
              OR.B D0,D2
MT_TRESKIP2:
              MOVE.B D2,N_TREMOLOCMD(A6)
MT_TREMOLO2:
              MOVE.B N_TREMOLOPOS(A6),D0
              LEA MT_VIBRATOTABLE(PC),A4
              LSR.W #2,D0
              AND.W #$001F,D0
              MOVEQ #0,D2
              MOVE.B N_WAVECONTROL(A6),D2
              LSR.B #4,D2
              AND.B #$03,D2
              BEQ.S MT_TRE_SINE
              LSL.B #3,D0
              CMP.B #1,D2
              BEQ.S MT_TRE_RAMPDOWN
              MOVE.B #255,D2
              BRA.S MT_TRE_SET
MT_TRE_RAMPDOWN:
              TST.B N_VIBRATOPOS(A6)
              BPL.S MT_TRE_RAMPDOWN2
              MOVE.B #255,D2
              SUB.B D0,D2
              BRA.S MT_TRE_SET
MT_TRE_RAMPDOWN2:
              MOVE.B D0,D2
              BRA.S MT_TRE_SET
MT_TRE_SINE:
              MOVE.B 0(A4,D0.w),D2
MT_TRE_SET:
              MOVE.B N_TREMOLOCMD(A6),D0
              AND.W #15,D0
              MULU D0,D2
              LSR.W #6,D2
              MOVEQ #0,D0
              MOVE.B N_VOLUME(A6),D0
              TST.B N_TREMOLOPOS(A6)
              BMI.S MT_TREMOLONEG
              ADD.W D2,D0
              BRA.S MT_TREMOLO3
MT_TREMOLONEG:
              SUB.W D2,D0
MT_TREMOLO3:
              BPL.S MT_TREMOLOSKIP
              CLR.W D0
MT_TREMOLOSKIP:
              CMP.W #$0040,D0
              BLS.S MT_TREMOLOOK
              MOVE.W #$0040,D0
MT_TREMOLOOK:
              MOVE.W D0,8(A5)
              MOVE.B N_TREMOLOCMD(A6),D0
              LSR.W #2,D0
              AND.W #$003C,D0
              ADD.B D0,N_TREMOLOPOS(A6)
              RTS

MT_SAMPLEOFFSET:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              BEQ.S MT_SONONEW
              MOVE.B D0,N_SAMPLEOFFSET(A6)
MT_SONONEW:
              MOVE.B N_SAMPLEOFFSET(A6),D0
              LSL.W #7,D0
              CMP.W N_LENGTH(A6),D0
              BGE.S MT_SOFSKIP
              SUB.W D0,N_LENGTH(A6)
              LSL.W #1,D0
              ADD.L D0,N_START(A6)
              RTS
MT_SOFSKIP:
              MOVE.W #$0001,N_LENGTH(A6)
              RTS

MT_VOLUMESLIDE:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              LSR.B #4,D0
              TST.B D0
              BEQ.S MT_VOLSLIDEDOWN
MT_VOLSLIDEUP:
              ADD.B D0,N_VOLUME(A6)
              CMPI.B #$40,N_VOLUME(A6)
              BMI.S MT_VSUSKIP
              MOVE.B #$40,N_VOLUME(A6)
MT_VSUSKIP:
              MOVE.B N_VOLUME(A6),D0
              MOVE.W D0,8(A5)
              RTS

MT_VOLSLIDEDOWN:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
MT_VOLSLIDEDOWN2:
              SUB.B D0,N_VOLUME(A6)
              BPL.S MT_VSDSKIP
              CLR.B N_VOLUME(A6)
MT_VSDSKIP:
              MOVE.B N_VOLUME(A6),D0
              MOVE.W D0,8(A5)
              RTS

MT_POSITIONJUMP:
              MOVE.B N_CMDLO(A6),D0
              SUBQ.B #1,D0
              MOVE.B D0,MT_SONGPOS
MT_PJ2:       CLR.B MT_PBREAKPOS
              ST  MT_POSJUMPFLAG
              RTS

MT_VOLUMECHANGE:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              CMP.B #$40,D0
              BLS.S MT_VOLUMEOK
              MOVEQ #$40,D0
MT_VOLUMEOK:
              MOVE.B D0,N_VOLUME(A6)
              MOVE.W D0,8(A5)
              RTS

MT_PATTERNBREAK:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              MOVE.L D0,D2
              LSR.B #4,D0
              MULU #10,D0
              AND.B #$0F,D2
              ADD.B D2,D0
              CMP.B #63,D0
              BHI.S MT_PJ2
              MOVE.B D0,MT_PBREAKPOS
              ST  MT_POSJUMPFLAG
              RTS

MT_SETSPEED:
              MOVE.B 3(A6),D0
              BEQ MT_RETURN2
              CLR.B MT_COUNTER
              MOVE.B D0,MT_SPEED
              RTS

MT_CHECKMOREEFX:
              BSR MT_UPDATEFUNK
              MOVE.B 2(A6),D0
              AND.B #$0F,D0
              CMP.B #$09,D0
              BEQ MT_SAMPLEOFFSET
              CMP.B #$0B,D0
              BEQ MT_POSITIONJUMP
              CMP.B #$0D,D0
              BEQ.S MT_PATTERNBREAK
              CMP.B #$0E,D0
              BEQ.S MT_E_COMMANDS
              CMP.B #$0F,D0
              BEQ.S MT_SETSPEED
              CMP.B #$0C,D0
              BEQ MT_VOLUMECHANGE
              BRA MT_PERNOP

MT_E_COMMANDS:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$F0,D0
              LSR.B #4,D0
              BEQ.S MT_FILTERONOFF
              CMP.B #1,D0
              BEQ MT_FINEPORTAUP
              CMP.B #2,D0
              BEQ MT_FINEPORTADOWN
              CMP.B #3,D0
              BEQ.S MT_SETGLISSCONTROL
              CMP.B #4,D0
              BEQ MT_SETVIBRATOCONTROL
              CMP.B #5,D0
              BEQ MT_SETFINETUNE
              CMP.B #6,D0
              BEQ MT_JUMPLOOP
              CMP.B #7,D0
              BEQ MT_SETTREMOLOCONTROL
              CMP.B #9,D0
              BEQ MT_RETRIGNOTE
              CMP.B #$0A,D0
              BEQ MT_VOLUMEFINEUP
              CMP.B #$0B,D0
              BEQ MT_VOLUMEFINEDOWN
              CMP.B #$0C,D0
              BEQ MT_NOTECUT
              CMP.B #$0D,D0
              BEQ MT_NOTEDELAY
              CMP.B #$0E,D0
              BEQ MT_PATTERNDELAY
              CMP.B #$0F,D0
              BEQ MT_FUNKIT
              RTS

MT_FILTERONOFF:
*              MOVE.B N_CMDLO(A6),D0
*              AND.B #1,D0
*              ASL.B #1,D0
*              ANDI.B #$FD,$00BFE001
*              OR.B D0,$00BFE001
              RTS

MT_SETGLISSCONTROL:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              ANDI.B #$F0,N_GLISSFUNK(A6)
              OR.B D0,N_GLISSFUNK(A6)
              RTS

MT_SETVIBRATOCONTROL:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              ANDI.B #$F0,N_WAVECONTROL(A6)
              OR.B D0,N_WAVECONTROL(A6)
              RTS

MT_SETFINETUNE:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              MOVE.B D0,N_FINETUNE(A6)
              RTS

MT_JUMPLOOP:
              TST.B MT_COUNTER
              BNE MT_RETURN2
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              BEQ.S MT_SETLOOP
              TST.B N_LOOPCOUNT(A6)
              BEQ.S MT_JUMPCNT
              SUBQ.B #1,N_LOOPCOUNT(A6)
              BEQ MT_RETURN2
MT_JMPLOOP:   MOVE.B N_PATTPOS(A6),MT_PBREAKPOS
              ST  MT_PBREAKFLAG
              RTS

MT_JUMPCNT:
              MOVE.B D0,N_LOOPCOUNT(A6)
              BRA.S MT_JMPLOOP

MT_SETLOOP:
              MOVE.W MT_PATTERNPOS(PC),D0
              LSR.W #4,D0
              MOVE.B D0,N_PATTPOS(A6)
              RTS

MT_SETTREMOLOCONTROL:
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              LSL.B #4,D0
              ANDI.B #$0F,N_WAVECONTROL(A6)
              OR.B D0,N_WAVECONTROL(A6)
              RTS

MT_RETRIGNOTE:
              MOVE.L D1,-(SP)
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              BEQ.S MT_RTNEND
              MOVEQ #0,D1
              MOVE.B MT_COUNTER(PC),D1
              BNE.S MT_RTNSKP
              MOVE.W (A6),D1
              AND.W #$0FFF,D1
              BNE.S MT_RTNEND
              MOVEQ #0,D1
              MOVE.B MT_COUNTER(PC),D1
MT_RTNSKP:
              DIVU D0,D1
              SWAP D1
              TST.W D1
              BNE.S MT_RTNEND
MT_DORETRIG:
*              MOVE.W N_DMABIT(A6),$00DFF096 ; Channel DMA off
*			move.w	n_dmabit(a6),-(sp)
*			bsr		dff096_contr
*			addq.w	#2,sp		
              MOVE.L N_START(A6),(A5)   ; Set sampledata pointer
              MOVE.W N_LENGTH(A6),4(A5) ; Set length
*              MOVE.W #300,D0
*MT_RTNLOOP1:
*              DBRA D0,MT_RTNLOOP1
*              MOVE.W N_DMABIT(A6),D0
*              BSET #15,D0
*              MOVE.W D0,$00DFF096
*			move.w	d0,-(sp)
*			bsr		dff096_contr
*			addq.w	#2,sp
*              MOVE.W #300,D0
*MT_RTNLOOP2:
*              DBRA D0,MT_RTNLOOP2
              MOVE.L N_LOOPSTART(A6),10(A5)    ;kein +10
              MOVE.w N_REPLEN(A6),4+10(A5)     ;war .l  / kein +10
MT_RTNEND:
              MOVE.L (SP)+,D1
              RTS

MT_VOLUMEFINEUP:
              TST.B MT_COUNTER
              BNE MT_RETURN2
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              BRA MT_VOLSLIDEUP

MT_VOLUMEFINEDOWN:
              TST.B MT_COUNTER
              BNE MT_RETURN2
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              BRA MT_VOLSLIDEDOWN2

MT_NOTECUT:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              CMP.B MT_COUNTER(PC),D0
              BNE MT_RETURN2
              CLR.B N_VOLUME(A6)
              MOVE.W #0,8(A5)
              RTS

MT_NOTEDELAY:
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              CMP.B MT_COUNTER,D0
              BNE MT_RETURN2
              MOVE.W (A6),D0
              BEQ MT_RETURN2
              MOVE.L D1,-(SP)
              BRA MT_DORETRIG

MT_PATTERNDELAY:
              TST.B MT_COUNTER
              BNE MT_RETURN2
              MOVEQ #0,D0
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              TST.B MT_PATTDELTIME2
              BNE MT_RETURN2
              ADDQ.B #1,D0
              MOVE.B D0,MT_PATTDELTIME
              RTS

MT_FUNKIT:
              TST.B MT_COUNTER
              BNE MT_RETURN2
              MOVE.B N_CMDLO(A6),D0
              AND.B #$0F,D0
              LSL.B #4,D0
              ANDI.B #$0F,N_GLISSFUNK(A6)
              OR.B D0,N_GLISSFUNK(A6)
              TST.B D0
              BEQ MT_RETURN2
MT_UPDATEFUNK:
              MOVEM.L D1/A0,-(SP)
              MOVEQ #0,D0
              MOVE.B N_GLISSFUNK(A6),D0
              LSR.B #4,D0
              BEQ.S MT_FUNKEND
              LEA MT_FUNKTABLE(PC),A0
              MOVE.B 0(A0,D0.w),D0
              ADD.B D0,N_FUNKOFFSET(A6)
              BTST #7,N_FUNKOFFSET(A6)
              BEQ.S MT_FUNKEND
              CLR.B N_FUNKOFFSET(A6)

              MOVE.L N_LOOPSTART(A6),D0
              MOVEQ #0,D1
              MOVE.W N_REPLEN(A6),D1
              ADD.L D1,D0
              ADD.L D1,D0
              MOVEA.L N_WAVESTART(A6),A0
              ADDQ.L #1,A0
              CMPA.L D0,A0
              BLO.S MT_FUNKOK
              MOVEA.L N_LOOPSTART(A6),A0
MT_FUNKOK:
              MOVE.L A0,N_WAVESTART(A6)
              MOVEQ #-1,D0
              SUB.B (A0),D0
              MOVE.B D0,(A0)
MT_FUNKEND:
              MOVEM.L (SP)+,D1/A0
              RTS


MT_FUNKTABLE: DC.B 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

MT_VIBRATOTABLE:
              DC.B 0,24,49,74,97,120,141,161
              DC.B 180,197,212,224,235,244,250,253
              DC.B 255,253,250,244,235,224,212,197
              DC.B 180,161,141,120,97,74,49,24

MT_PERIODTABLE:
; Tuning 0, Normal
              DC.W 856,808,762,720,678,640,604,570,538,508,480,453
              DC.W 428,404,381,360,339,320,302,285,269,254,240,226
              DC.W 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
              DC.W 850,802,757,715,674,637,601,567,535,505,477,450
              DC.W 425,401,379,357,337,318,300,284,268,253,239,225
              DC.W 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
              DC.W 844,796,752,709,670,632,597,563,532,502,474,447
              DC.W 422,398,376,355,335,316,298,282,266,251,237,224
              DC.W 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
              DC.W 838,791,746,704,665,628,592,559,528,498,470,444
              DC.W 419,395,373,352,332,314,296,280,264,249,235,222
              DC.W 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
              DC.W 832,785,741,699,660,623,588,555,524,495,467,441
              DC.W 416,392,370,350,330,312,294,278,262,247,233,220
              DC.W 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
              DC.W 826,779,736,694,655,619,584,551,520,491,463,437
              DC.W 413,390,368,347,328,309,292,276,260,245,232,219
              DC.W 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
              DC.W 820,774,730,689,651,614,580,547,516,487,460,434
              DC.W 410,387,365,345,325,307,290,274,258,244,230,217
              DC.W 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
              DC.W 814,768,725,684,646,610,575,543,513,484,457,431
              DC.W 407,384,363,342,323,305,288,272,256,242,228,216
              DC.W 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
              DC.W 907,856,808,762,720,678,640,604,570,538,508,480
              DC.W 453,428,404,381,360,339,320,302,285,269,254,240
              DC.W 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
              DC.W 900,850,802,757,715,675,636,601,567,535,505,477
              DC.W 450,425,401,379,357,337,318,300,284,268,253,238
              DC.W 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
              DC.W 894,844,796,752,709,670,632,597,563,532,502,474
              DC.W 447,422,398,376,355,335,316,298,282,266,251,237
              DC.W 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
              DC.W 887,838,791,746,704,665,628,592,559,528,498,470
              DC.W 444,419,395,373,352,332,314,296,280,264,249,235
              DC.W 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
              DC.W 881,832,785,741,699,660,623,588,555,524,494,467
              DC.W 441,416,392,370,350,330,312,294,278,262,247,233
              DC.W 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
              DC.W 875,826,779,736,694,655,619,584,551,520,491,463
              DC.W 437,413,390,368,347,328,309,292,276,260,245,232
              DC.W 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
              DC.W 868,820,774,730,689,651,614,580,547,516,487,460
              DC.W 434,410,387,365,345,325,307,290,274,258,244,230
              DC.W 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
              DC.W 862,814,768,725,684,646,610,575,543,513,484,457
              DC.W 431,407,384,363,342,323,305,288,272,256,242,228
              DC.W 216,203,192,181,171,161,152,144,136,128,121,114

MT_CHAN1TEMP: DC.L 0,0,0,0,0,$00010000,0,0,0,0,0
MT_CHAN2TEMP: DC.L 0,0,0,0,0,$00020000,0,0,0,0,0
MT_CHAN3TEMP: DC.L 0,0,0,0,0,$00040000,0,0,0,0,0
MT_CHAN4TEMP: DC.L 0,0,0,0,0,$00080000,0,0,0,0,0


ap_SAMPLETAB:
MT_SAMPLESTARTS:DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

MT_SONGDATAPTR:DC.L 0

MT_SPEED:     DC.B 6
MT_COUNTER:   DC.B 0
MT_SONGPOS:   DC.B 0
MT_PBREAKPOS: DC.B 0
MT_POSJUMPFLAG:DC.B 0
MT_PBREAKFLAG:DC.B 0
MT_LOWMASK:   DC.B 0
MT_PATTDELTIME:DC.B 0
MT_PATTDELTIME2:DC.B 0,0

MT_PATTERNPOS:DC.W 0
MT_DMACONTEMP:DC.W 0

;/* End of File */
