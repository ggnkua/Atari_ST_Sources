;DSP-MOD-Player
;Coderight by bITmASTER of TCE 
;V3.0

TEST		equ 1
POSTEST		equ 0					;uses r3

start		equ $40
PlayBufSize	equ 2*2*1024
HostBufSize	equ	1024

;---------- X: Memory --------------------------------------------------
host_buf1	equ	512					;Hostbuffer
host_buf2	equ 512+1*HostBufSize
host_buf3	equ 512+2*HostBufSize
host_buf4	equ 512+3*HostBufSize
host_buf5	equ	512+4*HostBufSize
host_buf6	equ	512+5*HostBufSize
host_buf7	equ	512+6*HostBufSize
host_buf8	equ	512+7*HostBufSize

;---------- Y: Memory ---------------------------------------------------

unpack_buf	equ $0400
play_buf	equ	$1000

;---------- X: und Y:Memory ---------------------------------------------

hall_buf	equ	$3000

;---------- Y:Memory ----------------------

			org	y:0

HallDelay	dc 0
Tracks		dc 0
CurBufSize	dc 0				;aktuelle Buffergroesse

buf_tab		dc	host_buf1,host_buf2,host_buf3,host_buf4
			dc	host_buf5,host_buf6,host_buf7,host_buf8
buf_ptr		equ	buf_tab+8

;---------- X:Memory ----------------------

			org x:0

VolLeft		dc 0
VolRight	dc 0
Inc			dc 0
parts		dc 0

			org	x:512
			dc	0,2,0,0


			if POSTEST
FracPos		dc 0,0,0,0,0,0,0,0
			endif

;---------- Peripherie --------------------

PBC			equ $ffe0
HCR			equ $ffe8
HSR			equ $ffe9
HRX			equ $ffeb
HTX			equ $ffeb

PCC			equ $ffe1
PCDDR		equ $ffe3
PCD			equ $ffe5
CRA			equ $ffec
CRB			equ $ffed
SSISR		equ $ffee
TX			equ $ffef
RX			equ $ffef
BCR			equ $fffe
IPR			equ $ffff

			org	p:0
			jmp 	>start

			org p:$10

			movep	y:(r7)+,x:TX			;Fast-Interrupt

			org p:$40

;			move	#512,r0
;			jsr		CalcFreq


;---------- Start -----------------------------------------------------

			movep	#0,x:BCR		;no Waitstates

;---------- Host initialisieren ---------------------------------------

			movep	#1,x:PBC

;---------- Play-Buffer ---------------------------------------------

			movec	#PlayBufSize-1,m6	;Buffersize
			movec	m6,m7

			clr		b
			move	#play_buf,r7
			move	#PlayBufSize,x0
			rep		x0
			move	b,y:(r7)+			;Buffer loeschen

			jsr		InitBufPtr

;---------- Hall-Buffer -----------------------------------------------

			move	#hall_buf,r5
			movec	#$1000-1,m5
			move	#$800,n5
			jsr		ClrHallBuf

;----------	SSI initialisieren ----------------------------------------

			movep	#$3000,x:IPR	;Int-Prioritaet
			movep	#$4100,x:CRA	;CRA, $4120
			movep	#$5800,x:CRB	;CRB, $5800 / $5a08

			movep	#$01f0,x:PCC	;PCC
			movep	#$0008,x:PCDDR  ;SC0 = Out

			andi	#$f0,mr			;Interrupt an, No Scaling

			move	#HallDelay,r0

FirstVBL	jclr	#0,x:HSR,FirstVBL	;warte auf 1.VBL
			movep	x:HRX,y:(r0)+		;HallDelay & Flags

wfs			jclr	#2,x:SSISR,wfs		;Wait for transmit-frame-sync

			move	#play_buf,r6    	;Calc-Pointer setzen
			move	#play_buf+984,r7	;Play-Pointer setzen
			jmp		loop1

;---------- Daten vom Host holen --------------------------------------

loop		move	#HallDelay,r0
loop_		jclr	#0,x:HSR,loop_	;warte auf VBL
			movep	x:HRX,y:(r0)+	;HallDelay

loop1		jclr	#0,x:HSR,loop1
			movep	x:HRX,y:(r0)+	;Tracks


			if      TEST
			bclr	#3,x:PCD
			endif

;---------- aktuelle Buffergroesse berechnen -----------------------------

			move	r7,b						;Play-Position
			move	r6,x0						;Calc-Position
			sub		x0,b	#PlayBufSize,x0		;Anzahl der zu berechn. Words
			jcc		SizeOK                      ;r7 > r6
			add		x0,b
SizeOK		lsr		b							;/2, wegen Stereo
			move	b,y:(r0)					;CurBufSize merken

_w			jclr	#<1,x:HSR,_w				;warten bis HTX leer
            movep	b,x:HTX						;CurBufSize -> CPU



;---------- Daten fÅr Tracks holen -------------------------------------

			move	#0,r3
ReadPart	jclr	#0,x:HSR,ReadPart
			movep	x:HRX,a
			tst		a						;kommt noch ein Part ?
			jne		ReadPartEnd				;nein
			move	(r3)+					;inc Partcounter

			move	#buf_ptr,r4
			do		y:<Tracks,ReadData
			move	y:(r4),r0				;get host_bufx
			jsr		CPUtoDSP
			move	r0,y:(r4)+				;host_buf-Position merken
ReadData	nop	
			jmp		<ReadPart

ReadPartEnd	move	r3,x:<parts

;---------- calculate Frequenz ------------------------------------------

			move	#>$250071,x0			;Opcode tfr	y1,a #<0,x1
			jclr	#17,y:<HallDelay,NoInterpol
			move	#>$21e571,x0			;Opcode tfr	y1,a b,x1
NoInterpol	movem	x0,p:Interpolate		;Patch
			movem	x0,p:NoOverflow

			move	#$4681e0,x0				;Opcode mpy
			movem	x0,p:MUL1
			move	#$4582e0,x0
			movem	x0,p:MUL2

			if		POSTEST
			move	#FracPos,r3
			endif

			move	#buf_tab,r4
			move	r6,n6					;n6 = Calc-Position

			do		y:<Tracks,CalcFreqs
			move	y:(r4)+,r0				;get Host-Buffer-Address
			jsr		<CalcFreq
			move	#$4681e2,x0				;Opcode mac
			movem	x0,p:MUL1
			move	#$4582e2,x0
			movem	x0,p:MUL2
CalcFreqs

;---------- make Surround-Effect ----------------------------------------

			jclr	#16,y:<HallDelay,HallEnd ;kein Hall
			move	y:<HallDelay,n5			;set HallDelay

			move	n6,r6					;Buffer
			move	#0.5,y0					;Hall-Faktor
            move	y:<CurBufSize,n0		;Groesse des zu fuellenden Buffers

			do		n0,HallEnd
			move	y:(r6)+,a  				;Orginal links
			move	a,x:(r5+n5)             ;in Hallbuffer speichern
			move	y:(r5),y1               ;Hall rechts holen
			macr	y1,y0,a	y:(r6)-,b     	;calc links, Orginal rechts
			move	b,y:(r5+n5)             ;in Hallbuffer speichern
			move	x:(r5)+,y1             	;Hall links holen
			macr	y1,y0,b	a,y:(r6)+     	;calc rechts, links zurÅck
			move	b,y:(r6)+             	;rechts zurÅck
HallEnd
			if		TEST
			bset	#<3,x:PCD
			move	a,x:HTX					;DSP fertig
			endif

			if		POSTEST
			move	#FracPos,r3
			do		y:<Tracks,SendPos
_w			jclr	#1,x:HSR,_w					;warten bis HTX leer
            movep	x:(r3)+,x:HTX				;FracPos -> CPU
SendPos
			endif

			jsr		InitBufPtr
			jmp		<loop

;---------- calculate Frequenz ----------------------------------------
;
;In:	r0: Pointer Datenbuffer

CalcFreq	move	n6,r6					;Calc-Start setzen
			do		x:<parts,CalcEndParts	;repeat for all parts

			move	#unpack_buf,r1
			move	x:(r0)+,b				;Anzahl der Bytes
			move	b,n1
			tst		b
			jsne	unpack
			move	#unpack_buf,r1
			move	x:(r0)+,b 				;Anzahl RepBytes
			move	(r1)+n1					;calc RepStart
			move	b,n1	
			move	r1,n0					;RepStart merken
			tst		b
			jeq		MakeRep					;kein Repeat
			jsr		unpack					;RepPart entpacken
			move	n0,r1					;r1, r2: RepeatStart
			move	n0,r2
;			move	#unpack_buf+1024,b		;unpack-Buffer-Ende
			move	#unpack_buf+4,b			;+4 Sicherheit
			move	x:(r0),x0				;worksize
			add		x0,b
			move	(r1)+n1					;r1: RepEnd
			move	r1,x0
			sub		x0,b					;BufEnd-RepEnd
			do		b,MakeRep
			move	y:(r2)+,x0				;Repstart ->
			move	x0,y:(r1)+				;Repend+1
MakeRep
			move	x:(r0)+,n0				;worksize

;---------- calculate Volume ------------------------------------------
; Balance: $c10000...$000000...$3f0000
;          left      mid       right
;          -0.492    0         0.492
; BalanceLeft  = 0.5 - Balance
; BalanceRight = 0.5 + Balance       


			move	x:(r0)+,x0				;SampVol
			move	x:(r0)+,x1				;MainVol
			mpy		x0,x1,a		x:(r0)+,y1	;y1 StereoPosition
			move	a,y0					;y0 gesamt-Volume
			move	#0.5,a
			sub		y1,a
			move	a,x0					;left
			mpy		x0,y0,a					;Calc Volume Left
			move	a,x:<VolLeft
			move	#0.5,a
			add		y1,a
			move	a,x0					;right
			mpy		x0,y0,a					;Calc Volume Right
			move	a,x:<VolRight

			move	x:(r0)+,b1				;SampPer
			lsr		b						;/2
			move	b1,x:<Inc				;INC-Wert

			move	#unpack_buf,r1

			move	x:(r0)+,b1				;fractional Position
			lsr		b						;fractional Position / 2

; Achtung ! Delta-Sample kann >1 werden !!!! Fehler !!!!

			move	y:(r1)+,y1				;Basis-Sample
			move	y:(r1)-,a				;nÑchste Sample
			sub		y1,a		#>2,n1		;Delta
			move	a,x0					;x0: Delta-Sample

Interpolate	tfr		y1,a	b,x1			;Basis-Sample | fractional Position oder 0

			do		n0,CalcEnd

			macr	x0,x1,a	x:<VolLeft,y0	;1stSample += deltaSample * fracPos
			move	a,x1	y:(r6),a		;Sample in x1 | read left track
MUL1		mac		x1,y0,a	x:<VolRight,y0	;calc left | Volume right
			move	a,y:(r6)+
			move	y:(r6),a				;read right track
MUL2		mac		x1,y0,a	x:<Inc,x1       ;calc right | INC-Wert
			add		x1,b	a,y:(r6)+		;pos += inc-Wert | Sample right -> Buffer
            jec		<NoOverflow				;Extension clear
			move	(r1)+					;next Sample
			move	y:(r1)+,y1				;Basis-Sample
			move	y:(r1)-,a				;nÑchste Sample
			sub		y1,a	#<$80,x1		;Delta | x1 = $800000
			eor		x1,b	a,x0			;öbertrag loeschen | x0: DeltaSample

NoOverflow	tfr		y1,a	b,x1			;Basis-Sample | fractional Position oder 0

CalcEnd		nop
CalcEndParts nop

			if		POSTEST
			move	b,x:(r3)+				;Fractional Pos merken
			endif
			rts

;********** unpack *****************************************************

;Input:	r0: Zeiger auf Hostbuffer

; unpack b Bytes
; b Bytes ( b/2+1 Words ) ab r0 nach r1

unpack    	lsr		b	#>1,x0      		;/2+1
            add		x0,b		#$8000,x1
			do		b,unpack_end			;Anzahl der zu unpacks Words
			move	x:(r0)+,x0
			move	x0,y:(r1)+
			move	x:(r0)+,x0
			move	x0,y:(r1)+
unpack_end	rts


;********** Move Daten von der CPU in den DSP ***************************

;Input:	r0: Zeiger auf Hostbuffer

CPUtoDSP	jsr		ReadSamp
			jsr		ReadSamp

			do		#6,ReadParameter
_w1			jclr	#0,x:HSR,_w1
			movep	x:HRX,x:(r0)+
ReadParameter
			rts

;---------- Samples von der CPU holen ------------------------------------

ReadSamp	jclr	#0,x:HSR,ReadSamp		;warten bis Daten da
			movep	x:HRX,b					;Anzahl der Bytes
            move	b,x:(r0)+				;merken
            tst		b
            jeq		read_end				;ist null
            lsr		b	#>1,x0      		;/2+1 ( wegen words und 68030er dbra )
            add		x0,b	#$8000,x1		;Shift-Faktor
			do		b,read_end
_w6			jclr	#<0,x:HSR,_w6			;warten bis Daten da
			movep	x:HRX,x0				;Samples lesen
			mpy		x0,x1,a					;shift right 8 Bits
			move	a,x0					;prepare x0 for 1s
			mpy		x0,x1,a		a0,x0		;shift right 8 Bits, store 2s in x0
			move	a0,x:(r0)+				;1. Sample-Byte
			move	x0,x:(r0)+				;2. Sample-Byte
read_end	
			rts

ClrHallBuf	clr		b
			move	#$1000,n0
			do		n0,ClrHallBuf1
			move	b,l:(r5)+			;Buffer loeschen
ClrHallBuf1
			rts

;---------- init buf_ptr -----------------------------------------------

InitBufPtr	move	#buf_tab,r0
			move	#buf_ptr,r1
			do		#8,InitBufPtr1
			move	y:(r0)+,x0
			move	x0,y:(r1)+
InitBufPtr1
			rts

			if		TEST
error		ori		#3,mr			;Interrupt aus
			stop
			endif

			nop

			dc $624954
			dc $6d4153
			dc $544552
			dc $202020
			dc $6e6f20
			dc $445350
			dc $202d20
			dc $6e6f20
			dc $66756e
			dc $202121

			end
