ON=1
OFF=0
TESTING=OFF
	IFNE TESTING
	move.l	#0,-(a7)
	move.l	#mod,-(a7)
	bsr	doit
	add.l	#8,a7
	clr	-(a7)
	trap	#1
	ENDC

doit	movem.l	d1-7/a0-6,-(a7)
	move.l	60(a7),a6
	move	64(a7),d6
	move	66(a7),d7
	bsr	super
	lea	old_ints(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.l	$70.w,(a0)+
	
start	bsr.s	play

wait	cmpi.b	#$39,$fffffc02.w
	bne.s	wait

stop	bsr	replay+8

exit	lea	old_ints(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	(a0)+,$70.w

	bsr	user
	movem.l	(a7)+,d1-7/a0-6
	rts
	
; Values for registers:
; ---------------------
;
; D0 = 
;
; $1388 = 5.0Khz
; $2134 = 8.5 khz
; $2ee0 = 12 khz
; $36b0 = 15.0 khz
; $5208 = 21 khz maximum ???
;
; D1 = Sound Mode
;
; 0 = 7-bit replay (all volume changes)
; 1 = 8-bit replay (all volume changes)
; 2 = 8-bit replay (NO volume changes!)
; 3 = STE/TT replay (all volume changes)
; 4 = STE/TT replay (NO volume changes)
;
; D2 = number of the used tracks ? (1-4, 0 none) - CAN'T TRANSLATE line below!
; d2 = Nr. des wegzulassenden Tracks      (1-4 oder 0=keiner) nur bei ST-Mode
; -------------------------------------------
; Register Usage etc.
;
; ST  = Cannot use a5,a6,d7
; STE = All registers are available
;
; Other information
;
; ST  = uses Timer D & soundchip for replay
; STE = uses Microwire Dat & Mask, SMODCNTR, FRMBAS, FRMEND
;
; (more translation required!!)
;
; benutzte Timer und Hardware Register
; ST
;           Timer D / Sound Chip
;           MFP im AOI-Modus keine L”schung des Interrupt_in_Service_A/B
;           Register n”tig. bclr #4,$fffffa11.w z.B. fr Timer D
; STe
;           MicoWire Dat / MicroWire Mask / SMODCNTR
;           sowie natrlich FRMBAS / FRMEND
;  Steereereeoo & 12517 Hz sind fest eingestellt
; -------------------------------------------
; Useful offsets in the code
;
; replay + 12 = VU Meters, 4 words    ($00 - $3e) --> read only
; replay + 20 = Song position, 1 word ($00 - $77) --> read only
; replay + 22 = Pattern posit. 1 word ($00 - $3f) --> read only
; replay + 24 = 
; replay + 26 = 
; replay + 28 = Fade out volume (still needs switching off though!)
; 
; mod_player+24:  Abblendspeed (0=nicht abblenden, 1=schnell bis 10=langsam)
;                 (Wort) (read/write) (Handhabung siehe main)
; mod_player+26:  Basislautst„rke ($40=normal laut, $00=Stille) (Wort)
;                 (read/write)  (Handhabung siehe main)
;************************************


play	move.l	a6,a0
	and	#7,d6
	add	d6,d6
	moveq	#0,d0
	moveq	#0,d1
	move	speed_tab(pc,d6),d0
	move	d7,d1
	moveq	#0,d2			; 
	bsr	replay
	clr.b	$fffffa07.w		; Timer B off ?
	clr.b	$fffffa09.w		; Timer C off ?
	lea	new_70(pc),a0
	move.l	a0,$70.w
	bsr	replay+4
	lea	replay+24(pc),a0
	clr.w	(a0)
exitpl	rts


new_70	movem.l	a0-a4/d0-d6,-(sp)
	bsr	replay+12
	movem.l	(sp)+,a0-a4/d0-d6
	rte

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	old_sp(pc),a4
	move.l	d0,(a4)
	rts

user	lea	old_sp(pc),a4
	move.l	(a4),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

speed_tab	dc.w	$1388	5.0 Khz
		dc.w	$2134	8.5 Khz
		dc.w	$2ee0	12.0 Khz
		dc.w	$36b0	15.0 Khz
		dc.w	$5208	21.0 Khz
		dc.w	$5208	
		dc.w	$5208	
		dc.w	$5208	
		
old_sp		ds.l	1
old_ints	ds.b	12

replay	incbin	'ninja342.bin'
	even

	IFNE TESTING
mod	incbin	c:\starbnd2.mod
	ENDC