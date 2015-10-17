;=======================
;=
;= Falcon 030 system init
;=
;=======================

		section text
Sys.Init	movea.l 4(sp),a5	; Free unused space
		move.l	$0c(a5),d0
		add.l	$14(a5),d0
		add.l	$1c(a5),d0
		addi.l	#$1100,d0	
		move.l	a5,d1
		add.l	d0,d1
		bclr.l	#0,d1		; Even address
		movea.l d1,sp

		move.l	d0,-(sp)
		move.l	a5,-(sp)
		move.w	d0,-(sp)
		move.w	#$4a,-(sp)	; Mshrink()
		trap	#1
		lea.l	12(sp),sp


malloc	macro	size
		pea.l	\1
		move.w	#72,-(sp)	; Malloc()
		trap	#1
		addq.l	#6,sp
	endm

		malloc	2*x_res*y_res+256; Reserve screen (ST RAM)
		tst.l	d0
		beq.w	Term
		
		addi.l	#255,d0
		clr.b	d0		; Even by 256 bytes
		move.l  d0,Screen

		movea.l	d0,a0
		move.w	#2*x_res*y_res/64-1,d7
.cls
	rept 16
		clr.l	(a0)+
	endr
		dbra	d7,.cls

		clr.l	-(sp)		; Super()
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,Save.usp


		move.l	#"_VDO",d1	; Check machinetype
		move.l	$05a0.w,d0
		beq.w	Term

.search		tst.l	(d0)		; Search for VDO cookie
		beq.w	Term
		
		cmp.l	(d0),d1
		beq.s	.found
		addq.l	#8,d0	
		bra.s	.search

.found		addq.l	#4,d0
		cmpi.l	#$030000,(d0)	; MCH = Falcon?
		bne.w	Term

		move.b	$ffff8006.w,d0	; Determine display type
		lsr.b	#6,d0
		beq.w	Term		; Mono, exit


		lea.l	Save.videl,a0	; Save all the affected videl vars.
		move.l	$ffff8200.w,(a0)+
		move.w	$ffff820c.w,(a0)+
		move.l	$ffff8282.w,(a0)+
		move.l	$ffff8286.w,(a0)+
		move.l	$ffff828a.w,(a0)+
		move.l	$ffff82a2.w,(a0)+
		move.l	$ffff82a6.w,(a0)+
		move.l	$ffff82aa.w,(a0)+
		move.w	$ffff82c0.w,(a0)+
		move.w	$ffff82c2.w,(a0)+
		move.l	$ffff820e.w,(a0)+
		move.w	$ffff820a.w,(a0)+
		move.b	$ffff8256.w,(a0)+
		clr.b	(a0)
		cmpi.w	#$b0,$ffff8282.w
		sle.b	(a0)+
		move.w	$ffff8266.w,(a0)+
		move.w	$ffff8260.w,(a0)+ 

		lea.l	scp+122,a0	; SCP modules (RGB&TV/VGA)
		
	 	btst.l	#0,d0		; VGA?
		bne.s	.RGB

		lea.l	158(a0),a0	; Point to VGA module
			
.RGB		move.l  (a0)+,$ffff8282.w
		move.l	(a0)+,$ffff8286.w
		move.l	(a0)+,$ffff828a.w
		move.l	(a0)+,$ffff82a2.w
		move.l	(a0)+,$ffff82a6.w
		move.l	(a0)+,$ffff82aa.w
		move.w	(a0)+,$ffff820a.w
		move.w	(a0)+,$ffff82c0.w
		move.w	(a0)+,$ffff8266.w
		move.w	(a0)+,$ffff8266.w
		move.w	(a0)+,$ffff82c2.w
		move.w	(a0)+,$ffff8210.w


		move.l	Screen,d0	; Set new screen base
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w


		move.w	sr,d0
		move.w	#$2700,sr	; Clear IRQs

		lea.l	Save.mfp,a0	; Save MFP settings
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa25.w,(a0)+
		move.l	$70.w,(a0)+
		move.l	$110.w,(a0)

		move.b	#%1010000,$fffffa09.w	; Enable Timer-D
		move.b	#%1010000,$fffffa15.w	; and Keyboard IRQ
		
		;bset.b	#4,$fffffa09.w
		;bset.b	#4,$fffffa15.w
		
		clr.b	$fffffa07.w	; Disable other Timers
		clr.b	$fffffa13.w
		
		or.b	#%111,$fffffa1d.w	; Set Timer D to 
		move.b	#123,$fffffa25.w	; approx. 100 Hz

		move.l	#.timer_d,$110.w	; New ISRs
		move.l	#.rte,$70.w	

		move.w	d0,sr
		
		
		lea.l	$fffffc00.w,a0	; Disable mouse
.ikbd		btst.b  #1,(a0)         ; IKBD ready ?
                beq.s   .ikbd
                
                move.b  #$12,2(a0)


		section data
.timer_d	addq.l	#1,Time.diff	; Count 100Hz frames
		bclr.b	#4,$fffffa11.w	; Clear busybit
.rte		rte

scp		incbin	'inc\320r20st.scp'
		incbin	'inc\320v200t.scp'


		section bss
Save.usp	ds.l	1
Save.mfp	ds.l	3
Save.videl	ds.w	25 	; videl variables
	  
Screen		ds.l	1

		section	text