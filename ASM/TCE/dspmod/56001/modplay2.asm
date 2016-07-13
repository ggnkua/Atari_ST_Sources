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

buf_ptr		ds	8

;---------- X:Memory ----------------------

			org x:0

VolLeft		dc 0
VolRight	dc 0
Inc			dc 0
parts		dc 0
calc_ptr:	dc 0
flags:		dc 0
exec:		dc 0
debug:		dc 0

			org	x:$100
register:	ds	32

			org	x:$200
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


WaitHoRX:	macro
_wrx:		jclr	#0,x:HSR,_wrx
			endm
			
			org	p:0
			jmp 	>start

			org p:$10

			movep	y:(r7)+,x:TX			;Fast-Interrupt

			org p:$24
			jsr		>loop
			jsr		>load_p56
			jsr		>dsp_exec	
											
			org p:$40
          	
;---------- Start -----------------------------------------------------

			movep	#0,x:BCR		;no Waitstates

;---------- Host initialisieren ---------------------------------------

			movep	#4,x:HCR		;enable Host Command Int
			movep	#1,x:PBC

;---------- Play-Buffer ---------------------------------------------

			movec	#PlayBufSize-1,m7	;Buffersize

			clr		b
			move	#play_buf,r7
			move	#PlayBufSize,x0
			rep		x0
			move	b,y:(r7)+			;Buffer loeschen

			jsr		InitBufPtr

;---------- Hall-Buffer -----------------------------------------------

;			move	#hall_buf,r5
;			movec	#$1000-1,m5
;			move	#$800,n5
;			jsr		ClrHallBuf  	;versaut F030 DSP-OS

;----------	SSI initialisieren ----------------------------------------

			movep	#$3800,x:IPR	;Int-Prioritaet
									;SSI = 2
									;HOST = 1
									
			movep	#$4100,x:CRA	;CRA, $4120
			movep	#$5800,x:CRB	;CRB, $5800 / $5a08

			movep	#$01f0,x:PCC	;PCC
			movep	#$0008,x:PCDDR  ;SC0 = Out

			andi	#$f0,mr			;Interrupt an, No Scaling


tunix:		move	x:<exec,a
			tst		a
			jeq		tunix
			move	a1,r0
			nop
			jmp		(r0)

;----------------------------------------------------------------------
;---------- Start Main Loop -------------------------------------------

;---------- Daten vom Host holen --------------------------------------

loop		jsr		save_reg
		
			move	#HallDelay,r0
			move	x:calc_ptr,r6
			movec	#PlayBufSize-1,m6

			jset	#0,x:flags,loop_

FirstVBL:	jclr	#0,x:HSR,FirstVBL	;warte auf 1.VBL
			movep	x:HRX,y:(r0)+		;HallDelay & Flags

wfs:		jclr	#2,x:SSISR,wfs		;Wait for transmit-frame-sync

			move	#play_buf,r6    	;Calc-Pointer setzen
			move	#play_buf+984,r7	;Play-Pointer setzen
			bset	#0,x:flags
			jmp		loop1

loop_		jclr	#0,x:HSR,loop_	;warte auf VBL
			movep	x:HRX,y:(r0)+	;HallDelay

loop1		jclr	#0,x:HSR,loop1
			movep	x:HRX,y:(r0)+	;Tracks


			if      TEST
;			bclr	#3,x:PCD
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

			movem	p:intp_off,x0
			jclr	#17,y:<HallDelay,NoInterpol
			movem	p:intp_on,x0
NoInterpol	movem	x0,p:Interpolate		;Patch
			movem	x0,p:NoOverflow

			movem	p:patch_a0,x0  			;set to zero
			movem	x0,p:patch_a
			movem	p:patch_b0,x0
			movem	x0,p:patch_b			

			if		POSTEST
			move	#FracPos,r3
			endif

			move	#buf_tab,r4
			move	r6,n6					;n6 = Calc-Position

			do		y:<Tracks,CalcFreqs
			move	y:(r4)+,r0				;get Host-Buffer-Address
			jsr		<CalcFreq

			movem	p:patch_a1,x0			;read Buffer and add
			movem	x0,p:patch_a
			movem	p:patch_b1,x0
			movem	x0,p:patch_b

CalcFreqs

;---------- make Surround-Effect ----------------------------------------
; r5 / m5 laden !!

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
;			bset	#<3,x:PCD
			movep	x:debug,x:HTX			;DSP fertig
			endif

			if		POSTEST
			move	#FracPos,r3
			do		y:<Tracks,SendPos
_w			jclr	#1,x:HSR,_w					;warten bis HTX leer
            movep	x:(r3)+,x:HTX				;FracPos -> CPU
SendPos
			endif

			move	r6,x:calc_ptr
			jsr		InitBufPtr
			jsr		load_reg
;			jmp		<loop
			rti

;---------- End Main Loop ---------------------------------------------
;----------------------------------------------------------------------

intp_off:	tfr	y1,a #<0,x1
intp_on:    tfr	y1,a b,x1



;---------- calculate Frequenz ----------------------------------------
;           alle Parts fÅr einen Track
;
;In:	r0: enthÑlt alle Parameter / Samples fÅr einen Track

CalcFreq	move	n6,r6					;Calc-Start setzen
			
			do		x:<parts,CalcEndParts	;repeat for all parts

			move	#8,n0                   ;Anzahl Parameter
			move	r0,r5					;r5 zeigt auf Parameter
			move	(r0)+n0					;skip Parameter

			move	r0,r1
			move	x:(r5)+,n1  			;size non-repeat
			nop
			move	(r1)+n1    				;r1 zeigt auf Repeatstart
			move	r1,r2					;r2 auch

			move	x:(r5)+,a        		;size repeated
			move	a,n1
			tst		a
			jeq		NoRepeat     			;kein Repeat

			move	r0,b					;adr start samples
			move	x:(r5),x0				;worksize
			add		x0,b                    ;bestimme Bufferende
			
			move	(r1)+n1					;r1: RepEnd
			move	r1,x0
			sub		x0,b 	#>1,x0			;BufEnd-RepEnd
			sub		x0,b
			jle		NoRepeat
			
; fÅlle den unpack-Buffer mit dem RepeatstÅck aus

			do		b,MakeRep
			move	x:(r2)+,x0				;Repstart ->
			move	x0,x:(r1)+				;Repend
MakeRep:
NoRepeat:			

			move	r0,r1    				;r1 uses for freqcalc
						
			move	x:(r5)+,a				;worksize
			move	a,n2
			move	#>5,x0 					;next part start by
			add		x0,a  	r5,r0           ; + worksize + 8
			move	a1,n0
			nop
			move	(r0)+n0

;---------- calculate Volume ------------------------------------------
; Balance: $c10000...$000000...$3f0000
;          left      mid       right
;          -0.492    0         0.492
; BalanceLeft  = 0.5 - Balance
; BalanceRight = 0.5 + Balance       


			move	x:(r5)+,x0				;SampVol
			move	x:(r5)+,x1				;MainVol
			mpy		x0,x1,a		x:(r5)+,y1	;y1 StereoPosition
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

			move	x:(r5)+,b1				;SampPer
			lsr		b						;/2
			move	b1,x:<Inc				;INC-Wert

			move	x:(r5)+,b1				;fractional Position
			lsr		b						;fractional Position / 2

; Achtung ! Delta-Sample kann >1 werden !!!! Fehler !!!!

			move	x:(r1)+,y1				;Basis-Sample
			move	x:(r1),a				;nÑchste Sample
			sub		y1,a		#>2,n1		;Delta
			move	a,x0					;x0: Delta-Sample

Interpolate	tfr		y1,a	b,x1			;Basis-Sample | fractional Position oder 0

			do		n2,CalcEnd

			macr	x0,x1,a	x:<VolLeft,y0	;1stSample += deltaSample * fracPos
patch_a:	move	a,x1	y:(r6),a		;Sample in x1 | read left track
			mac		x1,y0,a	x:<VolRight,y0	;calc left | Volume right
			move	a,y:(r6)+
patch_b:	move	y:(r6),a				;read right track
			mac		x1,y0,a	x:<Inc,x1       ;calc right | INC-Wert
			add		x1,b	a,y:(r6)+		;pos += inc-Wert | Sample right -> Buffer
            jec		<NoOverflow				;Extension clear
			move	x:(r1)+,y1				;Basis-Sample
			move	x:(r1),a				;nÑchste Sample
			sub		y1,a	#<$80,x1		;Delta | x1 = $800000
			eor		x1,b	a,x0			;öbertrag loeschen | x0: DeltaSample

NoOverflow:	tfr		y1,a	b,x1			;Basis-Sample | fractional Position oder 0

CalcEnd:	nop

CalcEndParts nop

			if		POSTEST
			move	b,x:(r3)+				;Fractional Pos merken
			endif
			rts

patch_a0:	clr		a		a,x1
patch_a1:	move	a,x1	y:(r6),a
patch_b0:	clr		a
patch_b1:	move	y:(r6),a	
			
;********** Move Daten von der CPU in den DSP ***************************

;Input:	r0: Zeiger auf Hostbuffer

CPUtoDSP:	move	r0,r1
			move	(r0)+
			move	(r0)+
			do		#6,ReadPara     		;get parameters
			WaitHoRX
			movep	x:HRX,x:(r0)+
ReadPara:

			move	r0,r2					;ab r2 kommen die Samples
			
			WaitHoRX
			movep	x:HRX,b					;Anzahl Bytes
			move	b,n2
			move	b,x:(r1)+
			jsr		ReadSamp                ;get non-repeated part

			WaitHoRX
			movep	x:HRX,b					;Anzahl Bytes
			move	b,x:(r1)+			
            move	(r2)+n2       			;r1 = end non-repeated part
            move	r2,r0
			jsr		ReadSamp				;repeated part
			
			move	x:(r1),a				;Worksize
			move	#>6,x0                  ;next part
			add		x0,a	r1,r0
			move	a,n0
			nop
			move	(r0)+n0

			rts

;---------- Samples von der CPU holen ------------------------------------

ReadSamp:	tst		b
            jeq		read_end				;ist null
            lsr		b	#>1,x0      		;/2+1 ( wegen words und 68030er dbra )
            add		x0,b	#$8000,x1		;Shift-Faktor

			do		b,read_end
			WaitHoRX						;warten bis Daten da
			movep	x:HRX,x0				;Samples lesen
			mpy		x0,x1,a					;shift right 8 Bits
			move	a,x0					;prepare x0 for 1s
			mpy		x0,x1,a		a0,x0		;shift right 8 Bits, store 2s in x0
			move	a0,x:(r0)+				;1. Sample-Byte
			move	x0,x:(r0)+				;2. Sample-Byte
read_end:	
			rts


;------------------------------------------------------------------------------

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


;-----------------------------------------------------------------------
;load P56-Files, Ende mit -1 ( $ffffff )


load_p56:	jsr		read_host			;Address Space
			move	#-1,a
			cmp		x0,a				;= -1 ?
			jeq		ld_p56end			;fertig
			
			move	x0,x1
			jsr		read_host			;Load address
			move	x0,r0
			jsr		read_host			;Block-Size

			do		x0,read_data
			jsr		read_host			;Daten
			clr		a
			cmp		x1,a	#>1,a		;P-Memory ?
			jne		no_p				;nein
			move	x0,p:(r0)+
			jmp		do_end	

no_p		cmp		x1,a	#>2,a		;X:Memory ?
			jne		no_x				;nein
			move	x0,x:(r0)+			;write to X:Memory
			jmp		do_end
			
no_x		cmp		x1,a				;Y:Memory ?
			jne		do_end				;nein
			move	x0,y:(r0)+			;write to Y:Memory
do_end:		nop
read_data:	nop
			jmp		load_p56


dsp_exec:	jsr		read_host
            move	x0,x:exec
ld_p56end:	rti

read_host:	jclr	#0,X:HSR,read_host
			movep	x:HRX,x0
			rts


;---------- Register retten / laden ------------------------------------

save_reg:	move	r0,x:register
			move	m0,x:register+1
			move	#register+2,r0
			move	#$ffff,m0
			nop
			move	r1,x:(r0)+
			move	m1,x:(r0)+
			move	r2,x:(r0)+
			move	m2,x:(r0)+
			move	r3,x:(r0)+
			move	m3,x:(r0)+
			move	r4,x:(r0)+
			move	m4,x:(r0)+
			move	r5,x:(r0)+
			move	m5,x:(r0)+
			move	r6,x:(r0)+
			move	m6,x:(r0)+
			move	n0,x:(r0)+
			move	n1,x:(r0)+
			move	n2,x:(r0)+
			move	n3,x:(r0)+
			move	n4,x:(r0)+
			move	n5,x:(r0)+
			move	n6,x:(r0)+
			move	a0,x:(r0)+
			move	a1,x:(r0)+
			move	a2,x:(r0)+
			move	b0,x:(r0)+
			move	b1,x:(r0)+
			move	b2,x:(r0)+
			move	x0,x:(r0)+
			move	x1,x:(r0)+
			move	y0,x:(r0)+
			move	y1,x:(r0)+
			rts	

load_reg:	move	#register+2,r0
			move	#$ffff,m0
			nop
			move	x:(r0)+,r1
			move	x:(r0)+,m1
			move	x:(r0)+,r2
			move	x:(r0)+,m2
			move	x:(r0)+,r3
			move	x:(r0)+,m3
			move	x:(r0)+,r4
			move	x:(r0)+,m4
			move	x:(r0)+,r5
			move	x:(r0)+,m6
			move	x:(r0)+,r6
			move	x:(r0)+,m6
			move	x:(r0)+,n0
			move	x:(r0)+,n1
			move	x:(r0)+,n2
			move	x:(r0)+,n3
			move	x:(r0)+,n4
			move	x:(r0)+,n5
			move	x:(r0)+,n6
			move	x:(r0)+,a0
			move	x:(r0)+,a1
			move	x:(r0)+,a2
			move	x:(r0)+,b0
			move	x:(r0)+,b1
			move	x:(r0)+,b2
			move	x:(r0)+,x0
			move	x:(r0)+,x1
			move	x:(r0)+,y0
			move	x:(r0)+,y1
			move	x:register,r0
			move	x:register+1,m0
			rts	







			if		TEST
error		ori		#3,mr			;Interrupt aus
			stop
			endif

			nop

			dc	"Help me!"
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
