	
				include "DSPMOD.INC"

				export Player, InitPlayer, PlayInfos
				export SongPosition, PatternPosition
				export Counter
				import mod, ExtSpeed
				import ModSongLen, ModPatData, ModSamples, ModTracks
				import sample_starts, SampSets, PlayFlag
				import PlayFreq2_5
								
; FileFormat offsets
o_songname      equ 0                   ;songname offset
o_sampleinfo    equ 20                  ;first sample starts here
o_numofpatt     equ 950                 ;number of patterns are stored here
o_pattpos       equ 952                 ;pattern positions table is here
o_mahokakt      equ 1080                ;"M.K." :)
o_patterndata   equ 1084                ;first pattern starts at this position

; Song offsets. W/L/B means word/longword/byte length.

n_note          equ 0                   ;W
n_cmd           equ 2                   ;W
n_cmdlo         equ 3                   ;low B of cmd
n_start         equ 4                   ;L
n_length        equ 8                   ;W
n_loopstart     equ 10                  ;L
n_replen        equ 14                  ;W
n_period        equ 16                  ;W
n_finetune      equ 18                  ;B
n_volume        equ 19                  ;B
n_dmabit        equ 20                  ;W
n_toneportdirec equ 22                  ;B
n_toneportspeed equ 23                  ;B
n_wantedperiod  equ 24                  ;W
n_vibratocmd    equ 26                  ;B
n_vibratopos    equ 27                  ;B
n_tremolocmd    equ 28                  ;B
n_tremolopos    equ 29                  ;B
n_wavecontrol   equ 30                  ;B
n_glissfunk     equ 31                  ;B
n_sampleoffset  equ 32                  ;B
n_pattpos       equ 33                  ;B
n_loopcount     equ 34                  ;B
n_funkoffset    equ 35                  ;B
n_wavestart     equ 36                  ;L
n_reallength    equ 40                  ;W
n_trigger       equ 42                  ;B
n_samplenum     equ 43                  ;B


;************** alle 20 ms ***************************************************

Player:      	tst.b	PlayFlag
				beq.s	NoPlay
				movea.l mod,a0
                addq.w  #1,Counter      ;++
                move.w  Counter(pc),d0
                cmp.w   CurrSpeed(pc),d0
                blo.s   NoNewNote
                clr.w   Counter         ;Clear Counter
                tst.b   PattDelayTime2
                beq.s   GetNewNote
                bsr.s   NoNewAllChannels
                bra     dskip

NoNewNote:      bsr.s   NoNewAllChannels
                bra     NoNewPositionYet

NoNewAllChannels:
				move.w	ModTracks,d6
				subq.w	#1,d6
                lea     audchan1temp(pc),a6
                lea     SampSets,a5
CheckEffects_:  bsr     CheckEffects
             	add.w	#44,a6
                add.w	#SizeOfSamp_,a5
				dbra	d6,CheckEffects_
NoPlay:			rts
				
GetNewNote:     lea     42-30(a0),a3
                move.l  ModPatData,a0 	;Startadresse Patterns
                moveq   #0,d1
                move.l  ModSongLen,a2 	;Adresse Songlength
                move.w  SongPosition(pc),d0
                move.b  2(a2,d0.w),d1   ;d1 = PatternNr
                lsl.l   #8,d1          	;*1024
                lsl.l   #2,d1
				cmp.w	#8,ModTracks	;8 Tracks ?
				bne.s	.m1				;nein
				lsl.l	#1,d1			;*2048
.m1:            move.w  PatternPosition(pc),d0
				ext.l	d0
                add.l	d0,d1

				moveq	#0,d6
                lea     SampSets,a5
                lea     audchan1temp(pc),a6
PlayVoices:     move.w	d6,d2			;Channel-Nr
                bsr		PlayVoice       ;Voice
                moveq   #0,d0
                move.b  n_volume(a6),d0 ;Set Volume
                move.w  d0,SampVol(a5)
				add.w	#SizeOfSamp_,a5
				add.w	#44,a6
				addq.w	#1,d6
				cmp.w	ModTracks,d6
				bne.s	PlayVoices			;fÅr alle Voices

;-------------- nÑchste Pattern-Zeile bestimmen --------------------------

dskip:          move.w	ModTracks,d1
				lsl.w	#2,d1				;*4 = 16/32
				add.w  	d1,PatternPosition	;next Pattern-Zeile
                move.b  PattDelayTime,d0	;Pattern-Delay ?
                beq.s   dskpc				;nein
                move.b  d0,PattDelayTime2
                clr.b   PattDelayTime
dskpc:          tst.b   PattDelayTime2		;lÑuft Pattern-Verzîgerung ?
                beq.s   dskpa				;nein
                subq.b  #1,PattDelayTime2	;dec PattDelay
                beq.s   dskpa				;PattDelay abgelaufen
                sub.w	d1,PatternPosition	;bei alten PatternLine bleiben
                
dskpa:          tst.b   PBreakFlag				;Pattern-Break ?
                beq.s   nnpysk					;nein
                sf      PBreakFlag				;PatternBreak aus
                moveq   #0,d0
                move.b  PBreakPosition(pc),d0
                mulu.w  d1,d0					;*16 / *32
                move.w  d0,PatternPosition
                clr.b   PBreakPosition
                
nnpysk:         move.w	d1,d2
				lsl.w	#6,d2					;*64 = 1024/2048
				cmp.w	PatternPosition,d2
                bne.s   NoNewPositionYet
NextPosition:   moveq   #0,d0
                move.b  PBreakPosition(pc),d0
                mulu.w	d1,d0					;*16 / *32
                move.w  d0,PatternPosition
                clr.b   PBreakPosition
                clr.b   PosJumpAssert
                addq.w  #1,SongPosition
                andi.w  #$7f,SongPosition
                move.w  SongPosition(pc),d1
				move.l	ModSongLen,a0
                cmp.b   (a0),d1
                blo.s   NoNewPositionYet
                moveq	#0,d1
                move.b	1(a0),d1			;Restart
                move.w	d1,SongPosition
NoNewPositionYet:
                tst.b   PosJumpAssert
                bne.s   NextPosition
                rts

******************************************************************************
*               d1: PatternOffset
*               a0: StartAdr Pattern
*               a6: WorkArea

PlayVoice:      tst.l   (a6)            ;InfoLong ?
                bne.s   plvskip         ;ja
                bsr     PerNop          ;Periode -> Paula
plvskip:        move.l  0(a0,d1.l),(a6) ;Read one track from pattern
                addq.l  #4,d1           ;next InfoLong of next Channel
				btst	d2,ActiveChannels
				beq		Return				
                moveq   #0,d2
                move.b  n_cmd(a6),d2    ;Get lower 4 bits of instrument
                and.b   #$f0,d2
                lsr.b   #4,d2
                move.b  (a6),d0         ;Get higher 4 bits of instrument
                and.b   #$f0,d0
                or.b    d0,d2
                tst.b   d2
                beq		SetRegisters    ;Instrument was zero
                moveq   #0,d3
                lea     sample_starts,a1
                move.w  d2,d4
                move.b  d2,n_samplenum(a6) ;Samplenummer merken
                subq.l  #1,d2
                lsl.l   #2,d2           ;*4
                mulu    #30,d4   		;*30
                move.l  0(a1,d2.l),n_start(a6) ;Sample Start
                move.w  0(a3,d4.l),n_length(a6) ;LÑnge
                move.w  0(a3,d4.l),n_reallength(a6)
                move.b  2(a3,d4.l),n_finetune(a6)
                move.b  3(a3,d4.l),n_volume(a6)
                move.w  4(a3,d4.l),d3   ;Get repeat
                beq.s   NoLoop          ;RepStart = 0

                move.l  n_start(a6),d2  ;Get start
                asl.w   #1,d3           ;*2
                add.l   d3,d2           ;start + repeat
                move.l  d2,n_loopstart(a6) ;= loopstart
                move.l  d2,n_wavestart(a6)
                movem.w 4(a3,d4.l),d0/d2;Get repeat, replen
                add.w   d2,d0   		;Add replen

;bei einigen Moduln ist repstart + replen > Samplelen !!!

				move.w	n_reallength(a6),d3
				cmp.w	d3,d0
				bls.s	LengthOK
				move.w	d3,n_length(a6)	;LÑnge max n_reallength
				sub.w	d3,d0
				sub.w	d0,d2			;replen korregieren
	            move.w  d2,n_replen(a6) ;Save replen
                bra.s   SetRegisters

LengthOK:       move.w  d0,n_length(a6) ;LÑnge = repeat + repeatlength
                move.w  d2,n_replen(a6) ;Save replen
                bra.s   SetRegisters

;-------------- RepStart = 0 -----------------------------------------

NoLoop:         move.l  n_start(a6),d2
                move.l  d2,n_loopstart(a6)		;LoopStart = SampleStart
                move.l  d2,n_wavestart(a6)
                move.w  6(a3,d4.l),n_replen(a6) ;Save replen

SetRegisters:   move.w  (a6),d0
                and.w   #$0fff,d0
                beq     CheckMoreEffects ;If no note ->
                move.w  2(a6),d0
                and.w   #$0ff0,d0
                cmp.w   #$0e50,d0       ;finetune?
                beq.s   DoSetFineTune
                move.b  2(a6),d0
                and.b   #$0f,d0
                cmp.b   #3,d0           ;TonePortamento?
                beq.s   ChkTonePorta
                cmp.b   #5,d0           ;TonePortamento + VolSlide?
                beq.s   ChkTonePorta
                cmp.b   #9,d0           ;Sample Offset?

                bne.s   SetPeriod
                bsr     CheckMoreEffects
                bra.s   SetPeriod

DoSetFineTune:  bsr     SetFineTune
                bra.s   SetPeriod

ChkTonePorta:   bsr     SetTonePorta
                bra     CheckMoreEffects

SetPeriod:      movem.l d0-d1/a0-a1,-(sp)
                move.w  n_note(a6),d1
                and.w   #$0fff,d1       ;12 Bit SamplePeriod
                lea     PeriodTable(pc),a1
                moveq   #0,d0
                moveq   #3*12,d7
ftuloop:        cmp.w   0(a1,d0.w),d1   ;suche Periode
                bcc.s   ftufound		;Periode <= n_note
                addq.l  #2,d0
                dbra    d7,ftuloop

ftufound:       moveq   #0,d1
                move.b  n_finetune(a6),d1 		;Fintune
                mulu    #(3*12+1)*2,d1        	;select Tab
                adda.l  d1,a1
                move.w  0(a1,d0.w),n_period(a6) ;get period with finetune
                movem.l (sp)+,d0-d1/a0-a1

                move.w  2(a6),d0
                and.w   #$0ff0,d0
                cmp.w   #$0ed0,d0
                beq     CheckMoreEffects

;                move.w  n_dmabit(a6),$dff096

                btst    #2,n_wavecontrol(a6)
                bne.s   vibnoc
                clr.b   n_vibratopos(a6)

vibnoc:         btst    #6,n_wavecontrol(a6)
                bne.s   trenoc
                clr.b   n_tremolopos(a6)

trenoc:         clr.l	SampPtrFrac(a5)
				move.l	n_start(a6),d0
				bne.s	StartOK
				
				move.l	#dummy+2,d0			;ungÅltiges Sample
				move.l	d0,SampPtr(a5)
				move.l	d0,SampEnd(a5)
				moveq	#2,d0
				move.l	d0,RepLen(a5)
				clr.l	n_loopstart(a6)
				move.w	#1,n_replen(a6)
				bra.s	sdmaskp				
				
StartOK:		move.l	d0,SampPtr(a5)
				moveq	#0,d2
				move.w	n_length(a6),d2
				add.l	d2,d2
				add.l	d2,d0
				move.l	d0,SampEnd(a5)
                move.l  n_loopstart(a6),RepStart(a5)
				moveq	#0,d0
                move.w  n_replen(a6),d0
				add.l	d0,d0
				move.l	d0,RepLen(a5)

sdmaskp:        move.w  n_period(a6),SampPer(a5)        ;Set period
                st      n_trigger(a6)
                move.w  n_dmabit(a6),d0
                bra     CheckMoreEffects


;-------------- Effekte werden bei jedem VBL geupdated --------------

CheckEffects:   bsr.s   chkefx2
                moveq   #0,d0
                move.b  n_volume(a6),d0
                move.w  d0,SampVol(a5)		;Set Volume
                rts

chkefx2:        bsr     UpdateFunk
                move.w  n_cmd(a6),d0
                and.w   #$0fff,d0
                beq.s   Return
                move.b  n_cmd(a6),d0
                and.b   #$0f,d0				;get Effect-Nr
                tst.b   d0
                beq.s   Arpeggio
                cmp.b   #1,d0
                beq     PortaUp
                cmp.b   #2,d0
                beq     PortaDown
                cmp.b   #3,d0
                beq     TonePortamento
                cmp.b   #4,d0
                beq     Vibrato
                cmp.b   #5,d0
                beq     TonePlusVolSlide
                cmp.b   #6,d0
                beq     VibratoPlusVolSlide
                cmp.b   #$0e,d0
                beq     ECommands

SetBack:        move.w  n_period(a6),SampPer(a5)
                cmp.b   #7,d0
                beq     Tremolo
                cmp.b   #$0a,d0
                beq     VolumeSlide

Return:         rts

PerNop:         move.w  n_period(a6),SampPer(a5) ;Periode -> Paula
                rts

;--------------------------------------------------------------------------
;				Cmd 0 / Arpeggio
;--------------------------------------------------------------------------

Arpeggio:       moveq   #0,d0
                move.w  Counter(pc),d0
                divs    #3,d0
                swap    d0
                cmp.w   #1,d0
                beq.s   Arpeggio1			;Rest = 1
                cmp.w   #2,d0
                beq.s   Arpeggio2			;Rest = 2

Arpeggio0:      move.w  n_period(a6),d2		;Rest = 0, use orginalperiod
                bra.s   ArpeggioSet			;!fintune wird nicht berÅcksichtigt !

Arpeggio1:      moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                lsr.b   #4,d0				;obere Nibble
                bra.s   ArpeggioFind

Arpeggio2:      moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #15,d0				;untere Nibble

ArpeggioFind:   asl.w   #1,d0				;*2
                moveq   #0,d1
                move.b  n_finetune(a6),d1
                mulu    #37*2,d1
                lea     PeriodTable(pc),a0
                adda.l  d1,a0				;select Periodentabelle je nach finetune
                moveq   #0,d1
                move.w  n_period(a6),d1		;aktuelle Periode
                moveq   #3*12,d7

arploop:        move.w  0(a0,d0.w),d2		;get period + halfnote
                cmp.w   (a0),d1				;
                bcc.s   ArpeggioSet			;Periode <= aktuelle Periode
                addq.l  #2,a0
                dbra    d7,arploop
                rts

ArpeggioSet:    move.w  d2,SampPer(a5)
                rts

;-------------------------------------------------------------------------

FinePortaUp:    tst.w   Counter
                bne.s   Return
                move.b  #$0f,LowMask

PortaUp:        moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   LowMask,d0
                move.b  #$ff,LowMask
                sub.w   d0,n_period(a6)
                move.w  n_period(a6),d0
                and.w   #$0fff,d0
                cmp.w   #$71,d0
                bpl.s   PortaUskip
                andi.w  #$f000,n_period(a6)
                ori.w   #$71,n_period(a6)

PortaUskip:     move.w  n_period(a6),d0
                and.w   #$0fff,d0
                move.w  d0,SampPer(a5)
                rts

FinePortaDown:  tst.w   Counter
                bne     Return
                move.b  #$0f,LowMask

PortaDown:      clr.w   d0
                move.b  n_cmdlo(a6),d0
                and.b   LowMask,d0
                move.b  #$ff,LowMask
                add.w   d0,n_period(a6)			;Freq down
                move.w  n_period(a6),d0
                and.w   #$0fff,d0
                cmp.w   #$0358,d0				;c1 erreicht ?
                bmi.s   Portadskip				;nein
                andi.w  #$f000,n_period(a6)
                ori.w   #$0358,n_period(a6)		;auf c1 halten

Portadskip:     move.w  n_period(a6),d0			;Setze Freq
                and.w   #$0fff,d0
                move.w  d0,SampPer(a5)
                rts

SetTonePorta:   move.l  a0,-(sp)
                move.w  (a6),d2
                and.w   #$0fff,d2
                moveq   #0,d0
                move.b  n_finetune(a6),d0
                mulu    #37*2,d0
                lea     PeriodTable(pc),a0
                adda.l  d0,a0
                moveq   #0,d0
StpLoop:
                cmp.w   0(a0,d0.w),d2
                bhs.s   StpFound
                addq.w  #2,d0
                cmp.w   #37*2,d0
                blo.s   StpLoop
                moveq   #35*2,d0
StpFound:
                move.b  n_finetune(a6),d2
                and.b   #8,d2
                beq.s   StpGoss
                tst.w   d0
                beq.s   StpGoss
                subq.w  #2,d0
StpGoss:
                move.w  0(a0,d0.w),d2
                movea.l (sp)+,a0
                move.w  d2,n_wantedperiod(a6)
                move.w  n_period(a6),d0
                clr.b   n_toneportdirec(a6)
                cmp.w   d0,d2
                beq.s   ClearTonePorta
                bge     Return
                move.b  #1,n_toneportdirec(a6)
                rts

ClearTonePorta: clr.w   n_wantedperiod(a6)
                rts

TonePortamento: move.b  n_cmdlo(a6),d0
                beq.s   TonePortNoChange
                move.b  d0,n_toneportspeed(a6)
                clr.b   n_cmdlo(a6)
TonePortNoChange:
                tst.w   n_wantedperiod(a6)
                beq     Return
                moveq   #0,d0
                move.b  n_toneportspeed(a6),d0
                tst.b   n_toneportdirec(a6)
                bne.s   TonePortaUp

TonePortaDown:  add.w   d0,n_period(a6)
                move.w  n_wantedperiod(a6),d0
                cmp.w   n_period(a6),d0
                bgt.s   TonePortaSetPer
                move.w  n_wantedperiod(a6),n_period(a6)
                clr.w   n_wantedperiod(a6)
                bra.s   TonePortaSetPer

TonePortaUp:    sub.w   d0,n_period(a6)
                move.w  n_wantedperiod(a6),d0
                cmp.w   n_period(a6),d0
                blt.s   TonePortaSetPer
                move.w  n_wantedperiod(a6),n_period(a6)
                clr.w   n_wantedperiod(a6)

TonePortaSetPer:move.w  n_period(a6),d2
                move.b  n_glissfunk(a6),d0
                and.b   #$0f,d0
                beq.s   GlissSkip
                moveq   #0,d0
                move.b  n_finetune(a6),d0
                mulu    #37*2,d0
                lea     PeriodTable(pc),a0
                adda.l  d0,a0
                moveq   #0,d0
GlissLoop:      cmp.w   0(a0,d0.w),d2
                bhs.s   GlissFound
                addq.w  #2,d0
                cmp.w   #37*2,d0
                blo.s   GlissLoop
                moveq   #35*2,d0
GlissFound:     move.w  0(a0,d0.w),d2
GlissSkip:      move.w  d2,SampPer(a5)        ;Set period
                rts

Vibrato:        move.b  n_cmdlo(a6),d0
                beq.s   Vibrato2
                move.b  n_vibratocmd(a6),d2
                and.b   #$0f,d0
                beq.s   vibskip
                and.b   #$f0,d2
                or.b    d0,d2
vibskip:        move.b  n_cmdlo(a6),d0
                and.b   #$f0,d0
                beq.s   vibskip2
                and.b   #$0f,d2
                or.b    d0,d2
vibskip2:       move.b  d2,n_vibratocmd(a6)
Vibrato2:       move.l  a4,-(sp)
                move.b  n_vibratopos(a6),d0
                lea     VibratoTable(pc),a4
                lsr.w   #2,d0
                and.w   #$1f,d0
                moveq   #0,d2
                move.b  n_wavecontrol(a6),d2
                and.b   #$03,d2
                beq.s   vib_sine
                lsl.b   #3,d0
                cmp.b   #1,d2
                beq.s   vib_rampdown
                move.b  #255,d2
                bra.s   vib_set
vib_rampdown:   tst.b   n_vibratopos(a6)
                bpl.s   vib_rampdown2
                move.b  #255,d2
                sub.b   d0,d2
                bra.s   vib_set

vib_rampdown2:  move.b  d0,d2
                bra.s   vib_set

vib_sine:       move.b  0(a4,d0.w),d2
vib_set:        move.b  n_vibratocmd(a6),d0
                and.w   #15,d0
                mulu    d0,d2
                lsr.w   #7,d2
                move.w  n_period(a6),d0
                tst.b   n_vibratopos(a6)
                bmi.s   VibratoNeg
                add.w   d2,d0
                bra.s   Vibrato3

VibratoNeg:     sub.w   d2,d0
Vibrato3:       move.w  d0,SampPer(a5)
                move.b  n_vibratocmd(a6),d0
                lsr.w   #2,d0
                and.w   #$3c,d0
                add.b   d0,n_vibratopos(a6)
                movea.l (sp)+,a4
                rts

TonePlusVolSlide:
                bsr     TonePortNoChange
                bra     VolumeSlide

VibratoPlusVolSlide:
                bsr.s   Vibrato2
                bra     VolumeSlide

Tremolo:        move.l  a4,-(sp)
                move.b  n_cmdlo(a6),d0
                beq.s   Tremolo2
                move.b  n_tremolocmd(a6),d2
                and.b   #$0f,d0
                beq.s   treskip
                and.b   #$f0,d2
                or.b    d0,d2
treskip:        move.b  n_cmdlo(a6),d0
                and.b   #$f0,d0
                beq.s   treskip2
                and.b   #$0f,d2
                or.b    d0,d2
treskip2:       move.b  d2,n_tremolocmd(a6)
Tremolo2:       move.b  n_tremolopos(a6),d0
                lea     VibratoTable(pc),a4
                lsr.w   #2,d0
                and.w   #$1f,d0
                moveq   #0,d2
                move.b  n_wavecontrol(a6),d2
                lsr.b   #4,d2
                and.b   #$03,d2
                beq.s   tre_sine
                lsl.b   #3,d0
                cmp.b   #1,d2
                beq.s   tre_rampdown
                move.b  #255,d2
                bra.s   tre_set

tre_rampdown:   tst.b   n_vibratopos(a6)
                bpl.s   tre_rampdown2
                move.b  #255,d2
                sub.b   d0,d2
                bra.s   tre_set

tre_rampdown2:  move.b  d0,d2
                bra.s   tre_set

tre_sine:       move.b  0(a4,d0.w),d2
tre_set:        move.b  n_tremolocmd(a6),d0
                and.w   #15,d0
                mulu    d0,d2
                lsr.w   #6,d2
                moveq   #0,d0
                move.b  n_volume(a6),d0
                tst.b   n_tremolopos(a6)
                bmi.s   TremoloNeg
                add.w   d2,d0
                bra.s   Tremolo3

TremoloNeg:     sub.w   d2,d0
Tremolo3:       bpl.s   TremoloSkip
                clr.w   d0
TremoloSkip:    cmp.w   #$40,d0
                bls.s   TremoloOk
                move.w  #$40,d0
TremoloOk:      move.w  d0,SampVol(a5)
                move.b  n_tremolocmd(a6),d0
                lsr.w   #2,d0
                and.w   #$3c,d0
                add.b   d0,n_tremolopos(a6)
                movea.l (sp)+,a4
                addq.l  #4,sp
                rts

SampleOffset:   moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                beq.s   sononew
                move.b  d0,n_sampleoffset(a6)
sononew:        move.b  n_sampleoffset(a6),d0
                lsl.w   #7,d0
                cmp.w   n_length(a6),d0
                bge.s   sofskip
                sub.w   d0,n_length(a6)
                lsl.w   #1,d0
                add.l   d0,n_start(a6)
                rts
sofskip:        move.w  #1,n_length(a6)
                rts

VolumeSlide:    moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                lsr.b   #4,d0
                tst.b   d0
                beq.s   VolSlideDown
VolSlideUp:     add.b   d0,n_volume(a6)
                cmpi.b  #$40,n_volume(a6)
                bmi.s   vsuskip
                move.b  #$40,n_volume(a6)
vsuskip:        move.b  n_volume(a6),d0
                rts

VolSlideDown:   moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
VolSlideDown2:  sub.b   d0,n_volume(a6)
                bpl.s   vsdskip
                clr.b   n_volume(a6)
vsdskip:        move.b  n_volume(a6),d0
                rts

PositionJump:   moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                subq.b  #1,d0
                move.w  d0,SongPosition
pj2:            clr.b   PBreakPosition
                st      PosJumpAssert
                rts

VolumeChange:   moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                cmp.b   #$40,d0
                bls.s   VolumeOk
                moveq   #$40,d0
VolumeOk:       move.b  d0,n_volume(a6)
                rts

PatternBreak:   moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                move.l  d0,d2
                lsr.b   #4,d0				;BCD->HEX
                mulu    #10,d0
                and.b   #$0f,d2
                add.b   d2,d0
                cmp.b   #63,d0
                bhi.s   pj2					;>63
                move.b  d0,PBreakPosition
                st      PosJumpAssert
                rts

SetSpeed:       move.b  3(a6),d0
                and.w   #$ff,d0
                beq.s   SpeedNull
                cmp.w	#$20,d0
                bcc.s	SetExSpeed		;>=$20 ist extented
normspd:        clr.w   Counter
                move.w  d0,CurrSpeed
SpeedNull:      rts

; ab >= 32 wird der Speed als bpm interpretiert
; wenn extended Speed benutzt wird, muû Speed = 6 sein, sonst
; wird das ExtendedSpeed falsch berechnet
; 1 bpm = 4 Ticks pro Minute
; wenn Speed gleich Default ( 6 ) ist, wird mit 125 bpm gespielt
; 1 / 6 * 20ms = 8,333 Hz,  8,333 Hz * 60 / 4 = 125 bpm
; ExtSpeed =  PlayFreq * 2.5 / bpm


SetExSpeed:		move.l	PlayFreq2_5(pc),d2
				divu	d0,d2
				move.w	d2,ExtSpeed
				rts
				
CheckMoreEffects:
                move.b  2(a6),d0
                and.b   #$0f,d0
                cmp.b   #$09,d0
                beq     SampleOffset
                cmp.b   #$0b,d0
                beq     PositionJump
                cmp.b   #$0d,d0
                beq.s   PatternBreak
                cmp.b   #$0e,d0
                beq.s   ECommands
                cmp.b   #$0f,d0
                beq.s   SetSpeed
                cmp.b   #$0c,d0
                beq     VolumeChange
                bra     PerNop

ECommands:      move.b  n_cmdlo(a6),d0
                and.b   #$f0,d0
                lsr.b   #4,d0
                beq.s   FilterOnOff
                cmp.b   #1,d0
                beq     FinePortaUp
                cmp.b   #2,d0
                beq     FinePortaDown
                cmp.b   #3,d0
                beq.s   SetGlissControl
                cmp.b   #4,d0
                beq     SetVibratoControl
                cmp.b   #5,d0
                beq     SetFineTune
                cmp.b   #6,d0
                beq     JumpLoop
                cmp.b   #7,d0
                beq     SetTremoloControl
                cmp.b   #8,d0
                beq     KarplusStrong
                cmp.b   #$0e,d0
                beq     PatternDelay
                cmp.b   #9,d0
                beq     RetrigNote
                cmp.b   #$0a,d0
                beq     VolumeFineUp
                cmp.b   #$0b,d0
                beq     VolumeFineDown
                cmp.b   #$0c,d0
                beq     NoteCut
                cmp.b   #$0d,d0
                beq     NoteDelay
                cmp.b   #$0f,d0
                beq     FunkIt
                rts

FilterOnOff:    move.b  n_cmdlo(a6),d0
                and.b   #1,d0
                asl.b   #1,d0
;                andi.b  #$fd,$bfe001
;                or.b    d0,$bfe001
                rts

SetGlissControl:
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                andi.b  #$f0,n_glissfunk(a6)
                or.b    d0,n_glissfunk(a6)
                rts

SetVibratoControl:
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                andi.b  #$f0,n_wavecontrol(a6)
                or.b    d0,n_wavecontrol(a6)
                rts

SetFineTune:    move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                move.b  d0,n_finetune(a6)
                rts

JumpLoop:       tst.w   Counter
                bne     Return
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                beq.s   SetLoop
                tst.b   n_loopcount(a6)
                beq.s   jumpcnt
                subi.b  #1,n_loopcount(a6)
                beq     Return
jmploop:        move.b  n_pattpos(a6),PBreakPosition
                st      PBreakFlag
                rts

jumpcnt:        move.b  d0,n_loopcount(a6)
                bra.s   jmploop

SetLoop:        move.w  PatternPosition,d0
                lsr.l   #4,d0				;/16
                and.b   #63,d0
                move.b  d0,n_pattpos(a6)
                rts

SetTremoloControl:
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                lsl.b   #4,d0
                andi.b  #$0f,n_wavecontrol(a6)
                or.b    d0,n_wavecontrol(a6)
                rts

;-------------- so ne Art Tiefpass, es wird der Mittelwert zwischen --
;-------------- 2 jeweils aufeinanderfolgenden Bytes gebildet --------

KarplusStrong:  movem.l d1-d2/a0-a1,-(sp)
                movea.l n_loopstart(a6),a0
                movea.l a0,a1
                move.w  n_replen(a6),d0
                add.w   d0,d0
                subq.w  #2,d0
karplop:        move.b  (a0),d1
                ext.w   d1
                move.b  1(a0),d2
                ext.w   d2
                add.w   d1,d2
                asr.w   #1,d2
                move.b  d2,(a0)+
                dbra    d0,karplop
                move.b  (a0),d1
                ext.w   d1
                move.b  (a1),d2
                ext.w   d2
                add.w   d1,d2
                asr.w   #1,d2
                move.b  d2,(a0)
                movem.l (sp)+,d1-d2/a0-a1
                rts

;-------------- Note wird mehrmals gespielt --------------------------

RetrigNote:     move.l  d1,-(sp)
                moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                beq     rtnend					;nix tun
                move.w  Counter,d1
                bne.s   rtnskp					;Counter > 0
                move.w  n_note(a6),d1
                and.w   #$0fff,d1				;Note da ?
                bne     rtnend					;ja, kein retrigg
                move.w  Counter,d1
rtnskp:         ext.l	d1
				divu    d0,d1
                swap    d1
                tst.w   d1
                bne     rtnend

DoRetrg:        clr.l	SampPtrFrac(a5)
                move.l  n_start(a6),d0 			;Set sampledata pointer
				move.l	d0,SampPtr(a5)
				moveq	#0,d1
                move.w  n_length(a6),d1
                add.l	d1,d1
                add.l	d1,d0
                move.l	d0,SampEnd(a5)
                move.w  n_period(a6),SampPer(a5)
                move.l  n_loopstart(a6),RepStart(a5)
				moveq	#0,d0
                move.w  n_replen(a6),d0
                add.l	d0,d0
		        move.l	d0,RepLen(a5)
rtnend:         move.l  (sp)+,d1
                rts

VolumeFineUp:   tst.w   Counter
                bne     Return
                moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                bra     VolSlideUp

VolumeFineDown: tst.w   Counter
                bne     Return
                moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                bra     VolSlideDown2

NoteCut:        moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                cmp.w   Counter,d0
                bne     Return
                clr.b   n_volume(a6)
                rts

NoteDelay:      moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                cmp.w   Counter,d0
                bne     Return
                move.w  (a6),d0
                and.w   #$0fff,d0
                beq     Return
                move.l  d1,-(sp)
                bra     DoRetrg

PatternDelay:   tst.w   Counter
                bne     Return
                moveq   #0,d0
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                tst.b   PattDelayTime2
                bne     Return
                addq.b  #1,d0
                move.b  d0,PattDelayTime
                rts

FunkIt:         tst.w   Counter
                bne     Return
                move.b  n_cmdlo(a6),d0
                and.b   #$0f,d0
                lsl.b   #4,d0
                andi.b  #$0f,n_glissfunk(a6)
                or.b    d0,n_glissfunk(a6)
                tst.b   d0
                beq     Return
UpdateFunk:     movem.l d1/a0,-(sp)
                moveq   #0,d0
                move.b  n_glissfunk(a6),d0
                lsr.b   #4,d0
                beq.s   funkend
                lea     FunkTable(pc),a0
                move.b  0(a0,d0.w),d0
                add.b   d0,n_funkoffset(a6)
                btst    #7,n_funkoffset(a6)
                beq.s   funkend
                clr.b   n_funkoffset(a6)
                move.l  n_loopstart(a6),d0
                moveq   #0,d1
                move.w  n_replen(a6),d1
                add.l   d1,d0
                add.l   d1,d0
                movea.l n_wavestart(a6),a0
                addq.l  #1,a0
                cmpa.l  d0,a0
                blo.s   funkok
                movea.l n_loopstart(a6),a0
funkok:         move.l  a0,n_wavestart(a6)
                moveq   #-1,d0
                sub.b   (a0),d0
                move.b  d0,(a0)
funkend:        movem.l (sp)+,d1/a0
                rts

InitPlayer:		movem.l	d0/a0-a1,-(sp)
				lea		audchan1temp(pc),a0
				lea		InitEnd(pc),a1
InitPlayer1:	clr.b	(a0)+
				cmp.l	a0,a1
				bne.s	InitPlayer1
				lea		audchan1temp(pc),a0
				lea		20(a0),a0
				moveq	#1,d0
InitPlayer2:	move.b	d0,(a0)				;Setzte Channel-Nr-Bit
				add.w	#44,a0
				lsl.b	#1,d0
				bcc.s	InitPlayer2
				move.w	#6,CurrSpeed
				move.b	#%11111111,ActiveChannels
				movem.l	(sp)+,d0/a0-a1
				rts
				
				data
				
				
FunkTable:      dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

VibratoTable:   dc.b 0,24,49,74,97,120,141,161
                dc.b 180,197,212,224,235,244,250,253
                dc.b 255,253,250,244,235,224,212,197
                dc.b 180,161,141,120,97,74,49,24

dummy:			dc.w 0

PeriodTable:
; -> Tuning 0
                dc.w 856,808,762,720,678,640,604,570,538,508,480,453
                dc.w 428,404,381,360,339,320,302,285,269,254,240,226
                dc.w 214,202,190,180,170,160,151,143,135,127,120,113,0
; -> Tuning 1
                dc.w 850,802,757,715,674,637,601,567,535,505,477,450
                dc.w 425,401,379,357,337,318,300,284,268,253,239,225
                dc.w 213,201,189,179,169,159,150,142,134,126,119,113,0
; -> Tuning 2
                dc.w 844,796,752,709,670,632,597,563,532,502,474,447
                dc.w 422,398,376,355,335,316,298,282,266,251,237,224
                dc.w 211,199,188,177,167,158,149,141,133,125,118,112,0
; -> Tuning 3
                dc.w 838,791,746,704,665,628,592,559,528,498,470,444
                dc.w 419,395,373,352,332,314,296,280,264,249,235,222
                dc.w 209,198,187,176,166,157,148,140,132,125,118,111,0
; -> Tuning 4
                dc.w 832,785,741,699,660,623,588,555,524,495,467,441
                dc.w 416,392,370,350,330,312,294,278,262,247,233,220
                dc.w 208,196,185,175,165,156,147,139,131,124,117,110,0
; -> Tuning 5
                dc.w 826,779,736,694,655,619,584,551,520,491,463,437
                dc.w 413,390,368,347,328,309,292,276,260,245,232,219
                dc.w 206,195,184,174,164,155,146,138,130,123,116,109,0
; -> Tuning 6
                dc.w 820,774,730,689,651,614,580,547,516,487,460,434
                dc.w 410,387,365,345,325,307,290,274,258,244,230,217
                dc.w 205,193,183,172,163,154,145,137,129,122,115,109,0
; -> Tuning 7
                dc.w 814,768,725,684,646,610,575,543,513,484,457,431
                dc.w 407,384,363,342,323,305,288,272,256,242,228,216
                dc.w 204,192,181,171,161,152,144,136,128,121,114,108,0
; -> Tuning -8
                dc.w 907,856,808,762,720,678,640,604,570,538,508,480
                dc.w 453,428,404,381,360,339,320,302,285,269,254,240
                dc.w 226,214,202,190,180,170,160,151,143,135,127,120,0
; -> Tuning -7
                dc.w 900,850,802,757,715,675,636,601,567,535,505,477
                dc.w 450,425,401,379,357,337,318,300,284,268,253,238
                dc.w 225,212,200,189,179,169,159,150,142,134,126,119,0
; -> Tuning -6
                dc.w 894,844,796,752,709,670,632,597,563,532,502,474
                dc.w 447,422,398,376,355,335,316,298,282,266,251,237
                dc.w 223,211,199,188,177,167,158,149,141,133,125,118,0
; -> Tuning -5
                dc.w 887,838,791,746,704,665,628,592,559,528,498,470
                dc.w 444,419,395,373,352,332,314,296,280,264,249,235
                dc.w 222,209,198,187,176,166,157,148,140,132,125,118,0
; -> Tuning -4
                dc.w 881,832,785,741,699,660,623,588,555,524,494,467
                dc.w 441,416,392,370,350,330,312,294,278,262,247,233
                dc.w 220,208,196,185,175,165,156,147,139,131,123,117,0
; -> Tuning -3
                dc.w 875,826,779,736,694,655,619,584,551,520,491,463
                dc.w 437,413,390,368,347,328,309,292,276,260,245,232
                dc.w 219,206,195,184,174,164,155,146,138,130,123,116,0
; -> Tuning -2
                dc.w 868,820,774,730,689,651,614,580,547,516,487,460
                dc.w 434,410,387,365,345,325,307,290,274,258,244,230
                dc.w 217,205,193,183,172,163,154,145,137,129,122,115,0
; -> Tuning -1
                dc.w 862,814,768,725,684,646,610,575,543,513,484,457
                dc.w 431,407,384,363,342,323,305,288,272,256,242,228
                dc.w 216,203,192,181,171,161,152,144,136,128,121,114,0

				even

audchan1temp:   dc.l 0,0,0,0,0,$010000,0,0,0,0,0
audchan2temp:   dc.l 0,0,0,0,0,$020000,0,0,0,0,0
audchan3temp:   dc.l 0,0,0,0,0,$040000,0,0,0,0,0
audchan4temp:   dc.l 0,0,0,0,0,$080000,0,0,0,0,0
audchan5temp:   dc.l 0,0,0,0,0,$100000,0,0,0,0,0
audchan6temp:   dc.l 0,0,0,0,0,$200000,0,0,0,0,0
audchan7temp:   dc.l 0,0,0,0,0,$400000,0,0,0,0,0
audchan8temp:   dc.l 0,0,0,0,0,$800000,0,0,0,0,0
			

PlayInfos:
Counter:        dc.w 0
CurrSpeed:      dc.w 0
PatternPosition:dc.w 0			;0...1023
SongPosition:   dc.w 0			;
ActiveChannels: dc.b 0
PBreakPosition: dc.b 0
PosJumpAssert:  dc.b 0
PBreakFlag:     dc.b 0
LowMask:        dc.b 0
PattDelayTime:  dc.b 0
PattDelayTime2: dc.b 0
InitEnd:
				even


				