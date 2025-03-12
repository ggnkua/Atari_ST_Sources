;DSP-MOD-Player
;Coderight by bITmASTER of TCE

				include "DSPMOD.INC"
				include "REGISTER.H"
				include	"dspmods.h"
				
dsp_host		equ $ffffa200
color0			equ $ffff9800


TEST			equ 1  			;DPS-Calc-End Interrupt-Raster
; Achtung, auch in DSP-Sourcecode TEST entsprechend setzen !!
HZ50			equ 0			;VBL-Frequenz = 50 Hz
POSTEST			equ 0			;Vergleich FracPos CPU <-> DSP
EXTSPEED		equ 1			;use ext. Speed ( 0 nur bei 50 Hz mîglich )
FASTSEND		equ 1 			;schneller Send-Routine
NOPS			equ	0			;Anzahl NOP's bei ParameterÅbergabe
HOSTTEST		equ	1			;Teste Host bevor Transfer

				macro	HostEmpty
				local 	wait_empty
				
				if HOSTTEST
wait_empty:		btst	#1,-4(a5)
				beq.s	wait_empty
				endif
				
				endm
					
				macro	DEBUG val
				movem.l	d0/a0,-(sp)
				lea		debug_buf,a0
				move.w	debug_idx,d0
;				move.w	val,(a0,d0.w*2)
;				addq.w	#1,d0
				move.w	d0,debug_idx
				movem.l	(sp)+,d0/a0
				endm
				
							
				import load_dsp_obj, dsp_buffer, dsp_len
				import Player, InitPlayer, PlayInfos
				import PlayTime, flag
				import date
				import debug_buf, debug_idx
				export sample_starts, SampSets
				export cur, min, max, debug, ExtSpeed
				export ModSongLen, ModPatData, ModSamples, ModTracks
				export DspFlags, DspTracks, ModType, PlayFlag
				export PlayFreq2_5
				export mod
				export fx_test

				export init, off
				export PlayerOn, PlayerOff

				if		TEST
				import	pic
				export 	dsp_debug
				endif
				
				if		POSTEST
				export	FracPos
				endif
				
start:			bra.w	init
				bra.w	off
				bra.w	PlayerOn
				bra.w	PlayerOff
				bra.w	PlayMusic
				bra.w	PlayTime
				bra.w	ModType
				bra.w	fx
				dc.b	0
DspFlags:		dc.b	0
SurroundDelay:	dc.w	$800
DspTracks:		dc.w	4

				dc.l	PlayInfos
				dc.l	SampSets
				bra.w	LoadP56
				bra.w	SetDspExec
				
UserDspVbl:		dc.l	0

				dc.b	"*DSP-Protracker 4.0 Replay *"
				dc.b	"*coderight by bITmASTER    *"
				dc.b	"*bITmASTER@syncscroller.net*"
				even


;---------------------------------------------------------------------
; lÑdt User-DSP-Programm (*.P56)
; in: d0: Size
;     a0: Zeiger auf P56
;---------------------------------------------------------------------

LoadP56:		lea		dsp_host.w,a1
LoadP56_1:		btst	#1,2(a1)
				beq.s	LoadP56_1
				move.b	(a0)+,5(a1)
				move.w	(a0)+,6(a1)
				subq.l	#1,d0
				bne.s	LoadP56_1
LoadP56_2:		btst	#1,2(a1)
				beq.s	LoadP56_2
				move.b	#-1,5(a1)			;fertig
				move.w	#-1,6(a1)
				rts

;---------------------------------------------------------------------
; setze exec-Adresse
; in: d0: Adr
;---------------------------------------------------------------------
				
SetDspExec:		lea		dsp_host.w,a1
SetDspExec1:	btst	#1,2(a1)
				beq.s	SetDspExec1
				move.l	d0,4(a1)
				rts
								
				

;--------------------------------------------------------------------
; init
; d0.w = replay frequency
;--------------------------------------------------------------------

init:			movem.l	d0-a6,-(sp)
			if		TEST=0
				move.l	d0,-(sp)
				bsr		reloziere			;muû als 1. kommen !!!!
				bsr		load_dsp_obj		;DSP-Programm starten
				move.l	(sp)+,d0
			endif

				move.w	d0,d7				;ReplayFreq
				bsr		calc_inc			;Inc-Tabelle berechnen
				move.w	DefaultSpeed(pc),d0
				move.w	d0,ExtSpeed
				move.w	d0,ExtSpeedCount
				clr.b	PlayFlag
				bsr		Silence

				lea		$ffff8930.w,a0
				lea		SaveArea,a1
				move.l	(a0),(a1)+			;Mpx
				move.w	4(a0),(a1)+			;OldPreScale
				move.w	6(a0),(a1)+			;OldAdder
				move.l	8(a0),(a1)+			;OldCodec, LautstÑrke usw
				move.l	$3fc.w,(a1)+		;Host Interrupt
				move.b	$ffffa200.w,(a1)+	;HI Interrupt Control
				move.b	$ffffa203.w,(a1)+	;HI Interrupt Vector
			

				move.l	#$00902000,d0		;DSP->CODEC
				move.w	#$0101,d1			;interner Takt / 2
				cmp.w	#49170,d7
				beq.s	PlayFreqIntern
				move.w	#$0102,d1			;interner Takt / 3
				cmp.w	#32780,d7
				beq.s	PlayFreqIntern
				move.l	#$60b02000,d0		;DSP->Codec, externer Takt
				
PlayFreqIntern:	move.l	d0,(a0)				;Matrix
				move.w	d1,4(a0)			;setze Vorteiler
				move.w	#2,6(a0)			;Adder: only Mux

				move	sr,d0
				move	#$2700,sr
				move.b	#$ff,$ffffa203.w	;Interruptvector 255
				move.l	#DspVbl,$3fc.w
				move	d0,sr
				
				if		TEST & HZ50
				move.w	#1259,$ffff82a2.w	;50 Hz
				move.w	#$480,$ffff82ac.w
				endif

				if		TEST
				move.w	#2,-(sp)
				trap	#14
				addq.l	#2,sp
				move.l	d0,a0
				add.w	#XRES/8-8,a0
				lea		pic+140,a1
				move.w	#480-1,d0
copy_pic:		move.l	(a1)+,(a0)
				move.l	(a1)+,4(a0)
				add.w	#XRES/8,a0
				dbra	d0,copy_pic

				move	sr,d0
				move	#$2700,sr
				move.l	color0.w,old_color
				lea		TSaveArea,a0
				move.l	$70.w,(a0)+
				move.l	timer_int.w,(a0)+
				move.b	aer.w,(a0)+
				move.b	tbcr.w,(a0)+
				move.b	tbdr.w,(a0)+
				clr.b	tbcr.w					;Timer Stop
				bset	#3,aer.w
				move.l	#TimerBInt,timer_int.w
				bset	#0,imra.w
				bset	#0,iera.w
				move.l	#VblInt,$70.w
				move	d0,sr
				endif

				movem.l	(sp)+,d0-a6
				lea		date,a0					;Datum
				rts


;---------------------------------------------------------------------
; deinstalliert DSPMOD
;---------------------------------------------------------------------

off:			movem.l	d0-a6,-(sp)

				lea		$ffff8930.w,a0
				lea		SaveArea,a1
				move.l	(a1)+,(a0)
				move.w	(a1)+,4(a0)
				move.w	(a1)+,6(a0)
				move.l	(a1)+,8(a0)

				move	sr,d0
				move	#$2700,sr
				move.l	(a1)+,$3fc.w
				move.b	(a1)+,$ffffa200.w	;HI Interrupt Control
				move.b	(a1)+,$ffffa203.w	;HI Interrupt Vector
				move	d0,sr


			if		TEST & HZ50
				move.w	#1049,$ffff82a2.w		;back to 60 Hz
				move.w	#$415,$ffff82ac.w
			endif

			if		TEST
				move	sr,d0
				move	#$2700,sr
				bclr	#0,iera.w
				bclr	#0,imra.w
				clr.b	$ffffa200.w			;Host-Int aus
				lea		TSaveArea,a0
				move.l	(a0)+,$70.w
				move.l	(a0)+,timer_int.w
				move.b	(a0)+,aer.w
				move.b	(a0)+,tbcr.w
				move.b	(a0)+,tbdr.w

				move.l	old_color,color0.w
				move	d0,sr
			endif
				movem.l	(sp)+,d0-a6
				rts

;---------------------------------------------------------------------
; startet Abspielen eines MOD's
;---------------------------------------------------------------------


PlayerOn:		movem.l	d0-a6,-(sp)
				move.l	a0,mod
				lea		SampSets(pc),a0
				moveq	#8-1,d0
SetMainVol:		move.w	(a1)+,SampMainVol(a0)
				add.w	#SizeOfSamp_,a0
				dbra	d0,SetMainVol
				bsr		InitPlayer
				bsr		prepare_mod
				move.w	DefaultSpeed(pc),d0
				move.w	d0,ExtSpeed
				move.w	d0,ExtSpeedCount
				st		PlayFlag
				movem.l	(sp)+,d0-a6
				rts

;---------------------------------------------------------------------
; stopt Abspielen eines MOD's
;---------------------------------------------------------------------


PlayerOff:		movem.l	d0-a6,-(sp)
				clr.b	PlayFlag
				bsr		Silence
				movem.l	(sp)+,d0-a6
				rts

;---------------------------------------------------------------------
;DSP - VBL
;---------------------------------------------------------------------				

DspVbl:			movem.l	d0/a0,-(sp)
				move.w	$ffffa206.w,d0			;read
				clr.b	$ffffa200.w				;Host-Int aus
				move.l	UserDspVbl,a0
				tst.l	a0
				beq.s	NoUserDspVbl
				jsr		(a0)
NoUserDspVbl:
				

				if 		TEST
				move.w	d0,dsp_debug
				
				if		POSTEST
				movem.l	d0/d1/a0/a1,-(sp)
				move.w	DspTracks,d0
				subq.w	#1,d0
				lea		FracPos,a0
.m1:			btst	#0,$ffffa202.w			;auf DSP warten
				beq.s	.m1
				move.w	$ffffa205.w,(a0)+
				move.b	$ffffa207.w,(a0)+
				clr.b	(a0)+
				dbra	d0,.m1

				lea		FracPos,a0
				lea		SampSets,a1
				move.w	DspTracks,d0
				subq.w	#1,d0
m2:				move.l	(a0)+,d1
				lsl.l	#1,d1
				cmp.l	SampPtrFrac(a1),d1
				beq.s	m3
error:			move.w	#2,flag
				nop
m3:				add.w	#SizeOfSamp_,a1	;nÑchster Kanal
				dbra	d0,m2
				movem.l	(sp)+,d0/d1/a0/a1
				endif

				move.l	#-1,color0.w
				endif
				
				movem.l	(sp)+,d0/a0
				rte


				if		TEST
				
VblInt:			move.b	#16,tbdr.w
				move.b	#8,tbcr.w
				move.l	TSaveArea,-(sp)
				rts

TimerBInt:		bclr 	#0,$fffffa0f.w			;um Interrupts von
				move.w	#$2300,sr				;Tastatur/Maus zuzulassen
				clr.b	tbcr.w					;Timer Stop
				movem.l	d0-a6,-(sp)
				bsr.s	PlayMusic
				movem.l	(sp)+,d0-a6
				rte
				endif

PlayMusic:		add.w	#1,IntCount
;				DEBUG	IntCount
				
				if	TEST
				move.l	#$ff3f00ff,color0.w		;lila
				endif
		
				lea		dsp_host.w+6,a5		;TXM

				move.b	#$92,-5(a5)			;Host-Command

				move.b	DspFlags,-1(a5)		;DSP-Flags
				move.w	SurroundDelay,(a5)	;write SurroundDelay to DSP

				HostEmpty
				move.w	DspTracks,(a5)		;Anzahl DSP-Tracks

				moveq	#0,d0
WaitBufSize:	btst	#0,-4(a5)			;current bufsize
				beq.s	WaitBufSize
				move.w	(a5),bufsize		;RXM & RXL

				if TEST
				move.w	bufsize,d0		;get bufsize min/max
				move.w	d0,cur
				cmp.w	min,d0
				bcc.s	no_min
				move.w	d0,min
no_min:			cmp.w	max,d0
				bcs.s	no_max
				move.w	d0,max
no_max:

				clr.w	debug
				endif

				
SendPart:		move.w	bufsize(pc),d0
				cmp.w	ExtSpeedCount(pc),d0

			if EXTSPEED
				bhi		SendCount					;ExtSpeedCount < bufsize
			endif
				move.w	d0,worksize
;				DEBUG	#11111
				bsr		SampToDSP

				HostEmpty
				move.l	#1,-2(a5)		;alle Parts durch

				move.w	bufsize(pc),d0
				sub.w	d0,ExtSpeedCount
				
			if EXTSPEED
				bne.s	fertig
			endif
				
				bsr		Player
				move.w	ExtSpeed(pc),ExtSpeedCount
fertig:			
				if		TEST
				move.l	#$ffff0000,color0.w
				endif
				
;				DEBUG	#-12345

				move.b	#1,$ffffa200.w		;Host-Int an, fÅr DspVbl

				rts
								
SendCount:		move.w	ExtSpeedCount(pc),d0
				move.w	d0,worksize
				sub.w	d0,bufsize

;				DEBUG	#22222
				bsr.s	SampToDSP
				bsr		Player

				move.w	ExtSpeed(pc),ExtSpeedCount
				bra		SendPart							

;---------------------------------------------------------------------
; sendet fÅr worksize * SampPer Bytes Sampledaten
;---------------------------------------------------------------------
;Register:
; d0: fractional worksize * SampPer
; d1: SampPtr
; d2: SampEnd
; d3: RepStart
; d4: RepLen
; d5: integer    worksize * SampPer
; d6: DspTracks-dbra
; d7: Anzahl Bytes fÅr SendBlock
; a0: Zeiger auf IncTab
; a1: Zeiger auf SampSets
; a2: Zeiger auf Quelle fÅr SendBlock
; a3: Zeiger auf Inc-Wert in IncTab
; a4: Grîûe des Bereiches, der mit Samples gefÅllt werden muû ( + 3 Sicherheit & Interpolation )
; a5: Zeiger auf Host-Mid-Byte
; a6: SampEnd-SampPtr = Diff
						
SampToDSP:		if TEST
				move.l	#$ff000000,color0.w
				endif

;	DEBUG worksize

				lea		IncTab(pc),a0
				lea		SampSets(pc),a1		
				lea		dsp_host.w+6,a5		;TXM

				HostEmpty
				clr.l	-2(a5)				;es folgt ein Samplepart

				move.w	DspTracks,d6
				subq.w	#1,d6
	
SampToDSP1:	

;-------------- Parameters to DSP ----------------------------------------
	
				move.w	SampPer(a1),d0			;Periode
				lea		(a0,d0.w*4),a3			;Zeiger in IncTable

				clr.b	-1(a5)
				move.w	worksize(pc),(a5)		;Work-Size
				
				move.b	SampVol+1(a1),-1(a5)	;Volume -> DSP
				clr.w	(a5)

				move.w	SampMainVol(a1),-1(a5)	;MainVol -> DSP
				clr.b	1(a5)					;TXL

				move.b	SampPos+1(a1),-1(a5)	;StereoPos -> DSP
				clr.w	(a5)

				move.w	(a3),-1(a5)				;IncWert -> DSP, TXH / TXM
				move.b	2(a3),1(a5)				;TXL
									
				move.w	SampPtrFrac(a1),-1(a5)	;FracPos -> DSP
				move.b	SampPtrFrac+2(a1),1(a5)

;-------------

				move.l	(a3),d0					;read INC-Wert
				mulu.l	worksize_l(pc),d5:d0	;d5:PosInt, d0:PosFrac	
				move.l	d5,a4			
				addq.l	#3,a4					;Sicherheit
	
				movem.l	SampPtr(a1),d1-d4
				move.l	d2,a6			;SampleEnd
				sub.l	d1,a6			;SampEnd-SampPtr = Diff
				cmp.l	a6,a4			;BlocklÑnge <= Diff ?
				bls.s	NoRepeated		;BlocklÑnge <= Diff ( C v Z = 1 )
				sub.l	a6,a4			;BlocklÑnge -= Diff

;-------------- Sende von SampPtr bis SampEnd ( Diff ) --------------------

				move.w	a6,d7			;Size
				move.l	d1,a2			;SampPtr
				bsr		SendBlock		;sende d7 Bytes
				cmp.l	#2,d4			;Repeated ?
				beq.s	NoRepeatedEnd	;nein

;-------------- die restlichen Samples werden ab RepStart gesendet -----------

				cmp.l	d4,a4			;ReplLen > Rest ?
				bcs.s	SendRepPart		;ja
				move.l	d4,a4			;sende nur RepLen
SendRepPart:	move.w	a4,d7
				move.l	d3,a2			;ab RepStart
				bsr		SendBlock
				bra.s	SendDone

;-------------- 0-Bytes als Repeat-Block senden ----------------------

NoRepeatedEnd: 	HostEmpty
				clr.b	-1(a5)			;TXH
				move.w	#2,(a5)			;2 Bytes
				HostEmpty
				move.w	#0,(a5)
				HostEmpty
				move.w	#0,(a5)			;es mÅssen 2 Words gesendet werden
				bra.s	SendDone

;-------------- kein SampEnd erreicht -------------------------------------

NoRepeated:		move.w	a4,d7			;BlocklÑnge
				move.l	d1,a2			;SampPtr
				bsr		SendBlock		;sende Bytes
				HostEmpty
				clr.l	-2(a5)			;kein RepSample
				
SendDone:		rept	NOPS
				nop								;nop's sind notwendig !!
				endm


; calc new Sample-Pointer, d5=Anzahl der Samples

				add.l	d0,SampPtrFrac(a1)	;Fractional Pos
				addx.l	d5,d1				;SampPtr + gespielte Bytes
				move.l	d1,d0
				sub.l	d2,d0				;SampPtr-SampEnd
				bls.s	SampPtrOK			;SampPtr<=SampEnd
				cmp.l	#2,d4				;Repeated ?
				bne.s	CalcRep				;ja
				move.l	d2,d1				;nein SampPtr = SampEnd
				bra.s	SampPtrOK
CalcRep:		move.l	d3,d1				;SampPtr = RepStart
				divul.l	d4,d5:d0			;d0/Replen
				add.l	d5,d1				;SampPtr += Rest
SampPtrOK:		move.l	d1,SampPtr(a1)

				add.w	#SizeOfSamp_,a1	;nÑchster Kanal
				dbra	d6,SampToDSP1

				rts

xyz:			dc.w	0

;------------------------------------------------------------------------

SendBlock:	;	move.w	d6,xyz
;				add.w	#9001,xyz
;				DEBUG xyz
;				DEBUG d7
				HostEmpty
				clr.b	-1(a5)			;TXH
				move.w	d7,(a5)			;BlocklÑnge -> DSP
				beq.s	SendBlockZero	;0
.w_empty:		btst	#1,-4(a5)
				beq.s	.w_empty

			if FASTSEND = 0
				lsr.w	#1,d7			;/2
SendBlock1:		HostEmpty
				move.w	(a2)+,(a5)		;Samples zum DSP
				dbra	d7,SendBlock1	;durch dbra wir ein Word mehr gesendet
				rts
			else

;--- diese Sendroutine sollte schneller sein....

				move.w	d5,-(sp)
				moveq	#$1f,d5
				and.w	d7,d5			;mod 32
				lsr.w	#1,d5			;/2

				lsr.w	#5,d7			;/32
				beq		SendBlockRest
				subq.w	#1,d7			;wegen dbra

SendBlock2:		rept	16				;sende 32 Bytes
				move.w	(a2)+,(a5)		;Samples zum DSP
				endm
				dbra	d7,SendBlock2

SendBlockRest:	move.w	(a2)+,(a5)
				dbra	d5,SendBlockRest
				move.w	(sp)+,d5
				rts
			endif

SendBlockZero:	rts


;-------------- Handler fÅr Soundeffekte ---------------------------

fx:				movem.l	d0/a4,-(sp)
				lea		SampSets+4*SizeOfSamp_,a4
				mulu.w	#SizeOfSamp_,d0
				add.w	d0,a4
				move.l	a0,SampPtr(a4)		;aktuelle SamplePos
				move.l	a1,SampEnd(a4)		;Ende
				move.l	a2,RepStart(a4)
				move.l	a3,RepLen(a4)
				move.w	d1,SampPer(a4)
				move.w	d2,SampVol(a4)
				move.w	d3,SampPos(a4)
				clr.l	SampPtrFrac(a4)
				movem.l	(sp)+,d0/a4
				rts

				if		TEST
fx_test:		movem.l	d3-d7/a2-a6,-(sp)
				move.l	a0,a1
				add.l	d1,a1			;End
				clr.l	a2				;repstart
				move.w	#2,a3			;kein rep
				move.w	#400,d1			;per
				move.w	#64,d2			;vol
				move.w	#0,d3			;pos
				bsr.s	fx
				movem.l	(sp)+,d3-d7/a2-a6
				rts
				endif

prepare_mod:	move.l	mod,a0			;Modul
				lea		20+31*30(a0),a1	;ModSongLen
				lea		2+128+4(a1),a2	;ModPatData
				moveq	#31-1,d1		;ModSamples
				moveq	#1,d3			;Instr31
				bsr		ModType
				tst.w	d0				;Mod-Magic gefunden ?
				bne.s	prepare_mod1	;ja

				lea		20+15*30(a0),a1	;ModSongLen
				lea		2+128(a1),a2	;ModPatData
				moveq	#4,d0			;4 Tracks
				moveq	#15-1,d1		;ModSamples
				moveq	#0,d3

prepare_mod1:	move.l	a1,ModSongLen
				move.l	a2,ModPatData
				move.w	d0,ModTracks
				move.w	d0,DspTracks
				move.w	d1,ModSamples
				move.l	ModSongLen,a1
				move.l	a1,a2
				addq.l	#2,a1			;Tabelle der Pattern-Nr
				moveq	#128-1,d0		;die Tabelle ist 128 Bytes groû
				moveq	#0,d1			;die grîûte Pattern-Nr
max_patt_nr:	move.b	(a1)+,d2		;Pattern-Nr
				cmp.b	d2,d1			;grîûer als max-Nr ?
				bcc.s	max_patt_nr1	;nein
				move.b	d2,d1			;ja, neue max-Nr
max_patt_nr1:	dbra	d0,max_patt_nr

				cmp.b	1(a2),d1		;check Mod-Restart, Restart < max_patt_nr
				bcc.s	RestartOK
				clr.b	1(a2)			;Restart bei 0

RestartOK:		addq.w	#1,d1
				move.w	ModTracks,d0
				lsl.w	#8,d0			;1024/2048
				mulu.w	d0,d1			;1 Pattern belegt 1024 Bytes
				move.l	ModPatData,a1
				lea		(a1,d1.l),a1	;Adr. 1.Sample
				add.w	#20+22,a0
				lea		sample_starts,a2
				move.w	ModSamples,d0
GetSampStarts:	move.l	a1,(a2)+		;Startadresse speichern
				moveq	#0,d1
				move.w	(a0),d1			;SampleLength
				add.l	d1,d1			;*2
				add.l	d1,a1			;next SampleStart
				tst.w	6(a0)			;Repeat-Length = 0 ?
				bne.s	RepLenOK		;nein
				move.w	#1,6(a0)
RepLenOK:		tst.w	d3
				bne.s	repstartOK
				lsr.w	#1,4(a0)		;repstart/2, bei 15er Mods
repstartOK:		add.w	#30,a0
				dbra	d0,GetSampStarts
				rts

; in:  a0: Zeiger auf Mod
; out: d0: 0: kein ModMagic ( eventuell ist es ein altes 15er MOD )
;          t: Anzahl der Tracks ( 4 / 8 )


ModType:		movem.l	d1/a1,-(sp)
				lea		ModMagic(pc),a1
ModType1:		moveq	#0,d0
				move.l	(a1)+,d1
				beq.s	ModType2
				move.w	(a1)+,d0
				cmp.l	1080(a0),d1
				bne.s	ModType1
ModType2:		movem.l	(sp)+,d1/a1
				rts


ModMagic:		dc.b	"M.K.",0,4
				dc.b	"FLT4",0,4
				dc.b	"CD8 ",0,8
				dc.b	"CD81",0,8
				dc.b	"FA08",0,8
				dc.l	0


;-------------- Silence, set alle 8 KanÑle auf einen "leeren" Buffer ----

Silence:		lea		BlankSamp+2,a0
				lea		SampSets,a1
				lea		PosTab,a2
				moveq	#8-1,d0
InitSampSets:	move.l	a0,SampPtr(a1)
				move.l	a0,SampEnd(a1)
				clr.l	RepStart(a1)
				move.l	#2,RepLen(a1)
			if		POSTEST=0
				clr.l	SampPtrFrac(a1)
			endif
				move.w	#800,SampPer(a1)
				clr.w	SampVol(a1)
				clr.w	SampMainVol(a1)
				moveq	#0,d1
				move.b	(a2)+,d1
				move.w	d1,SampPos(a1)		;setze Stereoposition
				add.w	#SizeOfSamp_,a1
				dbra	d0,InitSampSets
				rts

;-------------- berechnet Increment-Tabelle ------------------------
;
; d0: Playfrequenz in Hz


calc_inc:		and.l	#$ffff,d0		;high-word = 0
				move.w	d0,d1
				mulu	#5,d1
				lsr.l	#1,d1			;*5/2
				move.l	d1,PlayFreq2_5	;PlayFreq * 2,5
				
				move.l	d0,d1
				divu	#50,d1
				move.w	d1,DefaultSpeed

				move.l	#$1b4f,d1
				move.l	#$4d000000,d2	;d1:d2 = 3579546 * 2^23
				divu.l	d0,d1:d2		;/ PlayFreq
				
				lea		IncTab,a0
				move.w	#80-1,d0
calc_inc1:		clr.l	(a0)+
				dbra	d0,calc_inc1

				move	#910-80-1,d0
				move.l	#80,d1
				moveq	#9,d3
calc_inc2:		move.l	d2,d4
				divu.l	d1,d4
				lsl.l	d3,d4			;23:9
				move.l	d4,(a0)+		;INC-Wert
				addq.l	#1,d1
				dbra	d0,calc_inc2
				rts

;-------------- beim 1.Aufruf relozieren -----------------------------

reloziere:      movem.l	d0-d1/a0-a2,-(sp)
				tst.b	relozier_flag(pc)
				bne.s	rel1			;ist schon reloziert
				lea		start-28(pc),a0
				move.l  2(a0),d0        ;Relozieren
                add.l   6(a0),d0
                add.l   14(a0),d0
                adda.l  #$1c,a0
                move.l  a0,d1
                movea.l a0,a1
                movea.l a1,a2
                adda.l  d0,a1
                move.l  (a1)+,d0
                adda.l  d0,a2
                add.l   d1,(a2)
                clr.l   d0
L000A:          move.b  (a1)+,d0
                beq     L000C
                cmp.b   #1,d0
                beq     L000B
                adda.l  d0,a2
                add.l   d1,(a2)
                bra     L000A
L000B:          adda.l  #$fe,a2
                bra     L000A
L000C:          lea		relozier_flag(pc),a0
				st		(a0)
rel1:			movem.l	(sp)+,d0-d1/a0-a2
				rts

				data

PosTab:			dc.b	-55,55,55,-55,-55,55,55,-55
				
BlankSamp:		dc.w	0
SaveArea:		ds.b	20

PlayFlag:		dc.b 	0
relozier_flag:	dc.b	0

PlayFreq2_5:	dc.l	0				;PlayFreq * 2,5
DefaultSpeed:	dc.w	0
ExtSpeed:		dc.w	0
ExtSpeedCount:	dc.w	0
bufsize:		ds.w 	1
worksize_l:		dc.w	0				;fÅr Long-Zugriff auf worksize
worksize:		ds.w	1
IntCount:		ds.w	1
mod:			ds.l 1
ModSongLen:		ds.l 1
ModPatData:		ds.l 1
ModSamples:		ds.w 1
ModTracks:		ds.w 1
sample_starts:	ds.l 31					;max 31 Instrumente
SampSets:		ds.b 8*SizeOfSamp_
IncTab:			ds.l 910
				

				if		TEST
old_color:		ds.l 1
TSaveArea:		ds.b 20
min:			dc.w	10000		;bufsize min / max
max:			dc.w	0
cur:			dc.w	0
debug:			dc.w	0
dsp_debug:		dc.w	0
				endif

				if		POSTEST
FracPos:		ds.l 8
				endif
